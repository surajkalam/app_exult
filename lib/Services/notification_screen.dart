import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
class NotificationService {
  static Future<void> initialize() async {
    // iOS / Web need explicit permission request
    if (Platform.isIOS) {
      NotificationSettings settings =
          await FirebaseMessaging.instance.requestPermission();

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        log("iOS Notifications authorized!");
      } else {
        log("iOS Notifications not authorized.");
      }
    }

    // Android: skip requestPermission(), just set up listeners
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   log("Foreground message: ${message.notification?.title}");
    // });
  }
}
//  <service
//             android:name=".java.MyFirebaseMessagingService"
//             android:exported="false">
//             <intent-filter>
//                 <action android:name="com.google.firebase.MESSAGING_EVENT"/>
//             </intent-filter>
//         </service>
