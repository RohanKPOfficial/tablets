import 'package:flutter/material.dart';

Future<TimeOfDay?> showTimer(TimeOfDay initTime, BuildContext context) async {
  return showTimePicker(
    initialTime: initTime,
    context: context,
  );
}

bool EarlierThanNow(int hour, int minute) {
  TimeOfDay now = TimeOfDay.now();
  if (hour == now.hour && minute <= now.minute || hour < now.hour) {
    return true;
  } else {
    return false;
  }
}
