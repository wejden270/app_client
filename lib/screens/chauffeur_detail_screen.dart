import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import '../models/chauffeur_model.dart';
import '../helpers/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/demande_service.dart';

class ChauffeurDetailScreen extends StatefulWidget {
  final int chauffeurId;
  final String chauffeurNom;
  final double chauffeurLat;
  final double chauffeurLng;
  final double clientLat;
  final double clientLng;

  const ChauffeurDetailScreen({
    super.key,
    required this.chauffeurId,
    required this.chauffeurNom,
    required this.chauffeurLat,
    required this.chauffeurLng,
    required this.clientLat,
    required this.clientLng,
  });

  @override
  State<ChauffeurDetailScreen> createState() => _ChauffeurDetailScreenState();
}

class _ChauffeurDetailScreenState extends State<ChauffeurDetailScreen> {
  final DemandeService _demandeService = DemandeService();
  Map<String, dynamic>? chauffeurDetails;
  bool _isLoading = false;

  Future<void> _sendRequest() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final clientId = prefs.getInt('user_id');

      if (clientId == null) {
        throw Exception('Client non connecté');
      }

      await _demandeService.envoyerDemande(
        clientId,
        widget.chauffeurId,
        widget.clientLat,
        widget.clientLng,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Demande envoyée avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('❌ Erreur: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur lors de l\'envoi de la demande: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détail du chauffeur'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.chauffeurNom,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('Position du chauffeur :'),
            Text('Latitude: ${widget.chauffeurLat}'),
            Text('Longitude: ${widget.chauffeurLng}'),
            if (chauffeurDetails?.containsKey('phone') ?? false)
              Text('Téléphone : ${chauffeurDetails!['phone']}'),
            Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    onPressed: _sendRequest,
                    icon: Icon(Icons.send),
                    label: Text('Envoyer une demande'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
