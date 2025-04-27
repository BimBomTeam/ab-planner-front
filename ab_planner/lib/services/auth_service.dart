import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _baseUrl = 'http://localhost:3000/api/users';

  static Future<String?> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final token = data['token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      return token;
    } else {
      final data = json.decode(response.body);
      throw Exception(data['error'] ?? 'Nieprawidłowe dane logowania');
    }
  }

  static Future<String?> register(String firstName, String lastName, String email, String password) async {
    final url = Uri.parse('$_baseUrl/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final token = data['token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      return token;
    } else {
      final data = json.decode(response.body);
      throw Exception(data['error'] ?? 'Błąd rejestracji');
    }
  }
  static Future<void> resetPassword(String email) async {
  final url = Uri.parse('$_baseUrl/reset-password');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'email': email}),
  );

  if (response.statusCode != 200) {
    final data = json.decode(response.body);
    throw Exception(data['error'] ?? 'Błąd resetowania hasła');
  }
}

}
