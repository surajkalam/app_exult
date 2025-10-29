import 'package:flutter/material.dart';

class MaterialTheme {
  final TextTheme textTheme;

  MaterialTheme(this.textTheme);

  ColorScheme lightScheme() {
    return ColorScheme(
      primary: Color(0xFF372213), // (text-primary)
      onPrimary: Color(0xFFF8FAFC), // (bg-primary)
      primaryContainer: Color(0xFF372213), // (container-text)
      secondary: Color(0xFF94A3B8), // (text-secondary)
      surface: Color(0xFFF6F1E9), //  (bg-secondary, bg-card)
      error: Colors.red,
      onSecondary: Color(0xFF36C07E), //  (accent-primary)
      onPrimaryFixedVariant: Color(0xFFC67C4E), //(button)
      secondaryFixed: Color(0xFFFF7D29), //(orange)
      tertiary: Color(0xFF372213), //(category -icons)
      primaryFixed: Color(0xFF96CEB4), // (accent-secondary)
      primaryFixedDim: Color(0xFFF1F5F9),
      onPrimaryFixed: Color(0xFFFFD93D),
      tertiaryFixed: Color(0xFFFFF5EE), //indicator light browm profile
      onSecondaryFixed: Color(0xFFF8FAFC), //(fix white -container)
      outlineVariant: Color(0xFFE2E8F0), // (border-color)
      onSurface: Colors.white,
      onError: Colors.white,
      brightness: Brightness.light,
      shadow: Color(0x1F000000),
    );
  }

  ThemeData light() => theme(lightScheme());

  ColorScheme darkScheme() {
    return ColorScheme(
      primary: Color(0xFF372213), // (text-primary)
      onPrimary: Color.fromARGB(255, 16, 22, 36), // (bg-primary)
      primaryContainer: Color(0xFFF8FAFC),
      secondary: Color(0xFF94A3B8), // (text-secondary)
      surface: Color(0xFFD9C4B0), //  (bg-secondary, bg-card)
      error: Colors.red,
      onSecondary: Color(0xFF77B254),
      secondaryFixed: Color(0xFFFF7D29), //  (accent-primary,submit button)
      tertiary: Color(0xFF77B254), //(category -icons)
      onPrimaryFixedVariant: Color(0xFFC67C4E), //(button)
      primaryFixed: Color(0xFF96CEB4), // (accent-secondary)
      primaryFixedDim: Color(0xFFF1F5F9),
      onPrimaryFixed: Color(0xFFFFD93D),
      tertiaryFixed: Color(0xFFFFF5EE), //indicator light browm profile
      onSecondaryFixed: Color(0xFFF8FAFC), //(fix white -container)
      outlineVariant: Color(0xFF475569), // (border-color)
      onSurface: Colors.black,
      onError: Colors.white,
      brightness: Brightness.dark,
      shadow: Colors.white,
    );
  }

  ThemeData dark() => theme(darkScheme());

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto',
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    textTheme: textTheme.apply(
      bodyColor: colorScheme.primary,
      displayColor: colorScheme.primary,
    ),
    scaffoldBackgroundColor: colorScheme.onPrimary,
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.onPrimary,
      foregroundColor: colorScheme.primary,
    ),
  );
}
