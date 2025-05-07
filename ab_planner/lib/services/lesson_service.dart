import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ab_planner/models/lesson.dart';

class LessonService {
  static const String _baseUrl = 'http://10.0.2.2:3000/api/lessons';

  static Future<void> addLesson({
    required String room,
    required String title,
    required DateTime start,
    required DateTime end,
    required int teacherId,
    required int lessonTypeId,
    required int groupId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('Brak tokena uwierzytelniającego.');
    }

    final response = await http.post(
      Uri.parse(_baseUrl),
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
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Nie udało się dodać lekcji.');
    }
  }

  static Future<List<Lesson>> getLessons() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('Brak tokena uwierzytelniającego.');
    }

    final response = await http.get(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((lessonData) => Lesson.fromJson(lessonData)).toList();
    } else {
      throw Exception('Nie udało się pobrać lekcji.');
    }
  }
}
