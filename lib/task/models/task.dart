import 'package:hive_local_storage/hive_local_storage.dart';

part 'task.g.dart';

@HiveType(typeId: 2, adapterName: 'TaskAdapter')
class Task extends HiveObject {
  @HiveField(0)
 String id;
  @HiveField(1)
 String name;

  @HiveField(2)
 DateTime dueDate;

  @HiveField(3)
 String priority;

  @HiveField(4)
 String status;

  Task({
    required this.id,
    required this.name,
    required this.dueDate,
    required this.priority,
    required this.status,
  });
}
