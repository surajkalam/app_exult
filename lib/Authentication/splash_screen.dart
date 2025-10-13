import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';


class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Delay for 2 seconds then navigate to Home
    Future.delayed(const Duration(seconds: 5), () {
      // ignore: use_build_context_synchronously
      context.pushReplacement('/login-screen');
    });
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child:Lottie.asset('Assets/Icons/Robot_says_hello.json',
        height: 300,
        width: 300
        ),
      ),
    );
  }
}
