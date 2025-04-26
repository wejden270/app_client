import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'chauffeur_detail_screen.dart';
import '../config/api_config.dart';

class MapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final List<dynamic> drivers;

  const MapScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.drivers,
  });

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final MapController _mapController;
  late LatLng _initialPosition;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _initialPosition = LatLng(widget.latitude, widget.longitude);
    _getUserLocation();
    updateLocation();
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
      body: Stack(
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
                  ...widget.drivers.map(
                    (driver) => Marker(
                      point: LatLng(driver['latitude'], driver['longitude']),
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
          // AJOUTER LA LISTE DES CHAUFFEURS CLIQUABLES
          Positioned(
            bottom: 80,
            left: 10,
            right: 10,
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ListView.builder(
                itemCount: widget.drivers.length,
                itemBuilder: (context, index) {
                  final driver = widget.drivers[index];
                  return ListTile(
                    leading: const Icon(Icons.local_taxi),
                    title: Text(driver['name']),
                    subtitle: Text(
                      'Lat: ${driver['latitude']}, Lng: ${driver['longitude']}',
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChauffeurDetailScreen(
                            chauffeurId: driver['id'],
                            chauffeurNom: driver['name'],
                            chauffeurLat: driver['latitude'],
                            chauffeurLng: driver['longitude'],
                            clientLat: _initialPosition.latitude,
                            clientLng: _initialPosition.longitude,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
