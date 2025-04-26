import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class DemandeService {
  final String baseUrl = ApiConfig.baseUrl;
  final Map<String, String> headers = ApiConfig.headers;

  Future<Map<String, dynamic>> envoyerDemande(int clientId, int chauffeurId) async {
    try {
      if (kDebugMode) {
        print('📤 Envoi demande: client=$clientId, chauffeur=$chauffeurId');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/demandes'),
        headers: headers,
        body: jsonEncode({
          'client_id': clientId,
          'chauffeur_id': chauffeurId,
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
}
