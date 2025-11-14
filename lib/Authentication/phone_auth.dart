import 'dart:developer';
import 'dart:math' hide log;

import 'package:coffee_exult_app/Authentication/authenticationService.dart';
import 'package:coffee_exult_app/Authentication/otp_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

class PhoneAuth extends ConsumerStatefulWidget {
  const PhoneAuth({super.key});

  @override
  ConsumerState<PhoneAuth> createState() => _PhoneAuthState();
}

class _PhoneAuthState extends ConsumerState<PhoneAuth> {
  TextEditingController countryController = TextEditingController();
  TextEditingController phoneNoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _verificationId;

  @override
  void initState() {
    super.initState();
    countryController.text = "+91";
  }

  // Helper method to format phone number to E.164
  String formatToE164(String countryCode, String phoneNumber) {
    // Remove all non-digit characters from phone number
    String cleanPhoneNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    // Remove + from country code and any non-digit characters
    String cleanCountryCode = countryCode.replaceAll(RegExp(r'[^\d]'), '');
    // Ensure country code starts with +
    String formattedNumber = '+$cleanCountryCode$cleanPhoneNumber';
    log('Original: $countryCode$phoneNumber -> Formatted: $formattedNumber');
    return formattedNumber;
  }

  // Validate E.164 format
  bool isValidE164(String phoneNumber) {
    // E.164 regex: + followed by 1-3 digits (country code) and 4-14 digits (subscriber number)
    final RegExp e164Regex = RegExp(r'^\+[1-9]\d{1,14}$');
    return e164Regex.hasMatch(phoneNumber);
  }

  // Validate Indian phone number specifically
  bool isValidIndianNumber(String phoneNumber) {
    // Indian mobile numbers: +91 followed by 10 digits starting with 6-9
    final RegExp indianMobileRegex = RegExp(r'^\+91[6-9]\d{9}$');
    return indianMobileRegex.hasMatch(phoneNumber);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          BubbleBackground(),
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Lottie.asset(
                  'assets/Icons/Robot_says_hello.json',
                  height: 300,
                  width: 300,
                ),
                Text(
                  "Phone Verification",
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.primaryContainer,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "We need to register your phone number before getting started",
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: colorScheme.shadow, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
                        // Country code textfield
                        SizedBox(
                          width: 50,
                          child: TextFormField(
                            keyboardType: TextInputType.phone,
                            controller: countryController,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.primaryContainer,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[+\d]'),
                              ), // Only + and digits
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (!value.startsWith('+')) {
                                return 'Must start with +';
                              }
                              if (value.length < 2 || value.length > 4) {
                                return 'Invalid country code';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        Text(
                          "|",
                          style: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.primaryContainer,
                          ),
                        ),
                        SizedBox(width: 10),
                        // Phone number textfield
                        Expanded(
                          child: TextFormField(
                            keyboardType: TextInputType.phone,
                            controller: phoneNoController,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.primaryContainer,
                            ),
                            cursorColor: colorScheme.primaryContainer,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Phone number is required';
                              }
                              if (value.length != 10) {
                                return 'Enter a valid 10-digit phone number';
                              }
                              // Check if it's a valid Indian mobile number (starts with 6-9)
                              if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
                                return 'Enter a valid Indian mobile number';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: "Enter 10-digit mobile number",
                              hintStyle: textTheme.bodySmall?.copyWith(
                                color: colorScheme.secondary,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Show formatted number preview
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    phoneNoController.text.isNotEmpty
                        ? 'Number will be: ${formatToE164(countryController.text, phoneNoController.text)}'
                        : 'Enter your phone number',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.secondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        style: ButtonStyle(
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          backgroundColor: const WidgetStatePropertyAll(
                            Colors.green,
                          ),
                          fixedSize: WidgetStatePropertyAll(
                            Size.fromWidth(MediaQuery.of(context).size.width),
                          ),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            // Format the phone number properly
                            String formattedPhoneNumber = formatToE164(
                              countryController.text,
                              phoneNoController.text,
                            );
                            // Validate E.164 format
                            if (!isValidE164(formattedPhoneNumber)) {
                              showAppSnackBar(
                                context,
                                message: 'Invalid phone number format',
                                textColor: Colors.red,
                              );
                              return;
                            }
                            // Additional validation for Indian numbers
                            if (countryController.text == '+91' &&
                                !isValidIndianNumber(formattedPhoneNumber)) {
                              showAppSnackBar(
                                context,
                                message:
                                    'Please enter a valid Indian mobile number (10 digits starting with 6-9)',
                                textColor: Colors.red,
                              );
                              return;
                            }
                            log('Sending OTP to: $formattedPhoneNumber');
                            try {
                              await ref
                                  .read(authNotifierProvider.notifier)
                                  .verifyPhoneNumber(
                                    formattedPhoneNumber, // Use properly formatted number
                                    onCodeSent: (verificationId) {
                                      setState(() {
                                        _verificationId = verificationId;
                                      });
                                      // Navigate to OTP screen after getting verificationId
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => OtpScreen(
                                            phoneNumber: formattedPhoneNumber,
                                            verificationId: verificationId,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                            } catch (e) {
                              showAppSnackBar(
                                // ignore: use_build_context_synchronously
                                context,
                                message: 'Error: ${e.toString()}',
                                backgroundColor: Colors.white,
                                textColor: Colors.red,
                              );
                              log('Error: $e');
                            }
                          }
                        },
                        child: Text(
                          "Send the code",
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSecondaryFixed,
                            fontSize: 12,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('_verificationId', _verificationId));
  }
}

// Bubble Background Widget
class BubbleBackground extends StatelessWidget {
  const BubbleBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: BubblePainter(), child: Container());
  }
}

class BubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final random = Random(42); // Fixed seed for consistent bubble positions

    // Generate bubbles
    for (int i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 80 + 20;
      final opacity = random.nextDouble() * 0.15 + 0.05;
      // ignore: deprecated_member_use
      paint.color = Color(0xFFC67C4E).withValues(alpha: opacity);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
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
        style: TextStyle(color: textColor, fontWeight: FontWeight.w400),
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
