import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;

  const MapScreen({super.key, required this.latitude, required this.longitude});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final MapController _mapController;
  late LatLng _initialPosition;
  List<Map<String, dynamic>> _chauffeursProches = [];
  Map<String, dynamic>? _chauffeurSelectionne;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _initialPosition = LatLng(widget.latitude, widget.longitude);
    _getUserLocation();
    updateLocation();
    fetchNearbyDrivers();
  }

  Future<void> fetchNearbyDrivers() async {
    const String apiUrl = 'http://localhost:8000/api/drivers/nearby';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<Map<String, dynamic>> chauffeurs = data
            .map((driver) => {
          'id': driver['id'],
          'name': driver['name'],
          'latitude': driver['latitude'],
          'longitude': driver['longitude'],
        })
            .toList();

        // Filtrer les chauffeurs à moins de 50 km
        List<Map<String, dynamic>> filteredChauffeurs = chauffeurs.where((chauffeur) {
          final double distance = Geolocator.distanceBetween(
            _initialPosition.latitude,
            _initialPosition.longitude,
            chauffeur['latitude'],
            chauffeur['longitude'],
          );
          return distance <= 50000; // 50 km
        }).toList();

        setState(() {
          _chauffeursProches = filteredChauffeurs;
        });
      }
    } catch (e) {
      print('Erreur lors de la récupération des chauffeurs: $e');
    }
  }

  Future<void> sendRequestToDriver() async {
    if (_chauffeurSelectionne == null) return;

    final String apiUrl = 'http://localhost:8000/api/request-driver';
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: jsonEncode({
          'client_latitude': _initialPosition.latitude,
          'client_longitude': _initialPosition.longitude,
          'driver_id': _chauffeurSelectionne!['id'],
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Demande envoyée à ${_chauffeurSelectionne!['name']}")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Échec de l'envoi de la demande")),
        );
      }
    } catch (e) {
      print('Erreur lors de l’envoi de la demande : $e');
    }
  }

  Future<void> _getUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _initialPosition = LatLng(position.latitude, position.longitude);
      });
      _mapController.moveAndRotate(_initialPosition, 14, 0);
    } catch (e) {
      print("Impossible d'obtenir la position actuelle : $e");
    }
  }

  void updateLocation() {
    Geolocator.getPositionStream().listen((Position position) {
      setState(() {
        _initialPosition = LatLng(position.latitude, position.longitude);
        _mapController.moveAndRotate(_initialPosition, 14, 0);
      });
    });
  }

  Future<void> _centerMapOnUser() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _initialPosition = LatLng(position.latitude, position.longitude);
      });
      _mapController.moveAndRotate(_initialPosition, 14, 0);
    } catch (e) {
      print("Erreur lors du centrage de la carte : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Carte du client")),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _initialPosition,
                    initialZoom: 14,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                      userAgentPackageName: 'com.example.app_client',
                    ),
                    MarkerLayer(
                      markers: [
                        // Marqueur de l'utilisateur
                        Marker(
                          point: _initialPosition,
                          width: 40.0,
                          height: 40.0,
                          child: const Icon(
                            Icons.person_pin_circle,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                        // Marqueurs des chauffeurs proches
                        ..._chauffeursProches.map(
                              (chauffeur) => Marker(
                            point: LatLng(chauffeur['latitude'], chauffeur['longitude']),
                            width: 40.0,
                            height: 40.0,
                            child: const Icon(
                              Icons.local_taxi,
                              color: Colors.green,
                              size: 40,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: FloatingActionButton(
                    onPressed: _centerMapOnUser,
                    child: const Icon(Icons.my_location),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                const Text(
                  "Chauffeurs disponibles :",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _chauffeursProches.length,
                    itemBuilder: (context, index) {
                      final chauffeur = _chauffeursProches[index];
                      return ListTile(
                        title: Text(chauffeur['name']),
                        subtitle: Text(
                            "Lat: ${chauffeur['latitude']}, Lng: ${chauffeur['longitude']}"),
                        trailing: Radio<Map<String, dynamic>>(
                          value: chauffeur,
                          groupValue: _chauffeurSelectionne,
                          onChanged: (Map<String, dynamic>? value) {
                            setState(() {
                              _chauffeurSelectionne = value;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: sendRequestToDriver,
                  child: const Text("Demander un chauffeur"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}