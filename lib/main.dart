import 'package:attendance_tasks/common/themes/constants/themes.dart';
import 'package:attendance_tasks/common/themes/provider/theme_provider.dart';
import 'package:attendance_tasks/attendance/provider/attendance_provider.dart';
import 'package:attendance_tasks/attendance/screens/attendance_screen.dart';
import 'package:attendance_tasks/task/provider/task_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(
          create: (_) => AttendanceProvider(),
        ),
      ],

      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Attendance & Tasks',

      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.currentTheme,
      debugShowCheckedModeBanner: false,

      home: const AttendanceScreen(),
    );
  }
}
