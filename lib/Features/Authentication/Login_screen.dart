// import 'dart:developer';

// import 'package:coffee_shop/App/appTheme.dart';
// import 'package:coffee_shop/Cores/Widget/button.dart';
// import 'package:coffee_shop/Features/Authentication/signup_screen.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
  
//   TextEditingController phonecontroller= TextEditingController();
//   String _mobilenumber='';
//   bool isloading=false;

//   @override
//   Widget build(BuildContext context) {
//     var width = MediaQuery.of(context).size.width;
//     var height = MediaQuery.of(context).size.height;

//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       body: SingleChildScrollView(
//         scrollDirection: Axis.vertical,
//         child: Column(
//           children: [
//             Stack(
//               children: [
//                 Container(
//                   height: height * 0.3,
//                   width: width,
//                   decoration: BoxDecoration(
//                     image: DecorationImage(
//                       image: AssetImage(
//                         "Assets/Images/dff9e083-37c1-465a-bcfd-9f3dc4d71bec.jpg",
//                       ),
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   bottom: height * 0.07,
//                   left: width * 0.06,
//                   child: Text(
//                     "Welcome Back ! ",
//                     style: GoogleFonts.poppins(
//                       fontSize: 23,
//                       fontWeight: FontWeight.bold,
//                       color: Colorclass.fantgreencolor,
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   bottom: height * 0.04,
//                   left: width * 0.06,
//                   child: Text(
//                     "Login to Continue .... ",
//                     style: GoogleFonts.poppins(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w500,
//                       color: Colorclass.fantgreencolor,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: height * 0.04),
//             Padding(
//               padding: EdgeInsets.all(12),
//               child: Container(
//                 height: height * 0.6,
//                 width: width,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(12),
//                   color: Colorclass.whitecolor,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colorclass.shadowcolor,
//                       offset: Offset(3, 3),
//                       spreadRadius: 1,
//                       blurRadius: 6,
//                     ),
//                   ],
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(6),
//                   child: Column(
//                     children: [
//                       Row(
//                         children: [
//                           Text(
//                             "Coffee Shop",
//                             style: GoogleFonts.dmSans(
//                               color: Colorclass.blackcolor, // Example text color
//                               fontSize: 25,
//                               fontWeight: FontWeight.w600,
//                             ),
//                             softWrap: true,
//                             overflow: TextOverflow.visible,
//                           ),
//                         ],
//                       ),
        
//                       SizedBox(height: height * 0.02),
        
//                       SizedBox(
//                         width: width,
//                         child: Text(
//                           "Add your phone number.We'll send you a verification code so we know you are real.",
//                           style: GoogleFonts.dmSans(
//                             color: Colorclass.blackcolor, // Example text color
//                             fontSize: 12,
//                             fontWeight: FontWeight.w400,
//                           ),
//                           softWrap: true,
//                           overflow: TextOverflow.visible,
//                         ),
//                       ),
//                       SizedBox(height: height * 0.02),
//                       Text(
//                         "Enter your phone number",
//                         style: GoogleFonts.dmSans(
//                           color: Colorclass.blackcolor, // Example text color
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                         ),
//                         softWrap: true,
//                         overflow: TextOverflow.visible,
//                       ),
//                         SizedBox(height: height * 0.02),
//                       Form(
//                         key: _formKey,
//                         child: Column(
//                           children: [
//                             TextFormField(
//                               controller: phonecontroller,
//                               keyboardType: TextInputType.number,
//                               maxLength: 10,
//                               decoration: InputDecoration(
//                                 labelText: 'Mobile Number',
//                                 prefixIcon: Icon(Icons.phone),
//                                 border: OutlineInputBorder(
//                                   // Default border style
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: BorderSide(
//                                     color: Colorclass.fantgreencolor,
//                                   ),
//                                 ),
//                                 focusedErrorBorder: OutlineInputBorder(
//                                   // Error border when focused
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: BorderSide(
//                                     color: Colors.red,
//                                     width: 2,
//                                   ),
//                                 ),
//                               ),
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return 'Enter mobile number';
//                                 }
//                                 if (value.length != 10) {
//                                   return 'Must be 10 digits';
//                                 }
//                                 if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
//                                   return 'Digits only';
//                                 }
//                                 return null;
//                               },
//                               inputFormatters: [
//                                 FilteringTextInputFormatter.digitsOnly,
//                               ],
//                               onSaved: (value) => _mobilenumber = value!,
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: height * 0.03),
//                      isloading
//                      ?const CircularProgressIndicator()
//                      : ButtonNavigation(
//                         text: "Login !",
//                         height: height * 0.05,
//                         width: width * 0.7,
//                         onPressed: ()async {
                         
//                           await FirebaseAuth.instance.verifyPhoneNumber(
//                         phoneNumber: phonecontroller.text,
//                         verificationCompleted: (phoneAuthCredential) {},
//                         verificationFailed: (error) {
//                           log(error.toString());
//                         },
//                         codeSent: (verificationId, forceResendingToken) {
//                           setState(() {
//                             isloading = false;
//                           });
//                           Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) =>OTPScreen(
//                                         verificationId: verificationId,
//                                       ),
//                                       ),
//                                       );
//                         },
//                         codeAutoRetrievalTimeout: (verificationId) {
//                           log("Auto Retireval timeout");
//                         },
//                           if (_formKey.currentState!.validate()) {
//                             _formKey.currentState!.save();
//                             log("Valid mobile: $_mobilenumber");
//                           }
//                         },
//                       ),
//                 //         isloading
//                 // ? const CircularProgressIndicator()
//                 // : ElevatedButton(
//                 //     onPressed: () async {
//                 //       setState(() {
//                 //         isloading = true;
//                 //       });

//                 //       await FirebaseAuth.instance.verifyPhoneNumber(
//                 //         phoneNumber: phoneController.text,
//                 //         verificationCompleted: (phoneAuthCredential) {},
//                 //         verificationFailed: (error) {
//                 //           log(error.toString());
//                 //         },
//                 //         codeSent: (verificationId, forceResendingToken) {
//                 //           setState(() {
//                 //             isloading = false;
//                 //           });
//                 //           Navigator.push(
//                 //               context,
//                 //               MaterialPageRoute(
//                 //                   builder: (context) => OTPScreen(
//                 //                         verificationId: verificationId,
//                 //                       )));
//                 //         },
//                 //         codeAutoRetrievalTimeout: (verificationId) {
//                 //           log("Auto Retireval timeout");
//                 //         },
//                 //       );
//                 //     },
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


// best code and effective =important


// import 'dart:developer';

// // import 'package:coffee_shop/App/appTheme.dart';
// import 'package:coffee_shop/core/widget/button.dart';

// import 'package:coffee_shop/Features/Authentication/signup_screen.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';

// import '../../core/utils/utils.dart';

// class LoginScreen2 extends StatefulWidget {
//   const LoginScreen2({super.key});

//   @override
//   State<LoginScreen2> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen2> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _phoneController = TextEditingController();
//   bool _isLoading = false;
//   bool _isMounted = false;

//   @override
//   void initState() {
//     super.initState();
//     _isMounted = true;
//   }

//   @override
//   void dispose() {
//     _isMounted = false;
//     _phoneController.dispose();
//     super.dispose();
//   }

//   void _showSnackBar(String message, {bool isError = true}) {
//     if (!_isMounted) return;
    
//     ScaffoldMessenger.of(context).clearSnackBars();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: isError ? Colors.red : Colors.green,
//         duration: const Duration(seconds: 3),
//       ),
//     );
//   }

//   Future<void> _verifyPhoneNumber() async {
//     // Validate form first
//     if (!_formKey.currentState!.validate()) {
//       _showSnackBar('Please enter a valid 10-digit phone number');
//       return;
//     }

//     setState(() => _isLoading = true);
    
//     try {
//       final phoneNumber = '+91${_phoneController.text.trim()}'; // India country code
//       log('Attempting to verify phone number: $phoneNumber');

//       await FirebaseAuth.instance.verifyPhoneNumber(
//         phoneNumber: phoneNumber,
//         timeout: const Duration(seconds: 60),
//         verificationCompleted: (PhoneAuthCredential credential) async {
//           log('Verification completed automatically');
//           if (!_isMounted) return;
//           try {
//             await FirebaseAuth.instance.signInWithCredential(credential);
//             // Navigate to home screen if auto-verified
//           } catch (e) {
//             log('Auto verification error: $e');
//             _showSnackBar('Verification error: ${e.toString()}');
//           }
//         },
//         verificationFailed: (FirebaseAuthException e) {
//           log('Verification failed: ${e.message}');
//           _showSnackBar('Verification failed: ${e.message ?? 'Unknown error'}');
//         },
//         codeSent: (String verificationId, int? forceResendingToken) {
//           log('Code sent to $phoneNumber');
//           if (!_isMounted) return;
          
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => OTPScreen(
//                 verificationId: verificationId,
//                 phoneNumber: phoneNumber,
//                 resendVerificationCode: () {
//                   log('Resending verification code');
//                   return FirebaseAuth.instance.verifyPhoneNumber(
//                     phoneNumber: phoneNumber,
//                     forceResendingToken: forceResendingToken,
//                     verificationCompleted: (_) {},
//                     verificationFailed: (e) {
//                       _showSnackBar('Resend failed: ${e.message}');
//                     },
//                     codeSent: (newVerificationId, newToken) {
//                       log('Resend successful');
//                     },
//                     codeAutoRetrievalTimeout: (_) {},
//                   );
//                 },
//               ),
//             ),
//           );
//         },
//         codeAutoRetrievalTimeout: (String verificationId) {
//           log('Auto retrieval timeout');
//         },
//       );
//     } catch (e, stackTrace) {
//   log('VERIFICATION ERROR: ${e.toString()}');
//   log('STACK TRACE: $stackTrace');
//   if (e is FirebaseAuthException) {
//     log('FIREBASE ERROR CODE: ${e.code}');
//     log('FIREBASE ERROR MESSAGE: ${e.message}');
//   }
//   _showSnackBar('An unexpected error occurred. Please try again.');
// }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;

//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//           child: Column(
//             children: [
//               // Header Section
//               Container(
//                 height: size.height * 0.3,
//                 decoration: const BoxDecoration(
//                   image: DecorationImage(
//                     image: AssetImage("Assets/Images/dff9e083-37c1-465a-bcfd-9f3dc4d71bec.jpg"),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//                 child: Stack(
//                   children: [
//                     Positioned(
//                       bottom: 20,
//                       left: 20,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             "Welcome Back!",
//                             style: GoogleFonts.poppins(
//                               fontSize: 23,
//                               fontWeight: FontWeight.bold,
//                               color: Colorclass.fantgreencolor,
//                             ),
//                           ),
//                           Text(
//                             "Login to Continue...",
//                             style: GoogleFonts.poppins(
//                               fontSize: 18,
//                               fontWeight: FontWeight.w500,
//                               color: Colorclass.fantgreencolor,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 20),

//               // Form Section
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colorclass.whitecolor,
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colorclass.shadowcolor,
//                       offset: const Offset(3, 3),
//                       blurRadius: 6,
//                     ),
//                   ],
//                 ),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "Coffee Shop",
//                         style: GoogleFonts.dmSans(
//                           fontSize: 25,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         "Add your phone number. We'll send you a verification code.",
//                         style: GoogleFonts.dmSans(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w400,
//                         ),
//                       ),
//                       const SizedBox(height: 24),
//                       Text(
//                         "Enter your phone number",
//                         style: GoogleFonts.dmSans(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       TextFormField(
//                         controller: _phoneController,
//                         keyboardType: TextInputType.phone,
//                         maxLength: 10,
//                         decoration: InputDecoration(
//                           labelText: 'Mobile Number',
//                           prefixIcon: const Icon(Icons.phone),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide: BorderSide(
//                               color: Colorclass.fantgreencolor,
//                             ),
//                           ),
//                           errorBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide: const BorderSide(
//                               color: Colors.red,
//                               width: 1.5,
//                             ),
//                           ),
//                         ),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter phone number';
//                           }
//                           if (value.length != 10) {
//                             return 'Must be 10 digits';
//                           }
//                           if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
//                             return 'Only digits allowed';
//                           }
//                           return null;
//                         },
//                         inputFormatters: [
//                           FilteringTextInputFormatter.digitsOnly,
//                         ],
//                       ),
//                       const SizedBox(height: 32),
//                       SizedBox(
//                         width: double.infinity,
//                         child: _isLoading
//                             ? const Center(child: CircularProgressIndicator())
//                             : ButtonNavigation(
//                                 text: "Login",
//                                 height: 50,
//                                 onPressed: _verifyPhoneNumber,
//                               ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }