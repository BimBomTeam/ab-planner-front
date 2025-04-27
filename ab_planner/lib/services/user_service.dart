import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ab_planner/models/group_model.dart';

class UserService {
  static const String _baseUrl = 'http://localhost:3000/api';

  static Future<List<GroupModel>> fetchGroups(String startYear) async {
    final encodedYear = Uri.encodeComponent(startYear);
    final url = Uri.parse('$_baseUrl/groups/start-year/$encodedYear');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((groupJson) => GroupModel.fromJson(groupJson)).toList();
    } else {
      throw Exception('Błąd ładowania grup');
    }
  }

  static Future<void> saveProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String fieldOfStudy,
    required String startYear,
    required int groupId,
  }) async {
    final url = Uri.parse('$_baseUrl/users');
    final body = {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'field_of_study': fieldOfStudy,
      'start_year': startYear,
      'group_id': groupId,
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    if (response.statusCode != 201) {
      throw Exception('Błąd zapisu danych');
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
}
