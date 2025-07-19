import 'package:hive_local_storage/hive_local_storage.dart';

part 'task.g.dart';

@HiveType(typeId: 2, adapterName: 'TaskAdapter')
class Task extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;

  @HiveField(2)
  final DateTime dueDate;

  @HiveField(3)
  final String priority;

  @HiveField(4)
  final String status;

  Task({
    required this.id,
    required this.name,
    required this.dueDate,
    required this.priority,
    required this.status,
  });
}
