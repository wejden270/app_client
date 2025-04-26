class Chauffeur {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final double latitude;
  final double longitude;
  final String status;

  Chauffeur({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    required this.latitude,
    required this.longitude,
    required this.status,
  });

  factory Chauffeur.fromJson(Map<String, dynamic> json) {
    return Chauffeur(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      status: json['status'] ?? 'disponible',
    );
  }
}