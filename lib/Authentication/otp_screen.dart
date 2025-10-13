
// otp_screen.dart

import 'package:coffee_exult_app/Authentication/authenticationService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String verificationId;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
  });

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isLoading = false; // Added local loading state

  Future<void> _verifyOtp() async {
    String smsCode = _otpControllers
        .map((controller) => controller.text)
        .join();

    if (smsCode.length != 6) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text('Please enter a valid 6-digit code'),
      //     backgroundColor: Colors.red,
      //   ),
      // );
      showAppSnackBar(
        context,
        message: 'Please enter a valid 6-digit code',
        textColor: Colors.red,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref
          .read(authNotifierProvider.notifier)
          .signInWithPhoneNumber(widget.verificationId, smsCode);
      // ignore: use_build_context_synchronously
      context.go('/navbar');
    } catch (e) {
      setState(() => _isLoading = false);
      showAppSnackBar(
        // ignore: use_build_context_synchronously
        context,
        message: 'Error: ${e.toString()}',
        backgroundColor: Colors.white,
        textColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading =
        authState.isLoading || _isLoading;
     final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title:  Text('Enter OTP',
        style: textTheme.titleLarge?.copyWith(color: colorScheme.primaryContainer, fontWeight: FontWeight.w400,fontSize: 14),
        ),
        backgroundColor: colorScheme.surface,
      
      ),
      body: Stack(
        children:[
          Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'We’ve sent a 6-digit verification code to your number',
                style: textTheme.bodyMedium?.copyWith(color: colorScheme.primaryContainer),
              ),
              const SizedBox(height: 20),
              Text(
                ' ${widget.phoneNumber}',
                style: textTheme.bodySmall?.copyWith(color: colorScheme.secondary,),
              ),
              SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: colorScheme.shadow),
                      ),
                      child: TextField(
                        controller: _otpControllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        decoration: const InputDecoration(counterText: ''),
                        onChanged: (value) {
                          if (value.length == 1 && index < 5) {
                            FocusScope.of(
                              context,
                            ).requestFocus(_focusNodes[index + 1]);
                          } else if (value.isEmpty && index > 0) {
                            FocusScope.of(
                              context,
                            ).requestFocus(_focusNodes[index - 1]);
                          }
                          // Auto-verification when all digits are entered
                          if (value.isNotEmpty && index == 5) {
                            String fullCode = _otpControllers
                                .map((controller) => controller.text)
                                .join();
                            if (fullCode.length == 6) {
                              _verifyOtp();
                            }
                          }
                        },
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _verifyOtp,
                      child: const Text('Verify OTP'),
                    ),
            ],
          ),
        ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }
  void showAppSnackBar(
  BuildContext context, {
  required String message,
  Color backgroundColor = Colors.white,
  Color textColor = Colors.green,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w400,
        ),
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: textColor, width: 1.5),
      ),
      duration: const Duration(seconds: 2),
    ),
  );
}
}
