import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ab_planner/models/lesson.dart';

class LessonService {
  static const String _baseUrl = 'http://193.122.12.41:8000/api/v1/lessons';
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
    // MOCK DATA - zamiast prawdziwego API
    print('🔵 MOCK: Zwracam zmockowane dane zamiast prawdziwego API');
    print('🔵 Parametry: group_id=$groupId, date_from=$dateFrom, date_to=$dateTo');
    
    await Future.delayed(const Duration(milliseconds: 500)); // Symulacja opóźnienia sieci
    
    // Generuj lekcje dla całego tygodnia 17-21.11.2025
    final List<Map<String, dynamic>> mockData = [];
    
    // Definiujemy zajęcia dla każdego dnia tygodnia
    final subjects = [
      {"id": 1, "name": "Algorytmy i struktury danych", "code": "ASD"},
      {"id": 2, "name": "Programowanie obiektowe", "code": "POB"},
      {"id": 3, "name": "Bazy danych", "code": "BD"},
      {"id": 4, "name": "Sztuczna inteligencja", "code": "AI"},
      {"id": 5, "name": "Systemy operacyjne", "code": "SO"},
      {"id": 6, "name": "Sieci komputerowe", "code": "SK"},
      {"id": 7, "name": "Inżynieria oprogramowania", "code": "IO"},
    ];
    
    final lecturers = [
      {"id": 1, "name": "Dr. Jan Kowalski", "email": "jan.kowalski@example.edu"},
      {"id": 2, "name": "Dr. Anna Nowak", "email": "anna.nowak@example.edu"},
      {"id": 3, "name": "Prof. Piotr Wiśniewski", "email": "piotr.wisniewski@example.edu"},
      {"id": 4, "name": "Dr. Maria Lewandowska", "email": "maria.lewandowska@example.edu"},
      {"id": 5, "name": "Dr. Tomasz Kaczmarek", "email": "tomasz.kaczmarek@example.edu"},
    ];
    
    int lessonId = 1;
    
    // Tydzień: 17-21 listopada 2025 (poniedziałek-piątek)
    for (int dayOffset = 0; dayOffset < 5; dayOffset++) {
      final day = DateTime(2025, 11, 17 + dayOffset);
      
      // Poniedziałek (17.11)
      if (dayOffset == 0) {
        mockData.add(_createLesson(lessonId++, day, 8, 0, 10, 0, subjects[0], "lecture", "A", "101", lecturers[0]));
        mockData.add(_createLesson(lessonId++, day, 10, 15, 12, 0, subjects[1], "lab", "B", "205", lecturers[1]));
        mockData.add(_createLesson(lessonId++, day, 13, 0, 15, 0, subjects[2], "lecture", "C", "301", lecturers[2]));
      }
      // Wtorek (18.11)
      else if (dayOffset == 1) {
        mockData.add(_createLesson(lessonId++, day, 8, 0, 9, 45, subjects[3], "lecture", "A", "102", lecturers[3]));
        mockData.add(_createLesson(lessonId++, day, 10, 0, 12, 0, subjects[3], "lab", "D", "110", lecturers[3]));
        mockData.add(_createLesson(lessonId++, day, 12, 30, 14, 15, subjects[4], "lecture", "A", "101", lecturers[4]));
        mockData.add(_createLesson(lessonId++, day, 14, 30, 16, 0, subjects[1], "lab", "B", "206", lecturers[1]));
      }
      // Środa (19.11)
      else if (dayOffset == 2) {
        mockData.add(_createLesson(lessonId++, day, 8, 0, 10, 0, subjects[5], "lecture", "C", "302", lecturers[0]));
        mockData.add(_createLesson(lessonId++, day, 10, 15, 12, 0, subjects[5], "lab", "E", "115", lecturers[0]));
        mockData.add(_createLesson(lessonId++, day, 13, 0, 14, 45, subjects[6], "lecture", "A", "103", lecturers[2]));
      }
      // Czwartek (20.11)
      else if (dayOffset == 3) {
        mockData.add(_createLesson(lessonId++, day, 8, 0, 9, 45, subjects[2], "lab", "B", "207", lecturers[2]));
        mockData.add(_createLesson(lessonId++, day, 10, 0, 12, 0, subjects[4], "lab", "D", "111", lecturers[4]));
        mockData.add(_createLesson(lessonId++, day, 12, 30, 14, 15, subjects[0], "lab", "B", "208", lecturers[0]));
        mockData.add(_createLesson(lessonId++, day, 14, 30, 16, 0, subjects[6], "lab", "E", "116", lecturers[2]));
      }
      // Piątek (21.11)
      else if (dayOffset == 4) {
        mockData.add(_createLesson(lessonId++, day, 8, 0, 10, 0, subjects[1], "lecture", "A", "104", lecturers[1]));
        mockData.add(_createLesson(lessonId++, day, 10, 15, 12, 0, subjects[3], "lab", "D", "112", lecturers[3]));
        mockData.add(_createLesson(lessonId++, day, 13, 0, 14, 45, subjects[5], "lab", "E", "117", lecturers[0]));
      }
    }
    
    // Filtruj dane według wybranej daty
    final filteredData = mockData.where((lesson) {
      final lessonDate = DateTime.parse(lesson['starts_at']);
      if (dateFrom != null && dateTo != null) {
        return lessonDate.isAfter(dateFrom.subtract(const Duration(seconds: 1))) &&
               lessonDate.isBefore(dateTo.add(const Duration(seconds: 1)));
      }
      return true;
    }).toList();
    
    print('🟢 MOCK: Zwracam ${filteredData.length} lekcji dla wybranej daty');
    return filteredData.map((lessonJson) => LessonV1.fromJson(lessonJson)).toList();
  }
  
  static Map<String, dynamic> _createLesson(
    int id,
    DateTime day,
    int startHour,
    int startMinute,
    int endHour,
    int endMinute,
    Map<String, dynamic> subject,
    String lessonType,
    String building,
    String roomNumber,
    Map<String, dynamic> lecturer,
  ) {
    final startTime = DateTime(day.year, day.month, day.day, startHour, startMinute);
    final endTime = DateTime(day.year, day.month, day.day, endHour, endMinute);
    
    return {
      "id": id,
      "starts_at": startTime.toUtc().toIso8601String(),
      "ends_at": endTime.toUtc().toIso8601String(),
      "status": "scheduled",
      "lesson_type": lessonType,
      "subject": subject,
      "room": {
        "id": id,
        "number": roomNumber,
        "building": building,
        "capacity": lessonType == "lecture" ? 100 : 30
      },
      "group": {
        "id": 1,
        "code": "CS-AI-1${lessonType == 'lecture' ? 'L' : 'LAB'}",
        "program": {
          "id": 1,
          "name": "Computer Science"
        },
        "year": {
          "id": 1,
          "program_id": 1,
          "year": 2025
        },
        "specialization": {
          "id": 1,
          "program_id": 1,
          "name": "AI Engineering"
        },
        "group_type": {
          "code": lessonType,
          "label": lessonType == "lecture" ? "Lecture" : "Laboratory"
        }
      },
      "lecturer": lecturer
    };
  }

  // === STARE FUNKCJE - ZACHOWANE DLA KOMPATYBILNOŚCI ===

  // === STARE FUNKCJE - ZACHOWANE DLA KOMPATYBILNOŚCI ===

  /// 🧠 Pobiera group_id z /api/users/me -> Group.id (DEPRECATED)
  static Future<int> getUserGroupId() async {
    if (_cachedGroupId != null) return _cachedGroupId!;

    final token = await _getToken();

    final response = await http.get(
      Uri.parse('http://193.122.12.41:3000/api/users/me'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  
    if (response.statusCode == 200) {
      print(response.body);
      final data = jsonDecode(response.body);
      if (data != null && data['Group'] != null && data['Group']['id'] != null) {
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
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((lessonData) => Lesson.fromJson(lessonData)).toList();
    } else {
      final data = jsonDecode(response.body);
      final message = data['message'] ?? data['error'] ?? 'Nie udało się pobrać lekcji na dany dzień.';
      throw Exception(message);
    }
  }

  /// 📥 Pobiera wszystkie lekcje (DEPRECATED)
  static Future<List<Lesson>> getLessons() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse(_oldBaseUrl),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((lessonData) => Lesson.fromJson(lessonData)).toList();
    } else {
      final data = jsonDecode(response.body);
      final message = data['message'] ?? data['error'] ?? 'Nie udało się pobrać lekcji.';
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
      final message = data['message'] ?? data['error'] ?? 'Nie udało się dodać lekcji.';
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
      final message = data['message'] ?? data['error'] ?? 'Nie udało się zaktualizować lekcji.';
      throw Exception(message);
    }
  }
}
