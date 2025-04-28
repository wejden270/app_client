import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class DemandeService {
  final String baseUrl = ApiConfig.baseUrl;
  final Map<String, String> headers = ApiConfig.headers;

  Future<Map<String, dynamic>> envoyerDemande(
    int clientId,
    int chauffeurId,
    double clientLatitude,
    double clientLongitude,
  ) async {
    try {
      if (kDebugMode) {
        print('📤 Envoi demande: client=$clientId, chauffeur=$chauffeurId');
        print('📍 Position client: lat=$clientLatitude, lng=$clientLongitude');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/demandes'),
        headers: headers,
        body: jsonEncode({
          'client_id': clientId,
          'chauffeur_id': chauffeurId,
          'client_latitude': clientLatitude,
          'client_longitude': clientLongitude,
          'status': 'en_attente',
        }),
      ).timeout(ApiConfig.timeout);

      if (kDebugMode) {
        print('📡 Status: ${response.statusCode}');
        print('📡 Response: ${response.body}');
      }

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur demande: $e');
      }
      throw Exception('Échec de la demande: $e');
    }
  }

  Future<Map<String, dynamic>> getDemande(int demandeId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/demandes/$demandeId'),
        headers: headers,
      ).timeout(ApiConfig.timeout);

      if (kDebugMode) {
        print('📡 Status: ${response.statusCode}');
        print('📡 Response: ${response.body}');
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur récupération demande: $e');
      }
      throw Exception('Échec de la récupération: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getMesDemandes(int clientId) async {
    try {
      if (kDebugMode) {
        print('📤 Récupération des demandes pour le client: $clientId');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/client/$clientId/demandes'),
        headers: headers,
      ).timeout(ApiConfig.timeout);

      if (kDebugMode) {
        print('📡 Status: ${response.statusCode}');
        print('📡 Response: ${response.body}');
      }

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['data'] != null && jsonResponse['data'] is List) {
          return List<Map<String, dynamic>>.from(jsonResponse['data']);
        } else {
          throw Exception('Format de réponse invalide');
        }
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur récupération demandes: $e');
      }
      throw Exception('Échec de la récupération: $e');
    }
  }

  Future<void> annulerDemande(int demandeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final clientId = prefs.getInt('user_id');
      
      if (clientId == null) {
        throw Exception('Client non connecté');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/client/$clientId/demandes/$demandeId/cancel'),
        headers: headers,
      ).timeout(ApiConfig.timeout);

      if (kDebugMode) {
        print('📡 Status: ${response.statusCode}');
        print('📡 Response: ${response.body}');
      }

      if (response.statusCode != 200) {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur annulation demande: $e');
      }
      throw Exception('Échec de l\'annulation: $e');
    }
  }
}
