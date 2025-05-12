import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LessonFormService {
  static const String _baseUrl = 'http://10.0.2.2:3000/api';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<List<Map<String, dynamic>>> fetchTeachers() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/teachers'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    }
    throw Exception('Błąd ładowania nauczycieli');
  }

  static Future<List<Map<String, dynamic>>> fetchLessonTypes() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/lesson-types'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    }
    throw Exception('Błąd ładowania typów zajęć');
  }

  static Future<List<Map<String, dynamic>>> fetchGroups() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/groups'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    }
    throw Exception('Błąd ładowania grup');
  }

  static Future<List<String>> fetchFrequencies() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/lesson-frequencies'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return List<String>.from(json.decode(response.body));
    }
    throw Exception('Błąd ładowania częstotliwości');
  }

  static Future<List<String>> fetchTerms() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/terms'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return List<String>.from(json.decode(response.body));
    }
    throw Exception('Błąd ładowania semestrów');
  }
}
