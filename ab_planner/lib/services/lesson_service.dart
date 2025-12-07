import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:ab_planner/models/lesson.dart';

class LessonService {
  // static const String _baseUrl = 'http://193.122.12.41:8000/api/v1/lessons'; // Unused
  static const String _oldBaseUrl = 'http://193.122.12.41:3000/api/lessons';

  static int? _cachedGroupId;

  /// 🔐 Pobiera token JWT z lokalnego storage
  static Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) throw Exception('Brak tokena uwierzytelniającego.');
    return token;
  }

  /// Pobierz lekcje z nowymi filtrami (API v1)
  static Future<List<LessonV1>> fetchLessons({
    int? groupId,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    final token = await _getToken();

    final queryParams = <String, String>{};
    if (groupId != null) {
      queryParams['group_id'] = groupId.toString();
    }
    if (dateFrom != null) {
      queryParams['date_from'] = dateFrom.toIso8601String();
    }
    if (dateTo != null) {
      queryParams['date_to'] = dateTo.toIso8601String();
    }

    final url = Uri.parse(
      'http://193.122.12.41:8000/api/v1/lessons',
    ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    debugPrint('🌍 Fetching lessons from: $url');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    debugPrint('📩 Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      debugPrint('📦 Fetched ${data.length} lessons');
      return data.map((json) => LessonV1.fromJson(json)).toList();
    } else {
      debugPrint('❌ Error fetching lessons: ${response.body}');
      throw Exception('Failed to load lessons: ${response.statusCode}');
    }
  }

  // === STARE FUNKCJE - ZACHOWANE DLA KOMPATYBILNOŚCI ===

  // === STARE FUNKCJE - ZACHOWANE DLA KOMPATYBILNOŚCI ===

  /// 🧠 Pobiera group_id z /api/users/me -> Group.id (DEPRECATED)
  static Future<int> getUserGroupId() async {
    if (_cachedGroupId != null) return _cachedGroupId!;

    final token = await _getToken();

    final response = await http.get(
      Uri.parse('http://193.122.12.41:3000/api/users/me'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      debugPrint(response.body);
      final data = jsonDecode(response.body);
      if (data != null &&
          data['Group'] != null &&
          data['Group']['id'] != null) {
        _cachedGroupId = data['Group']['id'];
        return _cachedGroupId!;
      } else {
        throw Exception('Brak przypisanej grupy do użytkownika.');
      }
    } else {
      throw Exception('Nie udało się pobrać danych użytkownika.');
    }
  }

  /// 📅 Pobiera lekcje z danego dnia i dla grupy użytkownika (DEPRECATED)
  static Future<List<Lesson>> getLessonsByDate(DateTime date) async {
    final groupId = await getUserGroupId();
    final token = await _getToken();

    final formattedDate = date.toIso8601String().split('T').first;
    final url = '$_oldBaseUrl/date/$formattedDate/group/$groupId';

    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((lessonData) => Lesson.fromJson(lessonData)).toList();
    } else {
      final data = jsonDecode(response.body);
      final message =
          data['message'] ??
          data['error'] ??
          'Nie udało się pobrać lekcji na dany dzień.';
      throw Exception(message);
    }
  }

  /// 📥 Pobiera wszystkie lekcje (DEPRECATED)
  static Future<List<Lesson>> getLessons() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse(_oldBaseUrl),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((lessonData) => Lesson.fromJson(lessonData)).toList();
    } else {
      final data = jsonDecode(response.body);
      final message =
          data['message'] ?? data['error'] ?? 'Nie udało się pobrać lekcji.';
      throw Exception(message);
    }
  }

  /// ➕ Dodaje lekcję (DEPRECATED)
  static Future<void> addLesson({
    required String room,
    required String title,
    required DateTime start,
    required DateTime end,
    required int teacherId,
    required int lessonTypeId,
    required int groupId,
    required String frequency,
    required String term,
  }) async {
    final token = await _getToken();

    final response = await http.post(
      Uri.parse(_oldBaseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'room': room,
        'title': title,
        'start': start.toUtc().toIso8601String(),
        'end': end.toUtc().toIso8601String(),
        'teacher_id': teacherId,
        'lesson_type_id': lessonTypeId,
        'group_id': groupId,
        'frequency': frequency,
        'term': term,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final data = jsonDecode(response.body);
      final message =
          data['message'] ?? data['error'] ?? 'Nie udało się dodać lekcji.';
      throw Exception(message);
    }
  }

  /// ✏️ Aktualizuje lekcję (DEPRECATED)
  static Future<void> updateLesson({
    required int id,
    required String room,
    required String title,
    required DateTime start,
    required DateTime end,
    required int teacherId,
    required int lessonTypeId,
    required int groupId,
    required String frequency,
    required String term,
  }) async {
    final token = await _getToken();

    final response = await http.put(
      Uri.parse('$_oldBaseUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'room': room,
        'title': title,
        'start': start.toUtc().toIso8601String(),
        'end': end.toUtc().toIso8601String(),
        'teacher_id': teacherId,
        'lesson_type_id': lessonTypeId,
        'group_id': groupId,
        'frequency': frequency,
        'term': term,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      final data = jsonDecode(response.body);
      final message =
          data['message'] ??
          data['error'] ??
          'Nie udało się zaktualizować lekcji.';
      throw Exception(message);
    }
  }
}
