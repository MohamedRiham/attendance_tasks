import 'package:hive_local_storage/hive_local_storage.dart';

part 'attendance.g.dart';

@HiveType(typeId: 1, adapterName: 'AttendanceAdapter')
class Attendance extends HiveObject {
  @HiveField(0)
 String id;
  @HiveField(1)
 DateTime? date;
  @HiveField(2)
 String? dayName;
  @HiveField(3)
 String? checkInTime;
  @HiveField(4)
String? checkOutTime;
  @HiveField(5)
 String? timeSpent;
  @HiveField(6)
 String? attendanceStatus;

 Attendance({
    required this.id,
     this.date,
     this.dayName,
     this.checkInTime,
     this.checkOutTime,
     this.timeSpent,
     this.attendanceStatus,
  });
}
