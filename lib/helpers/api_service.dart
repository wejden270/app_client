import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/chauffeur_model.dart';
import 'package:flutter/foundation.dart' as foundation;
import '../config/api_config.dart';

class ApiService {
  final String baseUrl = ApiConfig.baseUrl;
  final Duration timeout = ApiConfig.timeout;
  
  Map<String, String> get _headers => ApiConfig.headers;

  Future<bool> testConnection() async {
    try {
      if (foundation.kDebugMode) {
        print('🔍 Test de connexion au serveur...');
        print('🌐 URL: $baseUrl');
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/ping'),
        headers: _headers,
      ).timeout(const Duration(seconds: 5));
      
      if (foundation.kDebugMode) {
        print('📡 Status: ${response.statusCode}');
        print('📡 Body: ${response.body}');
      }
      
      return response.statusCode == 200;
    } catch (e) {
      if (foundation.kDebugMode) {
        print('❌ Erreur de connexion: $e');
      }
      return false;
    }
  }

  // Méthode utilitaire pour créer un client HTTP avec timeout
  http.Client _createClient() {
    return http.Client();
  }

  Future<dynamic> _handleResponse(http.Response response) async {
    if (foundation.kDebugMode) {
      print('📡 URL appelée: ${response.request?.url}');
      print('📡 Headers envoyés: ${response.request?.headers}');
      print('📡 Status Code: ${response.statusCode}');
      print('📡 Response Body: ${response.body}');
    }

    try {
      final data = json.decode(response.body);
      
      switch (response.statusCode) {
        case 200:
        case 201:
          return data;
        case 401:
          throw Exception('Identifiants incorrects ou session expirée');
        case 403:
          throw Exception('Accès non autorisé');
        case 422:
          throw Exception(data['message'] ?? 'Données invalides');
        default:
          throw Exception('Erreur serveur (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Erreur de communication avec le serveur: $e');
    }
  }

  Future<T> _executeRequest<T>(Future<T> Function() request) async {
    try {
      if (foundation.kDebugMode) {
        print('🌐 Tentative de connexion à : $baseUrl');
        print('🔧 Headers: $_headers');
      }
      
      return await request().timeout(timeout);
    } on SocketException catch (e) {
      if (foundation.kDebugMode) {
        print('❌ Erreur de connexion socket: ${e.address}:${e.port}');
        print('❌ Message: ${e.message}');
        print('❌ OS Error: ${e.osError}');
      }
      throw Exception(
        'Impossible de se connecter au serveur. '
        'Vérifiez que le serveur est en cours d\'exécution sur $baseUrl '
        'et que votre appareil est connecté à Internet.'
      );
    } on TimeoutException {
      throw Exception('Le serveur met trop de temps à répondre. Délai dépassé après ${timeout.inSeconds} secondes.');
    } catch (e) {
      if (foundation.kDebugMode) {
        print('❌ Erreur inattendue: $e');
      }
      throw Exception('Erreur de connexion: $e');
    }
  }

  Future<dynamic> _handleRequest(Future<http.Response> Function() request) async {
    try {
      if (foundation.kDebugMode) {
        print('🌐 Tentative de connexion à : $baseUrl');
      }
      
      final response = await request();
      
      if (foundation.kDebugMode) {
        print('📡 Status Code: ${response.statusCode}');
        print('📡 Response: ${response.body}');
      }

      return json.decode(response.body);
    } catch (e) {
      if (foundation.kDebugMode) {
        print('❌ Erreur de connexion: $e');
      }
      throw Exception('Erreur de connexion au serveur: $e');
    }
  }

  // 🔍 Récupère les chauffeurs proches
  Future<List<Chauffeur>> getChauffeursProches(double latitude, double longitude) async {
    try {
      if (foundation.kDebugMode) {
        print('📍 Recherche des chauffeurs proches');
        print('📍 Position: $latitude, $longitude');
        print('🌐 URL: $baseUrl/drivers/nearby');
      }

      final response = await _executeRequest(() => http.get(
        Uri.parse('$baseUrl/drivers/nearby').replace(
          queryParameters: {
            'latitude': latitude.toString(),
            'longitude': longitude.toString(),
          },
        ),
        headers: _headers,
      ));

      final data = await _handleResponse(response);
      
      if (foundation.kDebugMode) {
        print('📡 Réponse reçue: $data');
      }

      List<dynamic> chauffeursData;
      if (data is List) {
        chauffeursData = data;
      } else if (data is Map) {
        chauffeursData = data['data'] ?? data['drivers'] ?? [];
      } else {
        chauffeursData = [];
      }

      final chauffeurs = chauffeursData
          .where((item) => item != null)
          .map((json) => Chauffeur.fromJson(json))
          .toList();

      if (foundation.kDebugMode) {
        print('✅ Chauffeurs trouvés: ${chauffeurs.length}');
      }

      return chauffeurs;
    } catch (e) {
      if (foundation.kDebugMode) {
        print('❌ Erreur getChauffeursProches: $e');
      }
      rethrow;
    }
  }

  // 📤 Envoie une demande à un chauffeur spécifique
  Future<void> sendRequestToChauffeur(int chauffeurId, double clientLat, double clientLon) async {
    try {
      if (foundation.kDebugMode) {
        print('📍 Envoi requête chauffeur: $chauffeurId');
        print('📍 Position: $clientLat, $clientLon');
      }

      final response = await _executeRequest(() => http.post(
        Uri.parse('$baseUrl/drivers/request'),
        headers: _headers,
        body: jsonEncode({
          'client_latitude': clientLat,
          'client_longitude': clientLon,
          'driver_id': chauffeurId,
        }),
      ));

      await _handleResponse(response);
    } catch (e) {
      if (foundation.kDebugMode) {
        print('❌ Erreur requête chauffeur: $e');
      }
      rethrow;
    }
  }
}