import 'package:flutter/material.dart';

Future<TimeOfDay?> showTimer(TimeOfDay initTime, BuildContext context) async {
  return showTimePicker(
    initialTime: initTime,
    context: context,
  );
}
