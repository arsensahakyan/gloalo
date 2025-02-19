// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class NotificationService {
//   final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

//   Future<void> init() async {
//     const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('app_icon');
//     final InitializationSettings settings = InitializationSettings(android: androidSettings);
//     await _notificationsPlugin.initialize(settings);
//   }

//   Future<void> showNotification({required String title, required String body}) async {
//     const AndroidNotificationDetails androidDetails = AndroidNotificationDetails('channelId', 'channelName');
//     final NotificationDetails details = NotificationDetails(android: androidDetails);
//     await _notificationsPlugin.show(0, title, body, details);
//   }
// }
