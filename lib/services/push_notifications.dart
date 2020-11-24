import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mess_meal/screens/notification_screen.dart';

class PushNotifications {
  static final FirebaseMessaging _fcm = FirebaseMessaging();
  static GlobalKey<NavigatorState> _navigatorKey;

  static Future<void> init(GlobalKey<NavigatorState> key) async {
    if (_navigatorKey != null) return;
    _navigatorKey = key;

    if (Platform.isIOS) {
      // request permissions if we're on android
      _fcm.requestNotificationPermissions(IosNotificationSettings());
    }

    _fcm.configure(
      // Called when the app is in the foreground and we receive a push notification
      onMessage: (Map<String, dynamic> message) async {
        print('onMessage: $message');
        loadNotificationScreen(message);
      },
      // Called when the app has been closed comlpetely and it's opened
      // from the push notification.
      onLaunch: (Map<String, dynamic> message) async {
        print('onLaunch: $message');
        loadNotificationScreen(message);
      },
      // Called when the app is in the background and it's opened
      // from the push notification.
      onResume: (Map<String, dynamic> message) async {
        print('onResume: $message');
        loadNotificationScreen(message);
      },
    );
  }

  static void loadNotificationScreen(Map<String, dynamic> message) {
    Navigator.of(_navigatorKey.currentContext).push(
      MaterialPageRoute(
        builder: (context) => NotificationScreen(
          message: Map<String, dynamic>.from(message['data']),
        ),
      ),
    );
  }
}
