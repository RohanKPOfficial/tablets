import 'dart:convert';

import 'package:flutter/material.dart';
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
        newSchedules.add(s);
      }
    }
    return ScheduleList(newSchedules);
  }

  ScheduleList getMonthlySchedules(List<int> dates) {
    List<Schedule> newSchedules = [];
    for (int j = 0; j < scheduleList.length; j++) {
      for (int i = 0; i < dates.length; i++) {
        Schedule s = scheduleList[j].copyWith();
        s.date = dates[i];

        newSchedules.add(s);
      }
    }
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

    return result;
  }

  void Modify(List<Schedule> mylist) {
    scheduleList = mylist;
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
  int? Id;
  int? NotifId;
  late int MedId;
  late String Type;
  int hour = 0, minute = 0, day = 0, date = 0;

  double dosage = 0.0;

  Schedule(
      {int hour = 0,
      int minute = 0,
      int day = 0,
      int date = 0,
      Type = 'Daily',
      double dosage = 0.0,
      required MedId}) {
    this.hour = hour;
    this.minute = minute;
    this.day = day;
    this.date = date;
    this.dosage = dosage;
    this.MedId = MedId;
    this.Type = Type;
  }

  Schedule copyWith() {
    return Schedule(
        hour: hour,
        minute: minute,
        day: day,
        date: date,
        dosage: dosage,
        MedId: MedId,
        Type: Type);
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'MedId': MedId,
      'hour': hour,
      'minute': minute,
      'day': day,
      'date': date,
      'dosage': dosage,
      'Type': Type
    };
    if (Id != null) {
      map["Id"] = Id;
    }
    if (NotifId != null) {
      map['NotifId'] = NotifId;
    }
    return map;
  }

  @override
  static toObject(Map<String, dynamic> map) {
    Schedule s = Schedule(
      hour: map['hour'],
      minute: map['minute'],
      day: map['day'],
      date: map['date'],
      dosage: double.parse(map['dosage']),
      MedId: map['MedId'],
      Type: map['Type'],
    );
    s.NotifId = map['NotifId'];
    s.Id = map['Id'];
    return s;
  }
}

class ReminderTimeList with ChangeNotifier {
  late List<TimeOfDay> myList;

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
    myList.add(addTime(myList.last, 1));
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

  TimeOfDay addTime(TimeOfDay td, int minutes) {
    if (td.minute + minutes <= 59) {
      return TimeOfDay(hour: td.hour, minute: td.minute + minutes);
    } else {
      return TimeOfDay(hour: td.hour + 1, minute: (td.minute + minutes) % 60);
    }
  }

  static Schedule ToSchedule(TimeOfDay td, int MedId) {
    return Schedule(hour: td.hour, minute: td.minute, MedId: MedId);
  }

  List<Schedule> toScheduleList(int MedId) {
    List<Schedule> returnList = [];
    for (TimeOfDay td in myList) {
      returnList.add(ToSchedule(td, MedId));
    }
    return returnList;
  }
}
