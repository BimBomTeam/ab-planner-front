class GroupModel {
  final int id;
  final String startYear;
  final int groupNumber;
  final String groupName;
  final int? majorId;
  final String? majorName;

  GroupModel({
    required this.id,
    required this.startYear,
    required this.groupNumber,
    required this.groupName,
    required this.majorId,
    this.majorName,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'],
      startYear: json['start_year'],
      groupNumber: json['group_number'],
      groupName: json['group_name'],
      majorId: json['major_id'],
      majorName: json['Major'] != null ? json['Major']['name'] : null,
    );
  }
}
