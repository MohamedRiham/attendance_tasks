import 'package:flutter/material.dart';
import 'package:shop_app/main.dart';

Future<void> selectTime(Function(TimeOfDay) setPickedDate) async {
  final TimeOfDay? picked = await showTimePicker(
    barrierDismissible: false,
    context: navigatorKey.currentContext!,
    initialTime: TimeOfDay.now(),
  );
  if (picked != null) {
    setPickedDate(picked);
  }
}
