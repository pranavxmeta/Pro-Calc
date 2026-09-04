// lib/normcalc/theme/app_theme.dart

import 'package:material_ui/material_ui.dart';

final class AppTheme {
  const AppTheme._();

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0E1117),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF6C5CE7),
      secondary: Color(0xFF00CEC9),
      surface: Color(0xFF1A1F2C),
      onSurface: Colors.white,
      error: Color(0xFFFF7675),
    ),
    textTheme: const TextTheme(
      displayMedium: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: Colors.white,
      ),
      headlineSmall: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: Color(0xFFB0B7C3),
      ),
      bodyLarge: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
  );
}
