import 'package:flutter/material.dart';
import 'package:attendance_tasks/main.dart';

Future<void> selectDate(Function(DateTime) setPickedDate) async {
  final now = DateTime.now();
  final picked = await showDatePicker(
    context: navigatorKey.currentContext!,
    initialDate: now,
    firstDate: now,
    lastDate: DateTime(now.year + 5),
  );
  if (picked != null) {
    setPickedDate(picked);
  }
}
