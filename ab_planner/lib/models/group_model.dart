class GroupModel {
  final int id;
  final String startYear;
  final int groupNumber;
  final String groupName;

  GroupModel({
    required this.id,
    required this.startYear,
    required this.groupNumber,
    required this.groupName,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'],
      startYear: json['start_year'],
      groupNumber: json['group_number'],
      groupName: json['group_name'],
    );
  }
}
