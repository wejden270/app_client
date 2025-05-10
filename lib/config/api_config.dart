import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String baseUrl = 'http://192.168.1.110:8000/api';
  static const Duration timeout = Duration(seconds: 30);

  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-Requested-With': 'XMLHttpRequest',
  };

  // Routes API
  static const String loginRoute = '/auth/login';
  static const String registerRoute = '/auth/register';
}
