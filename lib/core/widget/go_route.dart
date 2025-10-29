import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exult_admin/core/provider/auth_provider.dart';
import 'package:exult_admin/core/widget/login_page.dart';
import 'package:exult_admin/core/widget/signup_page.dart';
import 'package:exult_admin/firebasestoredata/Screens/widget/admin_pannel.dart';
import 'package:exult_admin/firebasestoredata/Screens/Screens.dart';

// Create a provider for the router
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login';
      final isSigningUp = state.matchedLocation == '/signup';

      // If not authenticated and not on login/signup page, redirect to login
      if (!isAuthenticated && !isLoggingIn && !isSigningUp) {
        return '/login';
      }

      // If authenticated and on login/signup page, redirect to home
      if (isAuthenticated && (isLoggingIn || isSigningUp)) {
        return '/';
      }

      return null; // No redirect needed
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const AdminPanel(),
      ),
      GoRoute(
        path: '/Newarraivles',
        builder: (context, state) => const NewArrivals(),
      ),
      GoRoute(
        path: '/sessional-items',
        builder: (context, state) => const Sessionalitems(),
      ),
      GoRoute(
        path: '/voucher-data',
        builder: (context, state) => const VoucherdataStoreScreen(),
      ),
      GoRoute(
        path: '/offer-data',
        builder: (context, state) => const OfferdataStoreScreen(),
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Error: ${state.error}'))),
  );
});

// Keep the old approuter for backward compatibility but make it use the provider
// This will be initialized in main.dart
late final GoRouter approuter;
