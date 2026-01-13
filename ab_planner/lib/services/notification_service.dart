import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ab_planner/models/notification_model.dart';

class NotificationService {
  // Using the new IP address as per previous task
  static const String _baseUrl = 'http://130.61.233.185:8000/api/v1';

  static Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) throw Exception('Brak tokena uwierzytelniającego.');
    return token;
  }

  /// Fetch notifications with optional filters
  static Future<List<Notification>> fetchNotifications({
    int? userId,
    String? deliveryStatus,
    String? readStatus,
  }) async {
    final token = await _getToken();
    final queryParams = <String, String>{};

    if (userId != null) queryParams['user_id'] = userId.toString();
    if (deliveryStatus != null) queryParams['delivery_status'] = deliveryStatus;
    if (readStatus != null) queryParams['read_status'] = readStatus;

    final url = Uri.parse(
      '$_baseUrl/notifications',
    ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    debugPrint('🔔 Fetching notifications from: $url');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      debugPrint('🔔 Notifications response: ${response.body}');
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Notification.fromJson(json)).toList();
    } else {
      debugPrint('❌ Error fetching notifications: ${response.body}');
      throw Exception('Failed to load notifications');
    }
  }

  /// Mark notification as read
  static Future<Notification> markAsRead(int notificationId) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/notifications/$notificationId');

    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'read': true, 'read_status': 'read'}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Notification.fromJson(data);
    } else {
      debugPrint('❌ Error marking notification as read: ${response.body}');
      throw Exception('Failed to mark notification as read');
    }
  }

  /// Mark notification as unread (optional utility)
  static Future<Notification> markAsUnread(int notificationId) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/notifications/$notificationId');

    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'read': false, 'read_status': 'unread'}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Notification.fromJson(data);
    } else {
      throw Exception('Failed to mark notification as unread');
    }
  }

  /// Register FCM token with backend
  static Future<void> registerFcmToken(String token) async {
    final authToken = await _getToken();
    final url = Uri.parse('$_baseUrl/fcm-tokens');

    debugPrint('🔥 Registering FCM token: $token');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'token': token,
        'platform': defaultTargetPlatform.name.toLowerCase(),
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      debugPrint('✅ FCM token registered successfully');
    } else {
      debugPrint('❌ Failed to register FCM token: ${response.body}');
    }
  }
}
