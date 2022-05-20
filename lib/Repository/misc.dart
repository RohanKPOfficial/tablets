import 'package:flutter/material.dart';
import 'package:tablets/Models/reminderList.dart';

Color tileColor(double stock, int i) {
  if (stock == 0) {
    return Colors.redAccent;
  } else if (stock > i) {
    return Colors.green.shade400;
  } else {
    return Colors.orange;
  }
}

String getScheduleType(Schedule s) {
  if (s.day != 0) {
    return 'Weekly';
  } else if (s.date != 0) {
    return 'Monthly';
  } else {
    return 'Daily';
  }
}
