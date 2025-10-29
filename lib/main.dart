// import 'package:flutter/material.dart';

// void main() {
//   runApp(const MainApp());
// }

// class MainApp extends StatelessWidget {
//   const MainApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: Scaffold(
//         body: Center(
//           child: Text('Hello World!'),
//         ),
//       ),
//     );
//   }
// }

// ignore: depend_on_referenced_packages
import 'dart:developer';

import 'package:exult_admin/Services/notification_screen.dart';
import 'package:exult_admin/core/utils/material_theme.dart';
import 'package:exult_admin/core/utils/typography.dart';
import 'package:exult_admin/core/widget/go_route.dart';
import 'package:exult_admin/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    log('Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    log('Firebase initialized successfully');
    // firebaseAppCheck.installAppCheckProviderFactory(PlayIntegrityAppCheckProviderFactory.getInstance());
  } catch (e, stack) {
    log('Firebase initialization failed', error: e, stackTrace: stack);
    rethrow;
  }
  _setupLogging();
  await NotificationService.initialize();
  log("NotificationService.initialize finished");
  debugPrint = (String? message, {int? wrapWidth}) {};
  runApp(ProviderScope(child: MainApp()));
}

void _setupLogging() {
  log('Setting up logging filters...');
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final materialTheme = MaterialTheme(textTheme);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: materialTheme.light(),
      darkTheme: materialTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
