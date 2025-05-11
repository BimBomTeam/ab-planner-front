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
      frequency: json['frequency'],
      term: json['term'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      teacherName: json['Teacher']?['name'],
      lessonTypeName: json['LessonType']?['name'],
      groupName: json['Group']?['group_name'],
      groupNumber: json['Group']?['group_number'],
    );
  }
}
