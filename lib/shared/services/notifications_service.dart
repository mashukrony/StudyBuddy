import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:intl/intl.dart';

class NotificationService {
  static final _messaging = FirebaseMessaging.instance;
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOSSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );
    
    await _notifications.initialize(settings);
    await _requestPermissions();
  }

  static Future<void> _requestPermissions() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    
    // Additional permission request for Android 13+
    // No need to call requestPermission() for AndroidFlutterLocalNotificationsPlugin as it does not exist.
    // Permissions for notifications on Android 13+ should be handled via the firebase_messaging package or platform-specific code if needed.
    // See: https://pub.dev/packages/flutter_local_notifications/versions/13.0.0#android-13-behavior
  }

  static Future<void> scheduleNotification(
    DateTime dueDate,
    String title,
    String taskId,
  ) async {
    await _notifications.zonedSchedule(
      taskId.hashCode,
      'Task Reminder: $title',
      'Due at ${DateFormat('hh:mm a').format(dueDate)}',
      tz.TZDateTime.from(dueDate.subtract(const Duration(hours: 1)), tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_channel',
          'Task Reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      // androidAllowWhileIdle: true,  // Removed as it's not defined in the current version
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,  // Added for better scheduling
     
    );
  }

  static Future<void> cancelNotification(String taskId) async {
    await _notifications.cancel(taskId.hashCode);
  }
}