import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/api_service.dart';
import '../config/api_config.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Import conditionnel pour gérer dart:io (incompatible avec le Web)
/*import 'platform_stub.dart'
if (dart.library.io) 'platform_io.dart';*/

class AuthService {
  final ApiService apiService = ApiService();

  /// 🔥 Retourne l'URL de l'API selon la plateforme
String getApiUrl() {
  return "http://192.168.1.110:8000/api/auth"; // IP de ton PC pour téléphones réels
}

  /// 🚀 Inscription
  Future<Map<String, dynamic>?> registerUser(String name, String email, String password) async {
    try {
      // Récupérer le FCM token
      final fcmToken = await FirebaseMessaging.instance.getToken();

      final String apiUrl = getApiUrl();
      final uri = Uri.parse('$apiUrl/register');

      debugPrint("🔗 URL appelée : $uri");
      debugPrint("📱 FCM Token: $fcmToken");

      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          'name': name.trim(),
          'email': email.trim(),
          'password': password,
          'password_confirmation': password,
          'fcm_token': fcmToken,
        }),
      );

      debugPrint("📡 Status Code : ${response.statusCode}");
      debugPrint("📡 Response Body : ${response.body}");

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data;
      } else {
        debugPrint("⚠ Échec inscription : ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint("❌ Erreur d'inscription : $e");
      return null;
    }
  }

  /// 🚀 Connexion
  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    try {
      if (kDebugMode) {
        print('🔐 Tentative de connexion pour: $email');
      }

      final response = await http.post(
        Uri.parse('${getApiUrl()}/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
        }),
      );

      if (kDebugMode) {
        print('📡 Status Code: ${response.statusCode}');
        print('📡 Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Vérifie si l'authentification a réussi
        if (data['status'] == 'success' || data['user'] != null) {
          // Mise à jour du FCM token une fois connecté
          try {
            final fcmToken = await FirebaseMessaging.instance.getToken();
            if (fcmToken != null) {
              await http.post(
                Uri.parse('http://192.168.1.110:8000/api/client/${data['user']['id']}/fcm-token'),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
                body: jsonEncode({'fcm_token': fcmToken}),
              );
            }
          } catch (e) {
            print('⚠️ Erreur lors de la mise à jour du FCM token: $e');
            // On continue même si la mise à jour du FCM token échoue
          }
          
          return {
            'user': data['user'],
            'token': data['access_token'],
          };
        }
        throw Exception('Réponse invalide du serveur');
      } else if (response.statusCode == 401) {
        throw Exception('Identifiants invalides');
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Erreur de connexion');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur détaillée: $e');
      }
      rethrow;
    }
  }

  /// Mise à jour du FCM token
  Future<void> _updateFcmToken(int userId, String fcmToken) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.110:8000/api/client/$userId/fcm-token'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'fcm_token': fcmToken}),
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur lors de la mise à jour du FCM token');
      }
    } catch (e) {
      print('❌ Erreur mise à jour FCM token: $e');
      rethrow;
    }
  }

  /// 🚀 Vérifie si un utilisateur est connecté
  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null;
  }

  /// 🚀 Récupérer l'utilisateur connecté
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      final userId = prefs.getInt('user_id');
      final userName = prefs.getString('user_name');
      final userEmail = prefs.getString('user_email');

      if (userId != null && userName != null && userEmail != null) {
        return {
          'id': userId,
          'name': userName,
          'email': userEmail,
        };
      }
    }

    return null;
  }

  /// 🚀 Déconnexion
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
  }

  /// 🚚 Récupérer la liste des chauffeurs
  Future<List<dynamic>> getDrivers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        debugPrint("⚠ Pas de token d'authentification");
        return [];
      }

      final response = await http.get(
        Uri.parse('${getApiUrl()}/drivers'),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      debugPrint("📡 Status Code : ${response.statusCode}");
      debugPrint("📡 Response Body : ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['drivers'] ?? [];
      } else {
        debugPrint("⚠ Échec de récupération des chauffeurs : ${response.body}");
        return [];
      }
    } catch (e) {
      debugPrint("❌ Erreur lors de la récupération des chauffeurs : $e");
      return [];
    }
  }
}