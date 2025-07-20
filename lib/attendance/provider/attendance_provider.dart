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
  bool _isInitialized = false;
  Future<void> initDatabase() async {
    if (_isInitialized) return;
    try {
      database = await LocalStorage.getInstance();
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(AttendanceAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(TaskAdapter());
      }
      if (!Hive.isBoxOpen('attendance_box')) {
        await database.openBox<Attendance>(
          boxName: 'attendance_box',
          typeId: 1,
        );
      }
      if (!Hive.isBoxOpen('task_box')) {
        await database.openBox<Task>(boxName: 'task_box', typeId: 2);
      }
      _isInitialized = true;
    } catch (_) {
      throw Exception('An error occurred');
    }
  }

  Future<void> loadName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      myName = prefs.getString('user_name');
      notifyListeners();
    } catch (_) {
      throw Exception('Failed load details.');
    }
  }

  Future<void> saveUserName(String userName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', userName);
      myName = userName;
      notifyListeners();
    } catch (_) {
      throw Exception('Failed to save details.');
    }
  }

  Future<void> loadAttendanceHistory() async {
    try {
      await initDatabase();

      attendanceHistory = database.values<Attendance>('attendance_box');

      if (attendanceHistory.isNotEmpty) {
        final today = DateTime.now();
        final todayDateOnly = DateTime(today.year, today.month, today.day);

        List<Attendance> list = attendanceHistory.where((element) {
          if (element.date != null) {
            final dateOnly = DateTime(
              element.date!.year,
              element.date!.month,
              element.date!.day,
            );

            return todayDateOnly == dateOnly;
          }
          return false;
        }).toList();
        if (list.isNotEmpty) {
          todayAttendance = list.first;

          _formatDateAndTime();
          _getTimeSpent();
        }
      }
      notifyListeners();
    } catch (_) {
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
          attendanceStatus: 'Incomplete',
        );

        todayAttendance = newAttendance;
        attendanceHistory.add(todayAttendance!);
        await database.add(boxName: 'attendance_box', value: newAttendance);
        _formatDateAndTime();
        notifyListeners();
      }
    } catch (_) {
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
      } else if (todayAttendance?.checkInTime != null &&
          todayAttendance?.checkOutTime != null) {
        message = 'Attendance for today has already been marked.';
        return message;
      } else {
        String formattedCheckOutTime = DateFormat('HH:mm').format(todayDate);

        todayAttendance!.checkOutTime = formattedCheckOutTime;
        todayAttendance!.attendanceStatus = 'Present';
        final records = database.values<Attendance>('attendance_box');
        final index = records.indexWhere(
          (record) => record.id == todayAttendance!.id,
        );
        if (index != -1) {
          await database.update(
            boxName: 'attendance_box',
            value: todayAttendance!,
          );
          final localIndex = attendanceHistory.indexWhere(
            (att) => att.id == todayAttendance!.id,
          );
          attendanceHistory[localIndex] = todayAttendance!;

          _getTimeSpent();
          notifyListeners();
        }
      }
    } catch (_) {
      throw Exception('An error occurred');
    }

    return message;
  }

  void _formatDateAndTime() {
    if (todayAttendance?.date != null) {
      formattedCurrentDay = DateFormat(
        'MM/dd/yyyy',
      ).format(todayAttendance!.date!);
      notifyListeners();
    }
  }

  void _getTimeSpent() async {
    if (todayAttendance?.checkInTime == null ||
        todayAttendance?.checkOutTime == null) {
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
      todayAttendance?.timeSpent = '$hours Hours and $minutes Minutes';
      await database.update(boxName: 'attendance_box', value: todayAttendance!);
    } catch (_) {
      return;
    }
  }

  Future<void> markOnLeave() async {
    try {
      DateTime todayDate = DateTime.now();
      todayAttendance ??= Attendance(
        id: Uuid().v4(),
        date: todayDate,
        dayName: DateFormat('EEEE').format(todayDate),
        checkInTime: null,
        checkOutTime: null,
        timeSpent: null,
        attendanceStatus: 'On Leave',
      );
      _formatDateAndTime();

      await database.add(boxName: 'attendance_box', value: todayAttendance!);
      attendanceHistory.add(todayAttendance!);

      notifyListeners();
    } catch (_) {
      throw Exception('Failed to mark attendance as leave.');
    }
  }
}
