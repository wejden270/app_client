import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

// Import conditionnel pour gérer dart:io (incompatible avec le Web)
import 'platform_stub.dart'
if (dart.library.io) 'platform_io.dart';

class AuthService {
  /// 🔥 Retourne l'URL de l'API selon la plateforme
  String getApiUrl() {
    if (kIsWeb) {
      return "http://192.168.1.110:8000/api/auth"; // Adresse pour tests Web
    }

    if (kDebugMode) {
      if (MyPlatform.isAndroid) {
        return "http://10.0.2.2:8000/api/auth"; // Android Emulator
      } else {
        return "http://192.168.1.110:8000/api/auth"; // iOS/physique
      }
    } else {
      return "https://mon-api.com/api/auth"; // Production
    }
  }

  /// 🚀 Inscription
  Future<User?> registerUser(String name, String email, String password) async {
    try {
      final String apiUrl = getApiUrl();
      final uri = Uri.parse('$apiUrl/register');

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

      if (response.statusCode == 201) {
        final data = json.decode(response.body);

        if (data is Map<String, dynamic> &&
            data.containsKey('token') &&
            data.containsKey('user')) {
          final userData = data['user'];

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', data['token']);
          await prefs.setInt('user_id', userData['id']);
          await prefs.setString('user_name', userData['name']);
          await prefs.setString('user_email', userData['email']);

          return User(
            id: userData['id'],
            name: userData['name'],
            email: userData['email'],
            password: "",
          );
        }
        return null;
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
  Future<User?> loginUser(String email, String password) async {
    try {
      final String apiUrl = getApiUrl();
      final uri = Uri.parse('$apiUrl/login');

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

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is Map<String, dynamic> &&
            data.containsKey('token') &&
            data.containsKey('user')) {
          final userData = data['user'];

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', data['token']);
          await prefs.setInt('user_id', userData['id']);
          await prefs.setString('user_name', userData['name']);
          await prefs.setString('user_email', userData['email']);

          return User(
            id: userData['id'],
            name: userData['name'],
            email: userData['email'],
            password: "",
          );
        }
        return null;
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
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      final userId = prefs.getInt('user_id');
      final userName = prefs.getString('user_name');
      final userEmail = prefs.getString('user_email');

      if (userId != null && userName != null && userEmail != null) {
        return User(
          id: userId,
          name: userName,
          email: userEmail,
          password: "",
        );
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
}
