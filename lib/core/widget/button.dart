
import 'package:coffee_shop/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ButtonNavigation extends StatelessWidget {
  final String text;
  final double? height;
  final double? width;
  final VoidCallback? onPressed; 
  final Widget?child;

  const ButtonNavigation({
    super.key,
    required this.text,
    this.height, 
    this.width = double.infinity, 
    this.onPressed,
    this.child,

  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colorclass.fantgreencolor,
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.dmSans(
              color: Colorclass.blackcolor, // Example text color
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}