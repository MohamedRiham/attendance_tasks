import 'package:attendance_tasks/common/themes/constants/themes.dart';
import 'package:attendance_tasks/common/themes/provider/theme_provider.dart';
import 'package:attendance_tasks/attendance/provider/attendance_provider.dart';
import 'package:attendance_tasks/attendance/screens/attendance_screen.dart';
import 'package:attendance_tasks/task/provider/task_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProxyProvider<AttendanceProvider, TaskProvider>(
          create: (_) => TaskProvider(null),
          update: (_, attendanceProvider, __) =>
              TaskProvider(attendanceProvider.database),
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
navigatorKey: navigatorKey,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.currentTheme,
      debugShowCheckedModeBanner: false,

      home:  const AttendanceScreen(),
    );
  }
}
