import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tablets/Models/Medicine.dart';
import 'package:tablets/Models/inventoryItem.dart';
import 'package:tablets/Repository/dblink.dart';
import 'package:tablets/Models/reminderList.dart' as rem;
import '../Repository/DBInterfacer.dart';

class ScheduleList implements DBSerialiser {
  late List<Schedule> scheduleList;

  ScheduleList(List<Schedule> mylist) {
    scheduleList = mylist;
  }

  ScheduleList getWeeklySchedules(List<int> days) {
    List<Schedule> newSchedules = [];
    for (int j = 0; j < scheduleList.length; j++) {
      for (int i = 0; i < days.length; i++) {
        Schedule s = scheduleList[j].copyWith();
        s.day = days[i];
        print('Set day to ${days[i]} @${s.toMap()}');
        newSchedules.add(s);
        print('new schedules @ iter : ${i}');
        newSchedules.forEach((element) {
          print(element.toMap());
        });
      }
    }
    print('new schedules');
    newSchedules.forEach((element) {
      print(element.toMap());
    });
    return ScheduleList(newSchedules);
  }

  ScheduleList getMonthlySchedules(List<int> dates) {
    List<Schedule> newSchedules = [];
    for (int j = 0; j < scheduleList.length; j++) {
      for (int i = 0; i < dates.length; i++) {
        Schedule s = scheduleList[j].copyWith();
        s.date = dates[i];
        print('Set day to ${dates[i]} @${s.toMap()}');
        newSchedules.add(s);
        print('new schedules @ iter : ${i}');
        newSchedules.forEach((element) {
          print(element.toMap());
        });
      }
    }
    print('new schedules');
    newSchedules.forEach((element) {
      print(element.toMap());
    });
    return ScheduleList(newSchedules);
  }

  @override
  Map<String, dynamic> toMap() {
    String listContents = '[';
    for (int i = 0; i < scheduleList.length; i++) {
      listContents += jsonEncode(scheduleList[i].toMap());
      if (i != scheduleList.length - 1) {
        listContents += ',';
      } else {
        listContents += ']';
      }
    }
    if (scheduleList.isEmpty) {
      listContents = '[]';
    }
    Map<String, dynamic> result = {'scheduleList': listContents};
    // print(result);

    return result;
  }

  void Modify(List<Schedule> mylist) {
    this.scheduleList = mylist;
  }

  static List<Schedule> toList(String jsonString) {
    var list = json.decode(jsonString);
    // print('decoded 2 list ${list[0]}');

    if (list.length == 0) {
      return [];
    } else {
      return List.generate(
          list.length, (index) => Schedule.toObject(list[index]));
    }
  }

  @override
  static toObject(String jsonString) {
    var decoded = json.decode(jsonString.substring(1, jsonString.length - 1));
    List<Schedule> list = ScheduleList.toList(decoded["scheduleList"]);

    /*   list = List.from(decoded["scheduleList"]);*/

    return ScheduleList(list);
  }
}

class Schedule implements DBSerialiser {
  int hour = 0, minute = 0, day = 0, date = 0, month = 0;
  double dosage = 0.0;

  Schedule(
      {int hour = 0,
      int minute = 0,
      int day = 0,
      int date = 0,
      int month = 0,
      double dosage = 0.0}) {
    this.hour = hour;
    this.minute = minute;
    this.day = day;
    this.date = date;
    this.month = month;
    this.dosage = dosage;
  }

  Schedule copyWith() {
    return new Schedule(
        hour: this.hour,
        minute: this.minute,
        day: this.day,
        date: this.date,
        month: this.month,
        dosage: this.dosage);
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'hour': hour,
      'minute': minute,
      'day': day,
      'date': date,
      'month': month,
      'dosage': dosage
    };
  }

  @override
  static toObject(Map<String, dynamic> decoded) {
    return Schedule(
        hour: decoded['hour'],
        minute: decoded['minute'],
        day: decoded['day'],
        date: decoded['date'],
        month: decoded['month'],
        dosage: decoded['dosage']);
  }
}

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

  static Schedule ToSchedule(TimeOfDay td) {
    return Schedule(hour: td.hour, minute: td.minute);
  }

  List<Schedule> toScheduleList() {
    List<Schedule> returnList = [];
    for (TimeOfDay td in myList) {
      returnList.add(ToSchedule(td));
    }
    return returnList;
  }
}
