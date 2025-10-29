
import 'package:exult_admin/core/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
Widget addbutton(double height, double width) {
  return SizedBox(
    height: height * 0.06, 
    width: width * 0.18,
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color.fromRGBO(219, 126, 26, 1),
            Color.fromRGBO(236, 215, 194, 1),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.add,
            color: Colorclass.blackcolor,
            size: height * 0.025,
          ),
          SizedBox(width: width * 0.015),
          Text(
            'Add',
            style: GoogleFonts.dmSans(
              fontSize: height * 0.015,
              fontWeight: FontWeight.w400,
              color: Colorclass.blackcolor,
            ),
          ),
        ],
      ),
    ),
  );
}
Widget addtextbutton(double height, double width, String text, {Icon? icon}) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(6),
      gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color.fromRGBO(219, 126, 26, 1),
          Color.fromRGBO(236, 215, 194, 1),
        ],
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.all(6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) icon,
          if (icon != null) SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colorclass.blackcolor,
            ),
          ),
        ],
      ),
    ),
  );
}
Widget addtextcartbutton(double height, double width, String text, {Icon? icon}) {
  return SizedBox(
    height: height, 
    width: width,   
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height * 0.3), // Scale with height
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color.fromRGBO(219, 126, 26, 1),
            Color.fromRGBO(236, 215, 194, 1),
          ],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(height * 0.1), // Relative padding
        child: Center( // Ensures content stays centered
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // Prevents row from expanding
            children: [
              if (icon != null) icon,
              if (icon != null) SizedBox(width: height * 0.1),
              Text(
                text,
                style: GoogleFonts.dmSans(
                  fontSize: height * 0.42, 
                  fontWeight: FontWeight.w700,
                  color: Colorclass.blackcolor,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
// class UserUtils {
//   static String getUserIdentifier(User user) {
//     // Always use UID as it's the most reliable identifier
//     return user.uid;
//   }

//   static String getUserDocumentPath(User user) {
//     return 'users/${getUserIdentifier(user)}';
//   }

//   static String getSanitizedIdentifier(User user) {
//     // For cases where you need a sanitized version (like for storage paths)
//     if (user.phoneNumber != null) {
//       return user.phoneNumber!
//           .replaceAll('+', '_plus_')
//           .replaceAll(' ', '_')
//           .replaceAll('(', '')
//           .replaceAll(')', '')
//           .replaceAll('-', '');
//     }
//     return user.uid;
//   }
// }