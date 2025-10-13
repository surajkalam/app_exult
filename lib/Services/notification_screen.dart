import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';

// Future<void> backgroundHandler(RemoteMessage message) async {
//   log("Background message received! ${message.messageId}");
// }

// class NotificationService {
//   static Future<void> initialize() async {
//     NotificationSettings settings =
//         await FirebaseMessaging.instance.requestPermission();

//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       log("Notifications authorized!");

//       // Background messages
//       FirebaseMessaging.onBackgroundMessage(backgroundHandler);

//       // Foreground messages
//       FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//         log("Foreground message received! ${message.notification?.title}");
//       });
//     } else {
//       log("Notifications not authorized.");
//     }
//   }
// }
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
