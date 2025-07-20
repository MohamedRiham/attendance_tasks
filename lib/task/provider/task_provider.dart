import 'package:attendance_tasks/task/models/task.dart';
import 'package:flutter/material.dart';
import 'package:hive_local_storage/hive_local_storage.dart';
import 'package:uuid/uuid.dart';

class TaskProvider with ChangeNotifier {
  final LocalStorage? database;
  List<Task> tasks = [];

  TaskProvider(this.database);

  Future<void> addTask(Task task) async {
    try {
      var id = Uuid().v4();
      task.id = id;

      await database?.add(boxName: 'task_box', value: task);
      tasks.add(task);
      notifyListeners();
    } catch (_) {
      throw Exception('An error occurred');
    }
  }

  Future<void> loadTasks() async {
    try {
      tasks = database?.values<Task>('task_box') ?? [];
      notifyListeners();
    } catch (_) {
      throw Exception('Failed to load tasks');
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      final index = tasks.indexWhere((t) => t.id == task.id);
      tasks[index] = task;

      await database?.update(boxName: 'task_box', value: task);
      notifyListeners();
    } catch (_) {
      throw Exception('An error occurred');
    }
  }
}
