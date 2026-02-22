import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'token_storage.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:4000';

  // ===================== GET SÉCURISÉ =====================
  static Future<Map<String, dynamic>> _authorizedGet(String endpoint) async {
    String? accessToken = await TokenStorage.readAccessToken();

    var response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    // Si token expiré → refresh
    if (response.statusCode == 401) {
      final newToken = await AuthService.refreshToken();
      if (newToken != null) {
        response = await http.get(
          Uri.parse('$baseUrl$endpoint'),
          headers: {
            'Authorization': 'Bearer $newToken',
            'Content-Type': 'application/json',
          },
        );
      }
    }

    return jsonDecode(response.body);
  }

  // ===================== DASHBOARD =====================
  static Future<Map<String, dynamic>> getDashboard() async {
    return await _authorizedGet('/users/dashboard');
  }
}
