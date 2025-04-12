class Chauffeur {
  final int id;
  final String name;
  final String email;
  final double latitude;
  final double longitude;
  final String status;
  final double distance;

  Chauffeur({
    required this.id,
    required this.name,
    required this.email,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.distance,
  });

  factory Chauffeur.fromJson(Map<String, dynamic> json) {
    return Chauffeur(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      status: json['status'],
      distance: double.parse(json['distance'].toString()),
    );
  }
}