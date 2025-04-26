import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Import conditionnel pour gérer dart:io (incompatible avec le Web)
/*import 'platform_stub.dart'
if (dart.library.io) 'platform_io.dart';*/

class AuthService {
  /// 🔥 Retourne l'URL de l'API selon la plateforme
String getApiUrl() {
  return "http://192.168.1.110:8000/api/auth"; // IP de ton PC pour téléphones réels
}

  /// 🚀 Inscription
  Future<Map<String, dynamic>?> registerUser(String name, String email, String password) async {
    try {
      final String apiUrl = getApiUrl();
      final uri = Uri.parse('$apiUrl/register');

      debugPrint("🔗 URL appelée : $uri");
      debugPrint("📤 Données envoyées : name=$name, email=$email, password=$password");

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
      final String apiUrl = getApiUrl();
      final uri = Uri.parse('$apiUrl/login');

      debugPrint("🔗 URL appelée : $uri");
      debugPrint("📤 Données envoyées : email=$email, password=$password");

      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
        }),
      );

      debugPrint("📡 Status Code : ${response.statusCode}");
      debugPrint("📡 Response Body : ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        debugPrint("⚠ Échec de la connexion : ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint("❌ Erreur de connexion : $e");
      return null;
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