class Notification {
  final int id;
  final int userId;
  final Map<String, dynamic> payload;
  final String status;
  final int attempts;
  final DateTime createdAt;
  final DateTime? sentAt;

  Notification({
    required this.id,
    required this.userId,
    required this.payload,
    required this.status,
    required this.attempts,
    required this.createdAt,
    this.sentAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      userId: json['user_id'],
      payload: json['payload'] as Map<String, dynamic>,
      status: json['status'],
      attempts: json['attempts'],
      createdAt: DateTime.parse(json['created_at']),
      sentAt: json['sent_at'] != null ? DateTime.parse(json['sent_at']) : null,
    );
  }
}
