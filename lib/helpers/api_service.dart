import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chauffeur_model.dart';
import 'package:flutter/foundation.dart' as foundation;

class ApiService {
  // ✅ Utilise l'adresse IP locale correcte de ton PC (visible dans ipconfig/ifconfig)
  final String baseUrl = 'http://localhost:8000/api';

  // 🔍 Récupère les chauffeurs proches
  Future<List<Chauffeur>> getChauffeursProches(double latitude, double longitude) async {
    try {
      // Vérification si on est sur le web
      if (foundation.kIsWeb) {
        // Logique spécifique pour le web (si nécessaire)
        print("Web platform detected");
        // Retourne une liste vide ou autres actions spécifiques au web
        return [];
      }

      final response = await http.get(
        Uri.parse('$baseUrl/drivers/nearby?latitude=$latitude&longitude=$longitude'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          List<dynamic> chauffeursData = data['data'];
          return chauffeursData.map((json) => Chauffeur.fromJson(json)).toList();
        } else {
          throw Exception('Erreur: ${data['message']}');
        }
      } else {
        throw Exception('Erreur ${response.statusCode}: Impossible de récupérer les chauffeurs.');
      }
    } catch (e) {
      throw Exception('Erreur réseau (getChauffeursProches) : $e');
    }
  }

  // 📤 Envoie une demande à un chauffeur spécifique
  Future<void> sendRequestToChauffeur(int chauffeurId, double clientLat, double clientLon) async {
    try {
      // Vérification si on est sur le web
      if (foundation.kIsWeb) {
        // Logique spécifique pour le web (si nécessaire)
        print("Web platform detected for request");
        // Retourne une action différente ou vide pour le web
        return;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/drivers/request'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'client_latitude': clientLat,
          'client_longitude': clientLon,
          'driver_id': chauffeurId,
        }),
      );

      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);
        throw Exception('Erreur de la requête : ${data['message']}');
      }
    } catch (e) {
      throw Exception('Erreur réseau (sendRequestToChauffeur) : $e');
    }
  }
}
