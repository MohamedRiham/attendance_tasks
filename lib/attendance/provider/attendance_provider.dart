import 'package:attendance_tasks/task/models/task.dart';
import 'package:flutter/material.dart';
import 'package:hive_local_storage/hive_local_storage.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:attendance_tasks/attendance/models/attendance.dart';
import 'package:uuid/uuid.dart';

class AttendanceProvider with ChangeNotifier {
  late final LocalStorage database;
  String? myName;
  List<Attendance> attendanceHistory = [];
  Attendance? todayAttendance;
  String? formattedCurrentDay;
  Future<void> initDatabase() async {
    try {
      database = await LocalStorage.getInstance();
      Hive.registerAdapter(AttendanceAdapter());
      Hive.registerAdapter(TaskAdapter());
      if (!Hive.isBoxOpen('attendance_box')) {
        await database.openBox<Attendance>(
          boxName: 'attendance_box',
          typeId: 1,
        );
      }
      if (!Hive.isBoxOpen('task_box')) {
        await database.openBox<Task>(boxName: 'task_box', typeId: 2);
      }
    } catch (e) {
      throw Exception('An error occurred');
    }
  }

  Future<void> loadName() async {
    final prefs = await SharedPreferences.getInstance();
    myName = prefs.getString('user_name');
    notifyListeners();
  }

  Future<void> saveUserName(String userName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', userName);
    myName = userName;
    notifyListeners();
  }

  Future<void> loadAttendanceHistory() async {
    try {
      await initDatabase();

      attendanceHistory = database.values<Attendance>('attendance_box');
      if (attendanceHistory.isNotEmpty) {
        final today = DateTime.now();
        final todayDateOnly = DateTime(today.year, today.month, today.day);
        todayAttendance = attendanceHistory.firstWhere(
                (record) {
              if (record.date == null) return false;
              final recordDate = DateTime(
                  record.date!.year, record.date!.month, record.date!.day);
              return recordDate == todayDateOnly;
            }
        );
        _formatDateAndTime();
        _getTimeSpent();
        notifyListeners();
      }
    } catch (e) {

      throw Exception('Failed to load attendance history');
    }
  }

  Future<String> checkIn() async {
    String message = '';
    try {
      final existingRecords = database.values<Attendance>('attendance_box');

      final todayDate = DateTime.now();

      final alreadyCheckedIn = existingRecords.any((record) {
        if (record.date != null) {
          final recordDate = DateTime(
            record.date!.year,
            record.date!.month,
            record.date!.day,
          );
          final now = DateTime(todayDate.year, todayDate.month, todayDate.day);

          return recordDate == now;
        }
        return false;
      });

      if (alreadyCheckedIn) {
        message = 'Already marked';
      } else {
        var id = Uuid().v4();
        String formattedCheckInTime = DateFormat('HH:mm').format(todayDate);
        String formattedDayName = DateFormat('EEEE').format(todayDate);
        final newAttendance = Attendance(
          id: id,
          date: todayDate,
          checkInTime: formattedCheckInTime,
          dayName: formattedDayName,
          attendanceStatus: 'Checked In Only'
        );

        todayAttendance = newAttendance;
        attendanceHistory.add(todayAttendance!);
        await database.add(boxName: 'attendance_box', value: newAttendance);
        _formatDateAndTime();
        notifyListeners();
      }
    } catch (e) {
      throw Exception('An error occurred');
    }

    return message;
  }


  Future<String> checkOut() async {
    String message = '';
    try {
      final todayDate = DateTime.now();

      if (todayAttendance == null) {
        message = 'No check-in found for today.';
        return message;
      }
        String formattedCheckOutTime = DateFormat('HH:mm').format(todayDate);

        todayAttendance!.checkOutTime = formattedCheckOutTime;
todayAttendance!.attendanceStatus = 'Present';
      final records = database.values<Attendance>('attendance_box');
      final index = records.indexWhere((record) => record.id == todayAttendance!.id);
      if (index != -1) {
        await database.update(
            boxName: 'attendance_box', value: todayAttendance!);
        final localIndex = attendanceHistory.indexWhere((att) =>
        att.id == todayAttendance!.id);
        attendanceHistory[localIndex] = todayAttendance!;

_getTimeSpent();
        notifyListeners();
      }
    } catch (e) {
      throw Exception('An error occurred');
    }

    return message;
  }

  void _formatDateAndTime() {
    if (todayAttendance?.date != null) {
      formattedCurrentDay =
          DateFormat('MM/dd/yyyy').format(todayAttendance!.date!);
      notifyListeners();
    }

  }


  void _getTimeSpent() async {
    if (todayAttendance?.checkInTime == null || todayAttendance?.checkOutTime == null) {
      return;
    }

    try {
      final checkInParts = todayAttendance!.checkInTime!.split(':');
      final checkOutParts = todayAttendance!.checkOutTime!.split(':');

      if (checkInParts.length != 2 || checkOutParts.length != 2) return;

      final now = DateTime.now();

      final checkIn = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(checkInParts[0]),
        int.parse(checkInParts[1]),
      );

      final checkOut = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(checkOutParts[0]),
        int.parse(checkOutParts[1]),
      );

      final diff = checkOut.difference(checkIn);
      final hours = diff.inHours.toString().padLeft(2, '0');
      final minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
todayAttendance?.timeSpent = hours+minutes;
      await database.update(
          boxName: 'attendance_box', value: todayAttendance!);

    } catch (e) {
      return;
    }
  }
}
