class Role {
  final int id;
  final String code;
  final String label;

  Role({required this.id, required this.code, required this.label});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(id: json['id'], code: json['code'], label: json['label']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'code': code, 'label': label};
  }
}
