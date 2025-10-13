// import 'dart:developer';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// final authNotifierProvider = NotifierProvider<AuthNotifier, AsyncValue<User?>>(
//   AuthNotifier.new,
// );

// class AuthNotifier extends Notifier<AsyncValue<User?>> {
//   // ignore: unused_field
//   String? _verificationId;
//   // ignore: unused_field
//   String? _phoneNumber;

//   @override
//   AsyncValue<User?> build() {
//     return const AsyncValue.data(null);
//   }

//   Future<void> initialize() async {
//     FirebaseAuth.instance.authStateChanges().listen((user) {
//       log("🔄 Auth state changed → ${user?.phoneNumber ?? "No user"}");
//       state = AsyncValue.data(user);
//     });
//   }

//   // Email login
//   Future<void> signInWithEmailAndPassword(String email, String password) async {
//     state = const AsyncValue.loading();
//     try {
//       log("📩 Signing in with email: $email");
//       final userCredential = await FirebaseAuth.instance
//           .signInWithEmailAndPassword(email: email, password: password);
//       log("✅ Email login success → ${userCredential.user?.uid}");
//       state = AsyncValue.data(userCredential.user);
//     } catch (e, st) {
//       log("❌ Email login failed: $e");
//       state = AsyncValue.error(e, st);
//       rethrow;
//     }
//   }

//   // Email signup
//   Future<void> signUpWithEmailAndPassword(String email, String password) async {
//     state = const AsyncValue.loading();
//     try {
//       log("🆕 Signing up with email: $email");
//       final userCredential = await FirebaseAuth.instance
//           .createUserWithEmailAndPassword(email: email, password: password);
//       log("✅ Email signup success → ${userCredential.user?.uid}");
//       state = AsyncValue.data(userCredential.user);
//     } catch (e, st) {
//       log("❌ Email signup failed: $e");
//       state = AsyncValue.error(e, st);
//       rethrow;
//     }
//   }

//   // Phone authentication
//   Future<void> verifyPhoneNumber(String phoneNumber, {Function(String)? onCodeSent}) async {
//     state = const AsyncValue.loading();
//     try {
//       _phoneNumber = phoneNumber;
//       log("📲 Sending OTP to $phoneNumber");

//       await FirebaseAuth.instance.verifyPhoneNumber(
//         phoneNumber: phoneNumber,
//         timeout: const Duration(seconds: 60),

//         verificationCompleted: (PhoneAuthCredential credential) async {
//           log("✅ Auto verification completed");
//           try {
//             final userCred = await FirebaseAuth.instance.signInWithCredential(credential);
//             log("🔑 Auto login success → ${userCred.user?.phoneNumber}");
//             state = AsyncValue.data(userCred.user);
//           } catch (e) {
//             log("❌ Auto verification failed: $e");
//             state = const AsyncValue.data(null);
//           }
//         },

//         verificationFailed: (FirebaseAuthException e) {
//           log("❌ Verification failed: ${e.code} - ${e.message}");
//           state = AsyncValue.error(e, StackTrace.current);
//         },

//         codeSent: (String verificationId, int? resendToken) {
//           _verificationId = verificationId;
//           log("📨 Code sent! verificationId saved.");
//           if (onCodeSent != null) {
//             onCodeSent(verificationId);
//           }
//           state = const AsyncValue.data(null); // reset to idle so UI allows OTP entry
//         },

//         codeAutoRetrievalTimeout: (String verificationId) {
//           _verificationId = verificationId;
//           log("⏳ Auto retrieval timeout");
//         },
//       );
//     } catch (e, st) {
//       log("❌ verifyPhoneNumber error: $e");
//       state = AsyncValue.error(e, st);
//       rethrow;
//     }
//   }

//   // Verify OTP
//   Future<void> signInWithPhoneNumber(String verificationId, String smsCode) async {
//     state = const AsyncValue.loading();
//     try {
//       log("🔑 Verifying OTP with verificationId: $verificationId and smsCode: $smsCode");

//       final credential = PhoneAuthProvider.credential(
//         verificationId: verificationId,
//         smsCode: smsCode,
//       );

//       final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
//       log("✅ Phone login success → ${userCredential.user?.phoneNumber}");
//       state = AsyncValue.data(userCredential.user);
//     } on FirebaseAuthException catch (e, st) {
//       log("❌ OTP verification failed: ${e.code} - ${e.message}");
//       state = AsyncValue.error(e, st);
//       rethrow;
//     }
//   }

//   // Sign out
//   Future<void> signOut() async {
//     log("🚪 Signing out user: ${FirebaseAuth.instance.currentUser?.phoneNumber}");
//     await FirebaseAuth.instance.signOut();
//     state = const AsyncValue.data(null);
//   }
// }
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authNotifierProvider = NotifierProvider<AuthNotifier, AsyncValue<User?>>(
  AuthNotifier.new,
);

class AuthNotifier extends Notifier<AsyncValue<User?>> {
  String? _verificationId;
  String? _phoneNumber;

  @override
  AsyncValue<User?> build() {
    // Check if user is already logged in when the notifier is built
    final currentUser = FirebaseAuth.instance.currentUser;
    log("🔄 Building AuthNotifier → Current user: ${currentUser?.phoneNumber ?? "No user"}");
    
    // Start listening to auth state changes
    _initializeAuthStateListener();
    
    // Return current user state
    return AsyncValue.data(currentUser);
  }

  void _initializeAuthStateListener() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      log("🔄 Auth state changed → ${user?.phoneNumber ?? "No user"}");
      state = AsyncValue.data(user);
    });
  }

  // Keep your existing initialize method for backward compatibility
  Future<void> initialize() async {
    // This method is now optional since auth state is handled in build()
    log("📱 Initialize called - auth state already being monitored");
  }

  // Check if user is currently logged in
  bool get isLoggedIn => FirebaseAuth.instance.currentUser != null;

  // Get current user
  User? get currentUser => FirebaseAuth.instance.currentUser;

  // Email login
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      log("📩 Signing in with email: $email");
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      log("✅ Email login success → ${userCredential.user?.uid}");
      state = AsyncValue.data(userCredential.user);
    } catch (e, st) {
      log("❌ Email login failed: $e");
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  // Email signup
  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      log("🆕 Signing up with email: $email");
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      log("✅ Email signup success → ${userCredential.user?.uid}");
      state = AsyncValue.data(userCredential.user);
    } catch (e, st) {
      log("❌ Email signup failed: $e");
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  // Phone authentication
  Future<void> verifyPhoneNumber(String phoneNumber, {Function(String)? onCodeSent}) async {
    state = const AsyncValue.loading();
    try {
      _phoneNumber = phoneNumber;
      log("📲 Sending OTP to $phoneNumber");

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),

        verificationCompleted: (PhoneAuthCredential credential) async {
          log("✅ Auto verification completed");
          try {
            final userCred = await FirebaseAuth.instance.signInWithCredential(credential);
            log("🔑 Auto login success → ${userCred.user?.phoneNumber}");
            state = AsyncValue.data(userCred.user);
          } catch (e) {
            log("❌ Auto verification failed: $e");
            state = const AsyncValue.data(null);
          }
        },

        verificationFailed: (FirebaseAuthException e) {
          log("❌ Verification failed: ${e.code} - ${e.message}");
          state = AsyncValue.error(e, StackTrace.current);
        },

        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          log("📨 Code sent! verificationId saved.");
          if (onCodeSent != null) {
            onCodeSent(verificationId);
          }
          state = const AsyncValue.data(null); // reset to idle so UI allows OTP entry
        },

        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
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
  Future<void> signInWithPhoneNumber(String verificationId, String smsCode) async {
    state = const AsyncValue.loading();
    try {
      log("🔑 Verifying OTP with verificationId: $verificationId and smsCode: $smsCode");

      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      log("✅ Phone login success → ${userCredential.user?.phoneNumber}");
      state = AsyncValue.data(userCredential.user);
    } on FirebaseAuthException catch (e, st) {
      log("❌ OTP verification failed: ${e.code} - ${e.message}");
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    log("🚪 Signing out user: ${FirebaseAuth.instance.currentUser?.phoneNumber}");
    await FirebaseAuth.instance.signOut();
    state = const AsyncValue.data(null);
  }
}