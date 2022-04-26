import 'package:flutter/material.dart';

class ReminderTimeList with ChangeNotifier {
  late List myList;
  ReminderTimeList(List<TimeOfDay> timeList) {
    myList = timeList;
  }

  regen(int length) {
    myList = List.generate(
        length,
        (index) => TimeOfDay.fromDateTime(
            DateTime.now().add(Duration(minutes: index))));
    notifyListeners();
  }

  regenIncrement() {
    myList.add(TimeOfDay.now());
    notifyListeners();
  }

  regenDecrement() {
    myList.removeLast();
    notifyListeners();
  }

  modify(int index, TimeOfDay td) {
    myList[index] = td;
    notifyListeners();
  }

  get(int index) {
    return myList[index];
  }
}
