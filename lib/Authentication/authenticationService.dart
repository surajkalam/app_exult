import 'dart:async';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Auth notifier provider for user state
final authNotifierProvider = NotifierProvider<AuthNotifier, AsyncValue<User?>>(
  AuthNotifier.new,
);

class AuthNotifier extends Notifier<AsyncValue<User?>> {
  // ignore: non_constant_identifier_names
  String? VerificationId;
  StreamSubscription<User?>? _authSubscription;

  @override
  AsyncValue<User?> build() {
    // Set up auth listener only once
    _setupAuthListener();

    // Return current user state
    final currentUser = FirebaseAuth.instance.currentUser;
    return AsyncValue.data(currentUser);
  }

  void _setupAuthListener() {
    // Cancel existing subscription to avoid duplicates
    _authSubscription?.cancel();

    _authSubscription = FirebaseAuth.instance.authStateChanges().listen(
      (user) {
        log("🔄 Auth state changed → ${user?.phoneNumber ?? "No user"}");

        // Only update state if it's different from current state
        if (state.value != user) {
          state = AsyncValue.data(user);
        }
      },
      onError: (error, stackTrace) {
        log("❌ Auth state error: $error");
        state = AsyncValue.error(error, stackTrace);
      },
    );

    ref.onDispose(() {
      _authSubscription?.cancel();
    });
  }

  // Phone authentication
  Future<void> verifyPhoneNumber(
    String phoneNumber, {
    Function(String)? onCodeSent,
  }) async {
    state = const AsyncValue.loading();
    try {
      log("📲 Sending OTP to $phoneNumber");

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),

        verificationCompleted: (PhoneAuthCredential credential) async {
          log("✅ Auto verification completed");
          try {
            final userCred = await FirebaseAuth.instance.signInWithCredential(
              credential,
            );
            log("🔑 Auto login success → ${userCred.user?.phoneNumber}");
          } catch (e) {
            log("❌ Auto verification failed: $e");
            state = AsyncValue.error(e, StackTrace.current);
          }
        },

        verificationFailed: (FirebaseAuthException e) {
          log("❌ Verification failed: ${e.code} - ${e.message}");
          state = AsyncValue.error(e, StackTrace.current);
        },

        codeSent: (String verificationId, int? resendToken) {
          VerificationId = verificationId;
          log("📨 Code sent! verificationId saved.");

          // Update state to not loading so OTP screen can be shown
          state = const AsyncValue.data(null);

          if (onCodeSent != null) {
            onCodeSent(verificationId);
          }
        },

        codeAutoRetrievalTimeout: (String verificationId) {
          VerificationId = verificationId;
          log("⏳ Auto retrieval timeout");
        },
      );
    } catch (e, st) {
      log("❌ verifyPhoneNumber error: $e");
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  // Verify OTP
  Future<void> signInWithPhoneNumber(
    String verificationId,
    String smsCode,
  ) async {
    state = const AsyncValue.loading();
    try {
      log("🔑 Verifying OTP...");

      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      log("✅ Phone login success → ${userCredential.user?.phoneNumber}");
    } on FirebaseAuthException catch (e, st) {
      log("❌ OTP verification failed: ${e.code} - ${e.message}");
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    log(
      "🚪 Signing out user: ${FirebaseAuth.instance.currentUser?.phoneNumber}",
    );
    await FirebaseAuth.instance.signOut();
  }
}
