import 'package:flutter/material.dart';
import 'package:hive_local_storage/hive_local_storage.dart';

class AttendanceProvider with ChangeNotifier {
  late final LocalStorage database;
  Future<void> initDatabase() async {
    try {
      database = await LocalStorage.getInstance();
      Hive.registerAdapter(AttendanceAdapter());
      Hive.registerAdapter(TaskAdapter());
      await database.openBox<Attendance>(boxName: 'attendance_box', typeId: 1);
      await database.openBox<Task>(boxName: 'task_box', typeId: 2);
    } catch (e) {
      throw Exception('An error occurred');
    }
  }

}
