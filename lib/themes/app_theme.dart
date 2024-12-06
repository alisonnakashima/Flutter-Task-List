import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.pink,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromARGB(255, 200, 120, 120),
      foregroundColor: Colors.white,
    ),
    cardTheme: CardTheme(
      color: Colors.grey,
      elevation: 4.0,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.pink,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromARGB(255, 90, 15, 75),
      foregroundColor: Colors.white,
    ),
    cardTheme: CardTheme(
      color: Colors.grey,
      elevation: 4.0,
    ),
  );
}
