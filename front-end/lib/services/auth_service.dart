import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_storage.dart';

class AuthService {
  // Pour l'émulateur Android : 10.0.2.2 pointe vers ton PC
  static const String baseUrl = 'http://10.0.2.2:4000';

  // ===================== LOGIN =====================
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data.containsKey('accessToken')) {
      await TokenStorage.writeAccessToken(data['accessToken']);
      await TokenStorage.writeRefreshToken(data['refreshToken']);
    }

    return data;
  }

  // ===================== SIGNUP =====================
  static Future<Map<String, dynamic>> signup(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    return jsonDecode(response.body);
  }

  // ===================== REFRESH TOKEN =====================
  static Future<String?> refreshToken() async {
    final refreshToken = await TokenStorage.readRefreshToken();
    if (refreshToken == null) return null;

    final response = await http.post(
      Uri.parse('$baseUrl/users/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'rftoken': refreshToken}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data.containsKey('accessToken')) {
      await TokenStorage.writeAccessToken(data['accessToken']);
      return data['accessToken'];
    }

    return null;
  }

  // ===================== LOGOUT =====================
  static Future<void> logout() async {
    await TokenStorage.deleteAll();
  }
}

