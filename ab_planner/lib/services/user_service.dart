import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ab_planner/models/group_model.dart';

class UserService {
  static const String _baseUrl = 'http://193.122.12.41:3000/api';

  /// Pobierz wszystkie grupy
  static Future<List<GroupModel>> fetchAllGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final url = Uri.parse('$_baseUrl/groups');
    final response = await http.get(
      url,
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    print('fetchAllGroups status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((groupJson) => GroupModel.fromJson(groupJson)).toList();
    } else {
      throw Exception('Błąd ładowania grup');
    }
  }

  /// Pobierz grupy dla konkretnego rocznika
  static Future<List<GroupModel>> fetchGroups(String startYear) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final encodedYear = Uri.encodeComponent(startYear);
    final url = Uri.parse('$_baseUrl/groups/start-year/$encodedYear');
    final response = await http.get(
      url,
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    print('fetchGroups status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((groupJson) => GroupModel.fromJson(groupJson)).toList();
    } else {
      throw Exception('Błąd ładowania grup');
    }
  }

  /// Pobierz dane konkretnej grupy po ID
  static Future<GroupModel> fetchGroupById(int groupId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final url = Uri.parse('$_baseUrl/groups/$groupId');
    final response = await http.get(
      url,
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    print('fetchGroupById status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return GroupModel.fromJson(data);
    } else {
      throw Exception('Błąd ładowania grupy');
    }
  }

  /// Zapisz dane użytkownika
  static Future<void> saveProfile({
    required int userId,
    required String firstName,
    required String lastName,
    required int groupId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final url = Uri.parse('$_baseUrl/users/$userId');
    final body = {
      'first_name': firstName,
      'last_name': lastName,
      'group_id': groupId,
    };

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode(body),
    );

    print('saveProfile status: ${response.statusCode}');
    print('saveProfile response: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Błąd zapisu danych');
    }
  }

  /// Wyloguj użytkownika
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  /// Pobierz dane aktualnie zalogowanego użytkownika
  static Future<Map<String, dynamic>> fetchCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final url = Uri.parse('$_baseUrl/users/me');
    final response = await http.get(
      url,
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    print('fetchCurrentUser status: ${response.statusCode}');
    print('fetchCurrentUser body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Błąd pobierania danych użytkownika');
    }
  }

  /// Pobierz dostępne kierunki
  static Future<List<Map<String, dynamic>>> fetchMajorsWithIds() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final url = Uri.parse('$_baseUrl/majors');
    final response = await http.get(
      url,
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    print('fetchMajors status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((major) => {
        'id': major['id'],
        'name': major['name'],
      }).toList();
    } else {
      throw Exception('Błąd ładowania kierunków');
    }
  }

  /// Pobierz unikalne roczniki startowe
  static Future<List<String>> fetchStartYears() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final url = Uri.parse('$_baseUrl/groups');
    final response = await http.get(
      url,
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    print('fetchStartYears status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      final years = data
          .map((group) => group['start_year'] as String)
          .toSet()
          .toList();
      years.sort((a, b) => b.compareTo(a));
      return years;
    } else {
      throw Exception('Błąd ładowania roczników');
    }
  }
}
