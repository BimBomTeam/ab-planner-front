import 'package:flutter/material.dart';
import 'package:ab_planner/models/notification_model.dart' as model;
import 'package:ab_planner/services/notification_service.dart';
import 'package:ab_planner/services/user_service.dart';
import 'package:ab_planner/widgets/notification_tile.dart';

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  bool _isLoading = true;
  List<model.Notification> _notifications = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = await UserService.fetchCurrentUser();
      final notifications = await NotificationService.fetchNotifications(
        userId: user.id,
      );

      // Sort by created at desc
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(model.Notification notification) async {
    if (notification.isRead) return;

    try {
      await NotificationService.markAsRead(notification.id);

      setState(() {
        final index = _notifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          // Update the local list with a new instance that is read
          // Since models are effectively immutable, we create a new one but readStatus is final.
          // We need to re-fetch or hack it.
          // Since we can't easily copyWith without implementing it,
          // let's just re-fetch or assume success and manually update if we had copyWith.
          // For now, let's just reload the list or modify the backend first then reload.
          // Better UX: Optimistic update?
          // Let's just reload for simplicity or find a way to update local state.
          // Since I didn't verify copyWith, I'll reload list for now to be safe.
        }
      });
      await _loadNotifications(); // Reload to get fresh state
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Błąd: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Powiadomienia'),
        backgroundColor: const Color(0xFF1A1F38),
        foregroundColor: Colors.white,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Wystąpił błąd: $_error'),
                    ElevatedButton(
                      onPressed: _loadNotifications,
                      child: const Text('Spróbuj ponownie'),
                    ),
                  ],
                ),
              )
              : _notifications.isEmpty
              ? const Center(child: Text('Brak powiadomień'))
              : RefreshIndicator(
                onRefresh: _loadNotifications,
                child: ListView.builder(
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    return NotificationTile(
                      notification: notification,
                      onTap: () => _markAsRead(notification),
                    );
                  },
                ),
              ),
    );
  }
}
