import 'package:flutter/material.dart';

final lightTheme = ThemeData(
  progressIndicatorTheme: ProgressIndicatorThemeData(color: Colors.black),
  useMaterial3: true,
  dividerTheme: DividerThemeData(color: Colors.black),
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
  scaffoldBackgroundColor: Colors.white,
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: Colors.black,
    unselectedItemColor: Colors.grey,
    selectedIconTheme: IconThemeData(color: Colors.black),
    unselectedIconTheme: IconThemeData(color: Colors.grey),
    showUnselectedLabels: true,
    type: BottomNavigationBarType.fixed,
  ),
);

final darkTheme = ThemeData(
  progressIndicatorTheme: ProgressIndicatorThemeData(color: Colors.white),
  useMaterial3: true,
  brightness: Brightness.dark,
  dividerTheme: DividerThemeData(color: Colors.white),

  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.teal,
    brightness: Brightness.dark,
  ),
  scaffoldBackgroundColor: Colors.black,
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.grey[900],
    selectedItemColor: Colors.white,
    unselectedItemColor: Colors.black,
    selectedIconTheme: IconThemeData(color: Colors.white),
    unselectedIconTheme: IconThemeData(color: Colors.black),
    showUnselectedLabels: true,
    type: BottomNavigationBarType.fixed,
  ),
);
