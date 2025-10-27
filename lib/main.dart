import 'dart:developer';

import 'package:coffee_exult_app/Services/notification_screen.dart';
import 'package:coffee_exult_app/core/utils/material_theme.dart';
import 'package:coffee_exult_app/core/utils/typography.dart';
import 'package:coffee_exult_app/core/widget/go_route.dart';
import 'package:coffee_exult_app/firebase_options.dart';
// ignore: depend_on_referenced_packages
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
  // await FirebaseAppCheck.instance.activate(
  //   androidProvider: AndroidProvider.debug,
  //   webProvider: ReCaptchaV3Provider('6LdxOMErAAAAAH6WkDCHztkWBmB0DocRPoZX3E1G'),
  //   appleProvider: AppleProvider.appAttest,
  // );
  debugPrint = (String? message, {int? wrapWidth}) {};
  runApp(ProviderScope(child: MainApp()));
}

void _setupLogging() {
  log('Setting up logging filters...');
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    final materialTheme = MaterialTheme(textTheme);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: materialTheme.light(),
      darkTheme: materialTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: approuter,
    );
  }
}