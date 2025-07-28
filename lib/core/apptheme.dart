import 'package:flutter/material.dart';

class ThemeConfig {
  // Common Input Border
  static final OutlineInputBorder _outlineInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8.0), // Rounded corners
    borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.0),
  );
  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Color(0xFFF5F5F5),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(16),
        ),
        elevation: 0,
        iconColor: Colors.white,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey,
        disabledForegroundColor: Colors.black54,
        padding: EdgeInsets.all(12),
        alignment: Alignment.center,
        textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      border: _outlineInputBorder,
      enabledBorder: _outlineInputBorder,
      focusedBorder: _outlineInputBorder.copyWith(
        borderSide: const BorderSide(color: Colors.black, width: 1),
      ),
      errorBorder: _outlineInputBorder.copyWith(
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),

      hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
    ),
    cardTheme: const CardThemeData(
      color: Colors.white,
      elevation: 8,
      margin: EdgeInsets.symmetric(vertical: 8),
      shadowColor: Colors.white12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        // side: BorderSide(
        //   color: Color(0xFFE0E0E0),
        //   width: 1,
        // ),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w400,
      ), // Large Title
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w400,
      ), // Title 1
      headlineSmall: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w400,
      ), // Title 2
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ), // Title 3
      titleMedium: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ), // Headline
      bodyLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.w400), // Body
      bodyMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ), // Callout
      bodySmall: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ), // Subhead
      labelLarge: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ), // Footnote
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ), // Caption 1
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w400,
      ), // Caption 2
    ),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blueGrey,
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.grey,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
    cardTheme: const CardThemeData(
      color: Colors.grey,
      elevation: 4,
      margin: EdgeInsets.all(8),
    ),
  );
}
