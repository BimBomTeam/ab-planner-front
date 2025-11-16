import 'package:ab_planner/models/group_model.dart';

// Stary model - zachowany dla kompatybilności
class Lesson {
  final int id;
  final String room;
  final String title;
  final DateTime start;
  final DateTime end;
  final int teacherId;
  final int lessonTypeId;
  final int groupId;
  final String? frequency;
  final String? term;
  final DateTime createdAt;
  final DateTime updatedAt;

  // 🔽 Relacyjne dane
  final String? teacherName;
  final String? lessonTypeName;
  final String? groupName;
  final int? groupNumber;

  Lesson({
    required this.id,
    required this.room,
    required this.title,
    required this.start,
    required this.end,
    required this.teacherId,
    required this.lessonTypeId,
    required this.groupId,
    required this.createdAt,
    required this.updatedAt,
    this.frequency,
    this.term,
    this.teacherName,
    this.lessonTypeName,
    this.groupName,
    this.groupNumber,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'],
      room: json['room'] ?? '',
      title: json['title'] ?? '',
      start: DateTime.parse(json['start']),
      end: DateTime.parse(json['end']),
      teacherId: json['teacher_id'],
      lessonTypeId: json['lesson_type_id'],
      groupId: json['group_id'],
      frequency: json['frequency'] as String?,
      term: json['term'] as String?,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      teacherName: json['Teacher']?['name'],
      lessonTypeName: json['LessonType']?['name'],
      groupName: json['Group']?['group_name'],
      groupNumber: json['Group']?['group_number'],
    );
  }
}

// Nowe modele dla API v1
class Subject {
  final int id;
  final String name;
  final String code;

  Subject({
    required this.id,
    required this.name,
    required this.code,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'],
      name: json['name'],
      code: json['code'],
    );
  }
}

class Room {
  final int id;
  final String number;
  final String building;
  final int capacity;

  Room({
    required this.id,
    required this.number,
    required this.building,
    required this.capacity,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      number: json['number'],
      building: json['building'],
      capacity: json['capacity'],
    );
  }
}

class Lecturer {
  final int id;
  final String name;
  final String email;

  Lecturer({
    required this.id,
    required this.name,
    required this.email,
  });

  factory Lecturer.fromJson(Map<String, dynamic> json) {
    return Lecturer(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
}

class LessonV1 {
  final int id;
  final DateTime startsAt;
  final DateTime endsAt;
  final String status;
  final String lessonType;
  final Subject subject;
  final Room room;
  final Group group;
  final Lecturer lecturer;

  LessonV1({
    required this.id,
    required this.startsAt,
    required this.endsAt,
    required this.status,
    required this.lessonType,
    required this.subject,
    required this.room,
    required this.group,
    required this.lecturer,
  });

  factory LessonV1.fromJson(Map<String, dynamic> json) {
    return LessonV1(
      id: json['id'],
      startsAt: DateTime.parse(json['starts_at']),
      endsAt: DateTime.parse(json['ends_at']),
      status: json['status'],
      lessonType: json['lesson_type'],
      subject: Subject.fromJson(json['subject']),
      room: Room.fromJson(json['room']),
      group: Group.fromJson(json['group']),
      lecturer: Lecturer.fromJson(json['lecturer']),
    );
  }
}
