// import 'package:coffee_shop/App/appTheme.dart';
// import 'package:coffee_shop/Cores/Widget/button.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';
// class SignupScreen extends StatefulWidget {
//   // ignore: prefer_typing_uninitialized_variables
//   final  verificationId ;
//   const SignupScreen({super.key,
//    this.verificationId});
//   @override
//   State<SignupScreen> createState() => _SignupScreenState();
// }

// class _SignupScreenState extends State<SignupScreen> {
//    List<String> otp = List.filled(6, '');
//   int resendTimer = 30;
//   bool isLoading = false;
//   String mobileNumber = '9876543210';
//    @override
//   void initState() {
//     super.initState();
//     _startResendTimer();
//   }
//   void _startResendTimer() {
//     Future.delayed(Duration(seconds: 1), () {
//       if (resendTimer > 0) {
//         setState(() => resendTimer--);
//         _startResendTimer();
//       }
//     });
//   }
//   void _handleOTPChange(String value, int index) {
//     setState(() {
//       otp[index] = value;
//       // Auto move to next field
//       if (value.isNotEmpty && index < 5) {
//         FocusScope.of(context).nextFocus();
//       }
//       // Auto move to previous field on backspace
//       if (value.isEmpty && index > 0) {
//         FocusScope.of(context).previousFocus();
//       }
//     });
//   }
//   void _verifyOTP() {
//     setState(() => isLoading = true);
    
//     final enteredOTP = otp.join();
//     if (enteredOTP.length != 6) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Please enter complete OTP')));
//       setState(() => isLoading = false);
//       return;
//     }

//     // Simulate verification
//     Future.delayed(Duration(seconds: 2), () {
//       setState(() => isLoading = false);
//       if (enteredOTP == "123456") { // Replace with actual verification
//         // ignore: use_build_context_synchronously
//         Navigator.pushReplacementNamed(context, '/success');
//       } else {
//         // ignore: use_build_context_synchronously
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Invalid OTP. Try again')));
//       }
//     });
//   }

//   void _resendOTP() {
//     setState(() {
//       otp = List.filled(6, '');
//       resendTimer = 30;
//     });
//     _startResendTimer();
//     // Add your resend OTP logic here
//   }
//   @override
//   Widget build(BuildContext context) {
//      var width = MediaQuery.of(context).size.width;
//     var height = MediaQuery.of(context).size.height;
//     return Scaffold(
//         body: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//            crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//                Padding(
//                  padding: const EdgeInsets.only(top: 100,left: 40),
//                  child: Text(
//                         "We Just Send an Message",
//                         style: GoogleFonts.dmSans(
//                           color: Colorclass.blackcolor, // Example text color
//                           fontSize: 20,
//                   fontWeight: FontWeight.w600,
//                 ),
//                 softWrap: true,
//                 overflow: TextOverflow.visible,
//               ),
//             ),
//             SizedBox(height: height * 0.02),
            
//              RichText(
//               text: TextSpan(
//                 style: TextStyle(fontSize: 16, color: Colors.black87),
//                 children: [
//                   TextSpan(
//                     text: "Enter the security code we send to \n",
//                      style: GoogleFonts.dmSans(
//                 color: Colorclass.blackcolor, // Example text color
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//               ),
//                   ),
                  
//                   TextSpan(
//                     text: "mobile number: ",
//                     style: TextStyle(
//                       fontWeight: FontWeight.w500,
//                       color:  Colorclass.blackcolor,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: height*0.02,),codecontainer(width)
//           ],
//           ),
//         ),

//     );
//   }
// Widget codecontainer(double width) {
//   return Column(
//     children: [
//       Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: List.generate(4, (index) {
//           return SizedBox(
//             width: width*0.13,
//             child: TextField(
//               onChanged: (value) => _handleOTPChange(value, index),
//               keyboardType: TextInputType.number,
//               textAlign: TextAlign.center,
//               maxLength: 1,
//               decoration: InputDecoration(
//                 counterText: '',
//                 border: OutlineInputBorder(),
//               ),
//               inputFormatters: [
//                 FilteringTextInputFormatter.digitsOnly,
//               ],
//             ),
//           );
//         }),
//       ),
//       const SizedBox(height: 20),
//       // Resend OTP
//       Center(
//         child: TextButton(
//           onPressed: resendTimer == 0 ? _resendOTP : null,
//           child: Text(
//             resendTimer == 0 
//               ? 'Resend OTP' 
//               : 'Resend in $resendTimer seconds',
//           ),
//         ),
//       ),
//       const SizedBox(height: 30),
//        ButtonNavigation(text: "Verify Otp",height: 50,width:width),
//     ],
//   );
// }
// }


 // Verify Button
      // ElevatedButton(
      //   onPressed: isLoading ? null : _verifyOTP,
      //   style: ElevatedButton.styleFrom(
      //     padding: const EdgeInsets.symmetric(vertical: 15),
      //   ),
      //   child: isLoading
      //       ? const CircularProgressIndicator(color: Colors.white)
      //       :  ButtonNavigation(text: "Verify Otp",height: 50,width:width),
      // ),



// import 'dart:developer';

// import 'package:coffee_shop/Features/Authentication/home2screen.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// // import 'package:phone_auth/screens/home_screen.dart';

// class OTPScreen extends StatefulWidget {
//   const OTPScreen({super.key, required this.verificationId});
//   final String verificationId;

//   @override
//   State<OTPScreen> createState() => _OTPScreenState();
// }

// class _OTPScreenState extends State<OTPScreen> {
//   final otpController = TextEditingController();

//   bool isLoading = false;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 30),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Text(
//             "We have sent an OTP to your phone. Plz verify",
//             textAlign: TextAlign.center,
//             style: TextStyle(fontSize: 18),
//           ),
//           const SizedBox(height: 40),
//           TextField(
//             controller: otpController,
//             keyboardType: TextInputType.phone,
//             decoration: InputDecoration(
//                 fillColor: Colors.grey.withOpacity(0.25),
//                 filled: true,
//                 hintText: "Enter OTP",
//                 border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(30),
//                     borderSide: BorderSide.none)),
//           ),
//           const SizedBox(height: 20),
//           isLoading
//               ? const CircularProgressIndicator()
//               : ElevatedButton(
//                   onPressed: () async {
//                     setState(() {
//                       isLoading = true;
//                     });

//                     try {
//                       final cred = PhoneAuthProvider.credential(
//                           verificationId: widget.verificationId,
//                           smsCode: otpController.text);

//                       await FirebaseAuth.instance.signInWithCredential(cred);

//                       Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => const home(),
//                           ));
//                     } catch (e) {
//                       log(e.toString());
//                     }
//                     setState(() {
//                       isLoading = false;
//                     });
//                   },
//                   child: const Text(
//                     "Verify",
//                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
//                   ),)
//         ],
//       ),
//     ),);
//   }
// }


  // it is best code for mobile 


// import 'dart:async';
// import 'dart:developer';
// import 'package:coffee_shop/core/widget/button.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';

// import '../../core/utils/utils.dart';

// class OTPScreen extends StatefulWidget {
//   final String verificationId;
//   final String phoneNumber;
//   final Function() resendVerificationCode; // Callback to resend OTP
  
//   const OTPScreen({
//     super.key,
//     required this.verificationId,
//     required this.phoneNumber,
//     required this.resendVerificationCode,
//   });

//   @override
//   State<OTPScreen> createState() => _OTPScreenState();
// }

// class _OTPScreenState extends State<OTPScreen> {
//   List<String> otp = List.filled(6, '');
//   bool isLoading = false;
//   final List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());
//   int _resendTimer = 30;
//   late Timer _timer;
//   bool _canResend = false;

//   @override
//   void initState() {
//     super.initState();
//     startTimer();
//   }

//   @override
//   void dispose() {
//     _timer.cancel();
//     for (var node in focusNodes) {
//       node.dispose();
//     }
//     super.dispose();
//   }

//   void startTimer() {
//     setState(() {
//       _resendTimer = 30;
//       _canResend = false;
//     });
    
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (_resendTimer > 0) {
//         setState(() {
//           _resendTimer--;
//         });
//       } else {
//         setState(() {
//           _canResend = true;
//         });
//         timer.cancel();
//       }
//     });
//   }

//   Future<void> resendOTP() async {
//     if (!_canResend) return;
    
//     setState(() {
//       isLoading = true;
//     });
    
//     try {
//       await widget.resendVerificationCode();
//       startTimer(); // Reset the timer after resending
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('OTP resent successfully')),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to resend OTP: ${e.toString()}')),
//       );
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   void _handleOTPChange(String value, int index) {
//     log('OTP field $index changed: $value');
//     setState(() {
//       otp[index] = value;
      
//       // Auto move to next field
//       if (value.isNotEmpty && index < 5) {
//         FocusScope.of(context).requestFocus(focusNodes[index + 1]);
//       }
      
//       // Auto move to previous field on backspace
//       if (value.isEmpty && index > 0) {
//         FocusScope.of(context).requestFocus(focusNodes[index - 1]);
//       }
      
//       // Auto verify if last digit entered
//       if (index == 5 && value.isNotEmpty) {
//         _verifyOTP();
//       }
//     });
//   }

//   Future<void> _verifyOTP() async {
//     if (isLoading) return;
    
//     final enteredOTP = otp.join();
//     log('Attempting verification with OTP: $enteredOTP');
    
//     if (enteredOTP.length != 6) {
//       log('Incomplete OTP entered');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please enter complete 6-digit OTP')),
//       );
//       return;
//     }

//     setState(() => isLoading = true);
    
//     try {
//       log('Creating credential with verificationId: ${widget.verificationId}');
//       final cred = PhoneAuthProvider.credential(
//         verificationId: widget.verificationId,
//         smsCode: enteredOTP,
//       );

//       log('Signing in with credential');
//       await FirebaseAuth.instance.signInWithCredential(cred);
      
//       log('Authentication successful');
//       if (!mounted) return;
      
//     } catch (e, stack) {
//       log('Verification failed', error: e, stackTrace: stack);
//       if (!mounted) return;
      
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Invalid OTP. Please try again')),
//       );
//       setState(() => isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;
//     final height = MediaQuery.of(context).size.height;

//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               SizedBox(height: height * 0.1),
              
//               // Title
//               Text(
//                 "Enter Verification Code",
//                 style: GoogleFonts.dmSans(
//                   color: Colorclass.blackcolor,
//                   fontSize: 20,
//                   fontWeight: FontWeight.w600,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
              
//               SizedBox(height: height * 0.03),
              
//               // Description
//               Text(
//                 "We've sent a 6-digit code to ${widget.phoneNumber}",
//                 style: GoogleFonts.dmSans(
//                   color: Colorclass.blackcolor,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
              
//               SizedBox(height: height * 0.05),
              
//               // OTP Input Fields
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: List.generate(6, (index) {
//                   return SizedBox(
//                     width: width * 0.12,
//                     child: TextField(
//                       controller: TextEditingController(text: otp[index]),
//                       focusNode: focusNodes[index],
//                       onChanged: (value) => _handleOTPChange(value, index),
//                       keyboardType: TextInputType.number,
//                       textAlign: TextAlign.center,
//                       maxLength: 1,
//                       style: GoogleFonts.dmSans(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                       decoration: InputDecoration(
//                         counterText: '',
//                         filled: true,
//                         fillColor: Colors.grey.withOpacity(0.1),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                           borderSide: BorderSide.none,
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                           borderSide: BorderSide(
//                             color: Colors.grey.withOpacity(0.3),
//                           ),
//                         ),
//                       ),
//                       inputFormatters: [
//                         FilteringTextInputFormatter.digitsOnly,
//                       ],
//                     ),
//                   );
//                 }),
//               ),
              
//               SizedBox(height: height * 0.05),
              
//               // Verify Button
//               isLoading
//                   ? const CircularProgressIndicator()
//                   : ButtonNavigation(
//                       text: "Verify OTP",
//                       height: 50,
//                       width: width,
//                       onPressed: _verifyOTP,
//                     ),
              
//               SizedBox(height: height * 0.02),
              
//               // Resend OTP Button
//               TextButton(
//                 onPressed: _canResend ? resendOTP : null,
//                 child: Text(
//                   _canResend 
//                       ? "Resend OTP" 
//                       : "Resend OTP in $_resendTimer seconds",
//                   style: GoogleFonts.dmSans(
//                     color: _canResend 
//                         ? Colorclass.blackcolor 
//                         : Colors.grey,
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
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