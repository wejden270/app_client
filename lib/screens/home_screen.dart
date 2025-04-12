import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double? latitude;
  double? longitude;
  bool isLoading = true;
  List<dynamic> drivers = [];
  MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await _determinePosition();
      print("position ===== $position");
      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
        isLoading = false;
      });
      _fetchNearbyDrivers();
    } catch (error) {
      setState(() => isLoading = false);
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Le service de géolocalisation est désactivé.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return Future.error('Permission refusée définitivement.');
      }
    }
    
    return await Geolocator.getCurrentPosition();
  }

  Future<void> _fetchNearbyDrivers() async {
    final url = Uri.parse('https://ton-domaine.com/api/drivers/nearby');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      try {
        final List<dynamic> driverData = json.decode(response.body);
        setState(() {
          drivers = driverData.where((driver) {
            double distance = Geolocator.distanceBetween(
              latitude!,
              longitude!,
              driver['latitude'],
              driver['longitude'],
            ) / 1000;
            return distance <= 50;
          }).toList();
        });
      } catch (e) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Position du client"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isLoading
                ? const CircularProgressIndicator()
                : latitude == null || longitude == null
                ? const Text("Impossible d'obtenir la position.")
                : Text("Latitude: $latitude, Longitude: $longitude"),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                if (latitude != null && longitude != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapScreen(
                        latitude: latitude!,
                        longitude: longitude!,
                        drivers: drivers,
                      ),
                    ),
                  );
                }
              },
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text("Voir la carte", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MapScreen extends StatelessWidget {
  final double latitude;
  final double longitude;
  final List<dynamic> drivers;

  const MapScreen({
    Key? key,
    required this.latitude,
    required this.longitude,
    required this.drivers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Carte des chauffeurs"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(latitude, longitude),
                initialZoom: 14.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 50.0,
                      height: 50.0,
                      point: LatLng(latitude, longitude),
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.blue,
                        size: 40.0,
                      ),
                    ),
                    ...drivers.map((driver) {
                      return Marker(
                        width: 50.0,
                        height: 50.0,
                        point: LatLng(driver['latitude'], driver['longitude']),
                        child: const Icon(
                          Icons.directions_car,
                          color: Colors.red,
                          size: 40.0,
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: drivers.isEmpty
                ? const Center(child: Text("Aucun chauffeur à proximité"))
                : ListView.builder(
              itemCount: drivers.length,
              itemBuilder: (context, index) {
                final driver = drivers[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: ListTile(
                    leading: const Icon(Icons.directions_car, color: Colors.red),
                    title: Text("Chauffeur ${index + 1}"),
                    subtitle: Text(
                      "Latitude: ${driver['latitude']}, Longitude: ${driver['longitude']}",
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}