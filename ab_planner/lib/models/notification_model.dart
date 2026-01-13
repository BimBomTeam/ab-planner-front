class Notification {
  final int id;
  final int userId;
  final Map<String, dynamic> payload;
  final String deliveryStatus;
  final String readStatus;
  final DateTime? readAt;
  final String? lastError;
  final int attempts;
  final DateTime createdAt;
  final DateTime? lastAttemptAt;
  final DateTime? sentAt;

  Notification({
    required this.id,
    required this.userId,
    required this.payload,
    required this.deliveryStatus,
    required this.readStatus,
    this.readAt,
    this.lastError,
    required this.attempts,
    required this.createdAt,
    this.lastAttemptAt,
    this.sentAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      userId: json['user_id'],
      payload: json['payload'] as Map<String, dynamic>,
      deliveryStatus: json['delivery_status'],
      readStatus: json['read_status'],
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      lastError: json['last_error'],
      attempts: json['attempts'],
      createdAt: DateTime.parse(json['created_at']),
      lastAttemptAt:
          json['last_attempt_at'] != null
              ? DateTime.parse(json['last_attempt_at'])
              : null,
      sentAt: json['sent_at'] != null ? DateTime.parse(json['sent_at']) : null,
    );
  }

  bool get isRead => readStatus == 'read';
}
