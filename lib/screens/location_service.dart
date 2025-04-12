import 'package:geolocator/geolocator.dart';

class LocationService {
  // Vérifier si la géolocalisation est activée
  Future<bool> isLocationServiceEnabled() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("❌ Les services de localisation sont désactivés.");
    }
    return serviceEnabled;
  }

  // Vérifier et demander les permissions de localisation
  Future<LocationPermission> checkAndRequestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      print("🔴 Permission de localisation refusée. Demande en cours...");
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      print("⛔ Permission de localisation refusée définitivement.");
    }

    return permission;
  }

  // Obtenir la position actuelle avec gestion des erreurs et timeout
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('⚠️ Activez les services de localisation.');
    }

    LocationPermission permission = await checkAndRequestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      return Future.error('❌ Autorisation de localisation refusée.');
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10), // Évite un blocage trop long
      );
    } catch (e) {
      print("⚠️ Erreur lors de la récupération de la position : $e");
      return Future.error('Erreur lors de la localisation.');
    }
  }
}