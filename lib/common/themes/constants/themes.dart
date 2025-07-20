import 'package:flutter/material.dart';

final lightTheme = ThemeData(

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStatePropertyAll<Color>(Colors.black),
      foregroundColor: WidgetStatePropertyAll<Color>(Colors.white
      ),
      padding: WidgetStatePropertyAll<EdgeInsets>(
        EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.green,
    hintStyle: TextStyle(color: Colors.black),
    prefixIconColor: Colors.black,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.grey),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.blue),
    ),
  ),

  progressIndicatorTheme: ProgressIndicatorThemeData(color: Colors.black),
  useMaterial3: true,
  dividerTheme: DividerThemeData(color: Colors.black),
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
  scaffoldBackgroundColor: Colors.white,
  cardTheme: CardThemeData(color: Colors.blue),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.orange,
    selectedItemColor: Colors.white,
    unselectedItemColor: Colors.black,
    selectedIconTheme: IconThemeData(color: Colors.white),
    unselectedIconTheme: IconThemeData(color: Colors.black),
    showUnselectedLabels: true,
    type: BottomNavigationBarType.fixed,
  ),
);

final darkTheme = ThemeData(
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStatePropertyAll<Color>(Colors.teal),
      foregroundColor: WidgetStatePropertyAll<Color>(Colors.white),
      padding: WidgetStatePropertyAll<EdgeInsets>(
        EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    fillColor: Colors.grey[600],
    hintStyle: TextStyle(color: Colors.white),
    prefixIconColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.blue),
    ),
  ),
  progressIndicatorTheme: ProgressIndicatorThemeData(color: Colors.white),
  useMaterial3: true,
  cardTheme: CardThemeData(color: Colors.deepPurple),

  brightness: Brightness.dark,
  dividerTheme: DividerThemeData(color: Colors.white),

  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.teal,
    brightness: Brightness.dark,
  ),
  scaffoldBackgroundColor: Colors.black,
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.grey[800],
    selectedItemColor: Colors.white,
    unselectedItemColor: Colors.black,
    selectedIconTheme: IconThemeData(color: Colors.white),
    unselectedIconTheme: IconThemeData(color: Colors.black),
    showUnselectedLabels: true,
    type: BottomNavigationBarType.fixed,
  ),
);
