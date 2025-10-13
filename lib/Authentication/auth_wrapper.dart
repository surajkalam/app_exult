import 'dart:developer';


import 'package:coffee_exult_app/Authentication/phone_auth.dart';
import 'package:coffee_exult_app/core/widget/Navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Import your main app screen here

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    log('checking logged or not');
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking authentication
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // If user is logged in, show main app
        if (snapshot.hasData && snapshot.data != null) {
          // Replace this with your actual main app widget/navbar
          return MainAppere(); // You need to replace this
        }
        
        // If user is not logged in, show phone authentication
        return const PhoneAuth();
      },
    );
  }
}
