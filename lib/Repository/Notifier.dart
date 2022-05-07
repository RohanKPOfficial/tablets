import 'dart:math';
import 'dart:ui';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:tablets/Models/Medicine.dart';
import 'package:tablets/Models/inventoryItem.dart';
import 'package:tablets/Models/reminderList.dart';
import 'package:tablets/Repository/NotificationListener.dart';
import 'package:tablets/Repository/Notifier.dart';

import '../BlocsNProviders//TodoProvider.dart';

import 'dblink.dart';

//init
void initNotificationService() {
  AwesomeNotifications().initialize(
      // set the icon to null if you want to use the default app icon
      null //'resource://drawable/res_app_icon'
      ,
      [
        NotificationChannel(
            channelGroupKey: 'basic_channel_group',
            channelKey: 'alerttone1',
            channelName: 'Dosage Reminders',
            channelDescription: 'Scheduled Reminders for your medication',
            defaultColor: Color(0xFF9D50DD),
            ledColor: Colors.white,
            playSound: true,
            locked: true,
            importance: NotificationImportance.Max,
            channelShowBadge: true,
            soundSource: 'resource://raw/tone'),
      ],
      // Channel groups are only visual and are not required
      channelGroups: [
        NotificationChannelGroup(
            channelGroupKey: 'basic_channel_group',
            channelGroupName: 'Tablets Reminders')
      ],
      debug: true);

  AwesomeNotifications().setListeners(
      onActionReceivedMethod: NotificationReaction.onActionReceivedMethod);
}

//schedule normal
Future bulkScheduleNotification(
    ScheduleList list, int MedId, String Dosage) async {
  // List<InventoryItem> a = await DatabaseLink.link.getInventoryItems();
  InventoryItem i = await DatabaseLink.link.getInventoryItemDeep(MedId);
  await SaveSchedules(list);
  for (Schedule s in list.scheduleList) {
    scheduleNotification(i.medicine!, Dosage, s);
  }
  return;
}

void scheduleNotification(Medicine medicine, String Dosage, Schedule s) async {
  NotificationCalendar calendar = getCalendar(s);
  print("notification scheduled at ${s.hour} ${s.minute}");
  AwesomeNotifications().createNotification(
      content: NotificationContent(
          payload: {
            "MedId": "${medicine.Id}",
            "MedicineName": "${medicine.Name}",
            "MedicineType": "${medicine.Type.name}",
            "Dosage": "$Dosage",
            "SId": '${s.Id}',
          },
          autoDismissible: false,
          // customSound: 'resource://raw/tone',
          id: s.NotifId!,
          channelKey: 'alerttone1',
          title: 'Time to take your Medicines',
          body: '${medicine.Name} ${Dosage} ${medicine.Type.name}'),
      actionButtons: [
        NotificationActionButton(
            key: 'MarkTaken',
            label: 'MarkTaken',
            autoDismissible: false,
            actionType: ActionType.SilentBackgroundAction),
        NotificationActionButton(
            key: 'Snooze',
            label: 'Snooze 10min',
            autoDismissible: false,
            actionType: ActionType.SilentAction)
      ],
      schedule: calendar);
}

//delayed schedule
void Snooze10min(ReceivedAction action) {
  Map<String, String> load = action.payload!;
  String medName = load["MedicineName"].toString();
  String medType = load["MedicineType"].toString();
  int Sid = int.parse(load["SId"].toString());
  int MedId = int.parse(load["MedId"]!);
  String dosage = load["Dosage"].toString();
  DateTime snoozeTime = DateTime.now().add(Duration(minutes: 1));
  Medicine med = Medicine(medName, isMedType(medType));
  med.Id = MedId;

  print(WidgetsBinding.instance?.lifecycleState.toString());
  scheduleNotificationOnce(
      med, dosage, snoozeTime.hour, snoozeTime.minute, Sid);
  // Schedule s = Schedule(MedId: med.Id);
  // s.hour = snoozeTime.hour;
  // s.minute = snoozeTime.minute;
  // scheduleNotification(med, dosage, s);
}

void scheduleNotificationOnce(
    Medicine medicine, String Dosage, int hour, int minute, int SId) async {
  print("notification scheduled at ${hour} ${minute}");
  await (Future.delayed(Duration(seconds: 2)));
  AwesomeNotifications().createNotification(
      content: NotificationContent(
          payload: {
            "MedId": "${medicine.Id}",
            "MedicineName": "${medicine.Name}",
            "MedicineType": "${medicine.Type.name}",
            "Dosage": "$Dosage",
            "SId": '${SId}'
          },
          autoDismissible: false,
          id: DateTime.now().millisecond.hashCode,
          channelKey: 'alerttone1',
          title: 'Alert : Late for your medicines . Take meds ASAP!',
          body: '${medicine.Name} ${Dosage} ${medicine.Type.name}'),
      actionButtons: [
        NotificationActionButton(
            key: 'MarkTaken',
            label: 'MarkTaken',
            autoDismissible: false,
            actionType: ActionType.SilentBackgroundAction),
        NotificationActionButton(
            key: 'Snooze',
            label: 'Snooze 10min',
            autoDismissible: false,
            actionType: ActionType.SilentBackgroundAction)
      ],
      schedule: NotificationCalendar(
          repeats: false, hour: hour, minute: minute, second: 0));
}

//misc
NotificationCalendar getCalendar(Schedule s) {
  late NotificationCalendar calendar;
  if (s.date == 0 && s.day == 0) {
    calendar = NotificationCalendar(
        repeats: true, hour: s.hour, minute: s.minute, second: 0);
  } else if (s.day != 0 && s.date == 0) {
    calendar = NotificationCalendar(
        repeats: true,
        hour: s.hour,
        minute: s.minute,
        weekday: s.day,
        second: 0);
  } else if (s.day == 0 && s.date != 0) {
    calendar = NotificationCalendar(
        repeats: true, hour: s.hour, minute: s.minute, day: s.date, second: 0);
  }
  return calendar;
}

Future<void> SaveSchedules(ScheduleList list) async {
  for (int i = 0; i < list.scheduleList.length; i++) {
    Random rand = Random();
    int NotifId = (DateTime.now().microsecond + rand.nextInt(1024));
    list.scheduleList[i].NotifId = NotifId;
    int SId = await DatabaseLink.link.InsertSchedule(list.scheduleList[i]);
    list.scheduleList[i].Id = SId;
  }
  return;
}

// void AddReminder(String medName, String Dosage) async {
//   AwesomeNotifications().createNotification(
//       content: NotificationContent(
//           // customSound: 'resource://raw/tone',
//           id: DateTime.now().millisecond.hashCode,
//           channelKey: 'ch2',
//           title: 'Time to take your Medicines',
//           body: '${medName} ${Dosage}'),
//       schedule: NotificationCalendar(
//           repeats: false,
//           month: DateTime.now().month,
//           weekday: DateTime.now().weekday,
//           day: DateTime.now().day,
//           hour: DateTime.now().hour,
//           millisecond: DateTime.now().millisecond,
//           second: DateTime.now().second)
//       // Future.delayed(Duration(seconds: 3), () {
//       //   newNOtfy();
//       //}
//       );
// }

//cancelALlSchedules
void CancelAllSchedules() {
  AwesomeNotifications().cancelAllSchedules();
}

void cancelSchedule(int NotifId) async {
  AwesomeNotifications().cancel(NotifId);
}
