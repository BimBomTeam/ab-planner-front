// Stary model - zachowany dla kompatybilności
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

// Nowe modele dla API v1
class GroupType {
  final String code;
  final String label;

  GroupType({
    required this.code,
    required this.label,
  });

  factory GroupType.fromJson(Map<String, dynamic> json) {
    return GroupType(
      code: json['code'],
      label: json['label'],
    );
  }
}

class ProgramInfo {
  final int id;
  final String name;

  ProgramInfo({
    required this.id,
    required this.name,
  });

  factory ProgramInfo.fromJson(Map<String, dynamic> json) {
    return ProgramInfo(
      id: json['id'],
      name: json['name'],
    );
  }
}

class YearInfo {
  final int id;
  final int programId;
  final int year;

  YearInfo({
    required this.id,
    required this.programId,
    required this.year,
  });

  factory YearInfo.fromJson(Map<String, dynamic> json) {
    return YearInfo(
      id: json['id'],
      programId: json['program_id'],
      year: json['year'],
    );
  }
}

class SpecializationInfo {
  final int id;
  final int programId;
  final String name;

  SpecializationInfo({
    required this.id,
    required this.programId,
    required this.name,
  });

  factory SpecializationInfo.fromJson(Map<String, dynamic> json) {
    return SpecializationInfo(
      id: json['id'],
      programId: json['program_id'],
      name: json['name'],
    );
  }
}

class Group {
  final int id;
  final String code;
  final ProgramInfo program;
  final YearInfo year;
  final SpecializationInfo specialization;
  final GroupType groupType;

  Group({
    required this.id,
    required this.code,
    required this.program,
    required this.year,
    required this.specialization,
    required this.groupType,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      code: json['code'],
      program: ProgramInfo.fromJson(json['program']),
      year: YearInfo.fromJson(json['year']),
      specialization: SpecializationInfo.fromJson(json['specialization']),
      groupType: GroupType.fromJson(json['group_type']),
    );
  }
}
