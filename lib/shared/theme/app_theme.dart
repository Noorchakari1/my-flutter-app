import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.blue,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.white,
        ),
        backgroundColor: Color(0xff1B047C),
      ),
      // Add more theme configurations here
    );
  }

  // You can add dark theme configuration here
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      // Add dark theme specific configurations
    );
  }
} 