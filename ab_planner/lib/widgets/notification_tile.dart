import 'package:flutter/material.dart';
import 'package:ab_planner/models/notification_model.dart' as model;
import 'package:intl/intl.dart';

class NotificationTile extends StatelessWidget {
  final model.Notification notification;
  final VoidCallback onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRead = notification.isRead;

    // Extract info from payload
    // Adjust keys based on actual backend payload structure
    // Assuming 'title' and 'body' or similar
    final title = notification.payload['title'] ?? 'Powiadomienie';
    final body =
        notification.payload['body'] ??
        notification.payload['message'] ??
        'Brak treści';

    final dateFormat = DateFormat('dd.MM HH:mm');

    return Card(
      color:
          isRead
              ? const Color(0xFF1F1F35).withOpacity(0.8)
              : const Color(0xFF2A2A40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isRead ? Colors.transparent : const Color(0xFF3A0CA3),
          width: 1,
        ),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 4,
      shadowColor: Colors.black45,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isRead ? Colors.white10 : const Color(0xFF3A0CA3),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isRead ? Icons.notifications_none : Icons.notifications,
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(
              body,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.white38),
                const SizedBox(width: 4),
                Text(
                  dateFormat.format(notification.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing:
            !isRead
                ? Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFF3A0CA3),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x663A0CA3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                )
                : null,
      ),
    );
  }
}
