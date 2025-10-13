import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class PhoneOTPVerification extends StatefulWidget {
  const PhoneOTPVerification({super.key});

  @override
  State<PhoneOTPVerification> createState() => _PhoneOTPVerificationState();
}

class _PhoneOTPVerificationState extends State<PhoneOTPVerification> {
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController otp = TextEditingController();
  bool visible = false;
  String? verificationId;
  bool isLoading = false;

  @override
  void dispose() {
    phoneNumber.dispose();
    otp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Firebase Phone OTP Authentication")),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            inputTextField("Contact Number", phoneNumber, context),
            visible ? inputTextField("OTP", otp, context) : SizedBox(),
            isLoading 
              ? CircularProgressIndicator()
              : !visible 
                ? SendOTPButton("Send OTP") 
                : SubmitOTPButton("Submit",context),
            if (visible)
              TextButton(
                onPressed: () => resendOTP(),
                child: Text("Resend OTP"),
              ),
          ],
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget SendOTPButton(String text) => ElevatedButton(
    onPressed: () async {
      if (phoneNumber.text.isEmpty || phoneNumber.text.length != 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please enter a valid 10-digit phone number")),
        );
        return;
      }
      
      log("Sending OTP to ${phoneNumber.text}");
      setState(() {
        isLoading = true;
      });
      
      await FirebaseAuthentication().sendOTP(
        phoneNumber.text,
        onCodeSent: (String verificationId) {
          this.verificationId = verificationId;
          setState(() {
            visible = true;
            isLoading = false;
          });
          log("OTP Sent Successfully");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("OTP sent to +91${phoneNumber.text}")),
          );
        },
        onVerificationFailed: (String error) {
          setState(() {
            isLoading = false;
          });
          log("Verification failed: $error");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $error")),
          );
        },
        onVerificationCompleted: (String message) {
          setState(() {
            isLoading = false;
          });
          log("Auto verification completed: $message");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        },
      );
    },
    child: Text(text),
  );

  // ignore: non_constant_identifier_names
  Widget SubmitOTPButton(String text,BuildContext context) => ElevatedButton(
    onPressed: () async {
      if (otp.text.isEmpty || verificationId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please enter the OTP")),
        );
        return;
      }
      
      setState(() {
        isLoading = true;
      });
      
      bool success = await FirebaseAuthentication().authenticate(verificationId!, otp.text);
      
      setState(() {
        isLoading = false;
      });
      
      if (success) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Authentication Successful!")),
        );
        // ignore: use_build_context_synchronously
        context.go('/navbar');
        // Navigate to next screen
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Authentication failed. Please check your OTP.")),
        );
      }
    },
    child: Text(text),
  );

  void resendOTP() async {
    setState(() {
      isLoading = true;
      visible = false;
    });
    
    await FirebaseAuthentication().sendOTP(
      phoneNumber.text,
      onCodeSent: (String verificationId) {
        this.verificationId = verificationId;
        setState(() {
          visible = true;
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("OTP resent to +91${phoneNumber.text}")),
        );
      },
      onVerificationFailed: (String error) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $error")),
        );
      },
      onVerificationCompleted: (String message) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      },
    );
  }

  Widget inputTextField(
    String labelText,
    TextEditingController textEditingController,
    BuildContext context,
  ) => Padding(
    padding: EdgeInsets.all(10.00),
    child: SizedBox(
      width: MediaQuery.of(context).size.width / 1.5,
      child: TextFormField(
        obscureText: labelText == "OTP" ? true : false,
        controller: textEditingController,
        keyboardType: TextInputType.number,
        maxLength: labelText == "OTP" ? 6 : 10,
        decoration: InputDecoration(
          hintText: labelText,
          hintStyle: TextStyle(color: Colors.blue),
          filled: true,
          fillColor: Colors.blue[100],
          counterText: "", // Hide character counter
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.circular(5.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.circular(5.5),
          ),
        ),
      ),
    ),
  );
}

class FirebaseAuthentication {
  String phoneNumber = "";

  Future<void> sendOTP(
    String phoneNumber, {
    required Function(String) onCodeSent,
    required Function(String) onVerificationFailed,
    required Function(String) onVerificationCompleted,
  }) async {
    this.phoneNumber = phoneNumber;
    FirebaseAuth auth = FirebaseAuth.instance;

    try {
      await auth.verifyPhoneNumber(
        phoneNumber: '+91$phoneNumber',
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification completed (usually happens on Android)
          try {
            UserCredential userCredential = await auth.signInWithCredential(credential);
            if (userCredential.user != null) {
              onVerificationCompleted("Phone number automatically verified and signed in");
            }
          } catch (e) {
            log("Auto sign-in failed: $e");
            onVerificationFailed("Auto sign-in failed: $e");
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          log("Verification failed: ${e.message}");
          String errorMessage = "Verification failed";
          
          switch (e.code) {
            case 'invalid-phone-number':
              errorMessage = "Invalid phone number format";
              break;
            case 'too-many-requests':
              errorMessage = "Too many requests. Please try again later";
              break;
            case 'operation-not-allowed':
              errorMessage = "Phone authentication is not enabled";
              break;
            default:
              errorMessage = e.message ?? "Verification failed";
          }
          
          onVerificationFailed(errorMessage);
        },
        codeSent: (String verificationId, int? resendToken) {
          log("OTP sent to +91$phoneNumber, verificationId: $verificationId");
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          log("Code auto retrieval timeout for verificationId: $verificationId");
        },
        timeout: Duration(seconds: 60), // Set timeout
      );
    } catch (e) {
      log("Error sending OTP: $e");
      onVerificationFailed("Failed to send OTP: $e");
    }
  }

  Future<bool> authenticate(String verificationId, String otp) async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      UserCredential userCredential = await auth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        log("Authentication Successful for user: ${userCredential.user!.uid}");
        return true;
      } else {
        log("Authentication failed - no user returned");
        return false;
      }
    } catch (e) {
      log("Authentication error: $e");
      return false;
    }
  }
}