class ProgramYear {
  final int id;
  final int programId;
  final int year;

  ProgramYear({
    required this.id,
    required this.programId,
    required this.year,
  });

  factory ProgramYear.fromJson(Map<String, dynamic> json) {
    return ProgramYear(
      id: json['id'],
      programId: json['program_id'],
      year: json['year'],
    );
  }
}

class Specialization {
  final int id;
  final int programId;
  final String name;

  Specialization({
    required this.id,
    required this.programId,
    required this.name,
  });

  factory Specialization.fromJson(Map<String, dynamic> json) {
    return Specialization(
      id: json['id'],
      programId: json['program_id'],
      name: json['name'],
    );
  }
}

class ProgramModel {
  final int id;
  final String name;
  final List<ProgramYear> years;
  final List<Specialization> specializations;

  ProgramModel({
    required this.id,
    required this.name,
    required this.years,
    required this.specializations,
  });

  factory ProgramModel.fromJson(Map<String, dynamic> json) {
    return ProgramModel(
      id: json['id'],
      name: json['name'],
      years: (json['years'] as List?)
              ?.map((y) => ProgramYear.fromJson(y))
              .toList() ??
          [],
      specializations: (json['specializations'] as List?)
              ?.map((s) => Specialization.fromJson(s))
              .toList() ??
          [],
    );
  }
}
