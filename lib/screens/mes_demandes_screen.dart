import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/demande_service.dart';
import 'package:intl/intl.dart';

class MesDemandesScreen extends StatefulWidget {
  const MesDemandesScreen({super.key});

  @override
  State<MesDemandesScreen> createState() => _MesDemandesScreenState();
}

class _MesDemandesScreenState extends State<MesDemandesScreen> {
  final DemandeService _demandeService = DemandeService();
  List<Map<String, dynamic>> _demandes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _chargerDemandes();
  }

  Future<void> _chargerDemandes() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final clientId = prefs.getInt('user_id');
      if (clientId == null) throw Exception('Client non connecté');
      
      final demandes = await _demandeService.getMesDemandes(clientId);
      setState(() => _demandes = demandes);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _annulerDemande(int demandeId) async {
    try {
      await _demandeService.annulerDemande(demandeId);
      await _chargerDemandes();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Demande annulée'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Demandes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _chargerDemandes,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _chargerDemandes,
              child: ListView.builder(
                itemCount: _demandes.length,
                itemBuilder: (context, index) {
                  final demande = _demandes[index];
                  final status = demande['status'] as String;
                  final date = DateTime.parse(demande['created_at']);
                  
                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      title: Text('Demande ${index + 1}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Date: ${DateFormat('dd/MM/yyyy HH:mm').format(date)}'),
                          Text('Status: $status'),
                          if (demande['chauffeur_nom'] != null && demande['chauffeur_nom'] != 'Inconnu')
                            Text('Chauffeur: ${demande['chauffeur_nom']}'),
                        ],
                      ),
                      trailing: status == 'en_attente' || status == 'en_cours'
                          ? TextButton.icon(
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              label: const Text('Annuler'),
                              onPressed: () => _annulerDemande(demande['id']),
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
    );
  }
}
