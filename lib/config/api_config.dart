import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _serverIP = '192.168.1.110';  // Votre IP WiFi
  static const int _serverPort = 8000;

  // ✅ Utilisation correcte avec un getter
  static String get baseUrl => 'http://$_serverIP:$_serverPort/api';
  
  static const Duration timeout = Duration(seconds: 30);
  
  static final Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
