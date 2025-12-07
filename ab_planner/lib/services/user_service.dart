import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ab_planner/models/group_model.dart';
import 'package:ab_planner/models/program_model.dart';
import 'package:ab_planner/models/student_selection_model.dart';
import 'package:flutter/foundation.dart';
import 'package:ab_planner/models/notification_model.dart';
import 'package:ab_planner/models/user_model.dart';

class UserService {
  static const String _baseUrl = 'http://193.122.12.41:8000/api/v1';

  /// Pobierz wszystkie programy (kierunki) z rocznikiami i specjalizacjami
  static Future<List<ProgramModel>> fetchAllPrograms() async {
    final url = Uri.parse('$_baseUrl/programs');
    final response = await http.get(url);

    debugPrint('fetchAllPrograms status: \${response.statusCode}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data
          .map((programJson) => ProgramModel.fromJson(programJson))
          .toList();
    } else {
      throw Exception('Błąd ładowania programów');
    }
  }

  /// DEPRECATED - stary endpoint, zachowane dla kompatybilności
  /// Użyj fetchAllPrograms() zamiast tego
  static Future<List<GroupModel>> fetchAllGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final url = Uri.parse('$_baseUrl/groups');
    final response = await http.get(
      url,
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    );

    debugPrint('fetchAllGroups status: \${response.statusCode}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((groupJson) => GroupModel.fromJson(groupJson)).toList();
    } else {
      throw Exception('Błąd ładowania grup');
    }
  }

  /// DEPRECATED - stary endpoint, użyj fetchGroups() z nowymi parametrami
  static Future<List<GroupModel>> fetchGroupsByStartYear(
    String startYear,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final encodedYear = Uri.encodeComponent(startYear);
    final url = Uri.parse('$_baseUrl/groups/start-year/$encodedYear');
    final response = await http.get(
      url,
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    );

    debugPrint('fetchGroupsByStartYear status: \${response.statusCode}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((groupJson) => GroupModel.fromJson(groupJson)).toList();
    } else {
      throw Exception('Błąd ładowania grup');
    }
  }

  /// DEPRECATED - stary endpoint, użyj fetchGroupById() z nowym API
  static Future<GroupModel> fetchOldGroupById(int groupId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final url = Uri.parse('$_baseUrl/groups/$groupId');
    final response = await http.get(
      url,
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    );

    debugPrint('fetchOldGroupById status: \${response.statusCode}');

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

    debugPrint('saveProfile status: \${response.statusCode}');
    debugPrint('saveProfile response: \${response.body}');

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
  static Future<User> fetchCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final url = Uri.parse('$_baseUrl/users/me');
    final response = await http.get(
      url,
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    );

    debugPrint('fetchCurrentUser status: \${response.statusCode}');
    debugPrint('fetchCurrentUser body: \${response.body}');

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Błąd pobierania danych użytkownika');
    }
  }

  /// Pobierz dostępne kierunki (programy)
  static Future<List<Map<String, dynamic>>> fetchMajorsWithIds() async {
    final programs = await fetchAllPrograms();
    return programs
        .map((program) => {'id': program.id, 'name': program.name})
        .toList();
  }

  /// Pobierz unikalne roczniki z wszystkich programów
  static Future<List<int>> fetchStartYears() async {
    final programs = await fetchAllPrograms();
    final years = <int>{};

    for (final program in programs) {
      for (final year in program.years) {
        years.add(year.year);
      }
    }

    final yearsList = years.toList();
    yearsList.sort((a, b) => b.compareTo(a)); // Od najnowszego do najstarszego
    return yearsList;
  }

  /// Pobierz grupy dla danego programu z opcjonalnymi filtrami
  static Future<List<Group>> fetchProgramGroups({
    required int programId,
    int? programYearId,
    int? specializationId,
    String? groupType,
  }) async {
    final queryParams = <String, String>{};
    if (programYearId != null) {
      queryParams['program_year_id'] = programYearId.toString();
    }
    if (specializationId != null) {
      queryParams['specialization_id'] = specializationId.toString();
    }
    if (groupType != null) {
      queryParams['group_type'] = groupType;
    }

    final url = Uri.parse(
      '$_baseUrl/programs/$programId/groups',
    ).replace(queryParameters: queryParams);

    final response = await http.get(url);

    debugPrint('fetchProgramGroups status: \${response.statusCode}');
    debugPrint('fetchProgramGroups url: \$url');

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((groupJson) => Group.fromJson(groupJson)).toList();
    } else {
      throw Exception('Błąd ładowania grup programu');
    }
  }

  /// Pobierz wszystkie grupy z opcjonalnymi filtrami
  static Future<List<Group>> fetchGroups({
    int? programId,
    int? programYearId,
    int? specializationId,
    String? groupType,
  }) async {
    final queryParams = <String, String>{};
    if (programId != null) {
      queryParams['program_id'] = programId.toString();
    }
    if (programYearId != null) {
      queryParams['program_year_id'] = programYearId.toString();
    }
    if (specializationId != null) {
      queryParams['specialization_id'] = specializationId.toString();
    }
    if (groupType != null) {
      queryParams['group_type'] = groupType;
    }

    final url = Uri.parse(
      '$_baseUrl/groups',
    ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    final response = await http.get(url);

    debugPrint('fetchGroups status: \${response.statusCode}');
    debugPrint('fetchGroups url: \$url');

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((groupJson) => Group.fromJson(groupJson)).toList();
    } else {
      throw Exception('Błąd ładowania grup');
    }
  }

  /// Pobierz szczegóły pojedynczej grupy po ID
  static Future<Group> fetchGroupById(int groupId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final url = Uri.parse('$_baseUrl/groups/$groupId');
    final response = await http.get(
      url,
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    );

    debugPrint('fetchGroupById status: \${response.statusCode}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Group.fromJson(data);
    } else {
      throw Exception('Błąd ładowania grupy');
    }
  }

  /// Pobierz wybory grup studenta
  static Future<List<StudentGroupSelection>> fetchStudentGroupSelections({
    int? userId,
  }) async {
    final queryParams = <String, String>{};
    if (userId != null) {
      queryParams['user_id'] = userId.toString();
    }

    final url = Uri.parse(
      '$_baseUrl/student-group-selection',
    ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final response = await http.get(
      url,
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    );

    debugPrint('fetchStudentGroupSelections status: \${response.statusCode}');
    debugPrint('fetchStudentGroupSelections url: \$url');

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data
          .map((selectionJson) => StudentGroupSelection.fromJson(selectionJson))
          .toList();
    } else {
      throw Exception('Błąd ładowania wyborów grup');
    }
  }

  /// Utwórz wybór grupy dla studenta
  static Future<StudentGroupSelection> createStudentGroupSelection({
    required int groupId,
    int? userId, // Opcjonalne - backend może użyć zalogowanego użytkownika
  }) async {
    final url = Uri.parse('$_baseUrl/student-group-selection');

    final body = CreateStudentGroupSelectionRequest(
      groupId: groupId,
      userId: userId,
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body.toJson()),
    );

    debugPrint('createStudentGroupSelection status: \${response.statusCode}');
    debugPrint('createStudentGroupSelection body: \${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      return StudentGroupSelection.fromJson(data);
    } else {
      throw Exception('Błąd tworzenia wyboru grupy');
    }
  }

  /// Pobierz powiadomienia
  static Future<List<Notification>> fetchNotifications({
    int? userId,
    String? status,
  }) async {
    final queryParams = <String, String>{};
    if (userId != null) {
      queryParams['user_id'] = userId.toString();
    }
    if (status != null) {
      queryParams['status'] = status;
    }

    final url = Uri.parse(
      '$_baseUrl/notifications',
    ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    final response = await http.get(url);

    debugPrint('fetchNotifications status: \${response.statusCode}');
    debugPrint('fetchNotifications url: \$url');

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data
          .map((notificationJson) => Notification.fromJson(notificationJson))
          .toList();
    } else {
      throw Exception('Błąd ładowania powiadomień');
    }
  }
}
