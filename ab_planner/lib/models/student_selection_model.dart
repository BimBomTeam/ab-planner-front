class StudentGroupSelection {
  final int id;
  final int userId;
  final int groupId;
  final DateTime selectedAt;

  StudentGroupSelection({
    required this.id,
    required this.userId,
    required this.groupId,
    required this.selectedAt,
  });

  factory StudentGroupSelection.fromJson(Map<String, dynamic> json) {
    return StudentGroupSelection(
      id: json['id'],
      userId: json['user_id'],
      groupId: json['group_id'],
      selectedAt: DateTime.parse(json['selected_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'group_id': groupId,
      'selected_at': selectedAt.toIso8601String(),
    };
  }
}

class CreateStudentGroupSelectionRequest {
  final int groupId;
  final int? userId; // Opcjonalne - backend może użyć zalogowanego usera

  CreateStudentGroupSelectionRequest({
    required this.groupId,
    this.userId,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'group_id': groupId,
    };
    if (userId != null) {
      json['user_id'] = userId;
    }
    return json;
  }
}
