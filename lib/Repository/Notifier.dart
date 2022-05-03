import 'dart:ui';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:tablets/Models/Medicine.dart';
import 'package:tablets/Models/inventoryItem.dart';
import 'package:tablets/Models/reminderList.dart';

import 'dblink.dart';

void initNotificationService() {
  AwesomeNotifications().initialize(
      // set the icon to null if you want to use the default app icon
      null //'resource://drawable/res_app_icon'
      ,
      [
        NotificationChannel(
            channelGroupKey: 'basic_channel_group',
            channelKey: 'AlertTone1',
            channelName: 'Dosage Reminders',
            channelDescription: 'Scheduled Reminders for your medication',
            defaultColor: Color(0xFF9D50DD),
            ledColor: Colors.white,
            playSound: true,
            locked: true,
            soundSource: 'resource://raw/tone'),
      ],
      // Channel groups are only visual and are not required
      channelGroups: [
        NotificationChannelGroup(
            channelGroupkey: 'basic_channel_group',
            channelGroupName: 'Tablets Reminders')
      ],
      debug: true);

  AwesomeNotifications().actionStream.listen((action) async {
    if (action != null) {
      if (action.buttonKeyPressed == "MarkTaken") {
        Map<String, String> receivedPayload = action.payload!;

        String medName = receivedPayload["MedicineName"].toString();
        String medType = receivedPayload["MedicineType"].toString();
        double Dosage = (double.parse(receivedPayload["Dosage"].toString()));
        Medicine med = Medicine(medName, isMedType(medType));

        int _success = await DatabaseLink.ConsumeMedicine(med, Dosage);
        if (_success == 1) {
          print("MarkTaken");
          AwesomeNotifications().dismiss(action.id!);
        } else {
          print("Unable to consume");
        }
      } else if (action.buttonKeyPressed == "Snooze") {
        print("Snoozed");
        Snooze10min(action);
        AwesomeNotifications().dismiss(action.id!);
      }
    }
  });
}

void ScheduleImmediateNotif(Medicine medicine, String Dosage) async {
  print("notification scheduled immediate");
  AwesomeNotifications().createNotification(
      content: NotificationContent(
          payload: {
            "MedicineName": "${medicine.Name}",
            "MedicineType": "${medicine.Type.name}",
            "Dosage": "$Dosage"
          },
          autoDismissible: false,
          // customSound: 'resource://raw/tone',
          id: DateTime.now().millisecond.hashCode,
          channelKey: 'AlertTone1',
          title: 'Time to take your Medicines',
          body: '${medicine.Name} ${Dosage} ${medicine.Type.name}'),
      actionButtons: [
        NotificationActionButton(
            key: 'MarkTaken',
            label: 'MarkTaken',
            autoDismissible: false,
            buttonType: ActionButtonType.KeepOnTop),
        NotificationActionButton(
            key: 'Snooze', label: 'Snooze 10min', autoDismissible: false)
      ],
      schedule: NotificationCalendar(
          repeats: false,
          month: DateTime.now().month,
          weekday: DateTime.now().weekday,
          day: DateTime.now().day,
          hour: DateTime.now().hour,
          minute: DateTime.now().minute,
          second: DateTime.now().second + 5));
}

void Snooze10min(ReceivedAction action) {
  Map<String, String> load = action.payload!;
  String medName = load["MedicineName"].toString();
  String medType = load["MedicineType"].toString();
  String dosage = load["Dosage"].toString();
  DateTime snoozeTime = DateTime.now().add(Duration(minutes: 10));
  scheduleOneTimeNotification(Medicine(medName, isMedType(medType)), dosage,
      snoozeTime.hour, snoozeTime.minute);
}

void scheduleOneTimeNotification(
    Medicine medicine, String Dosage, int hour, int minute) async {
  print("notification scheduled at ${hour} ${minute}");
  AwesomeNotifications().createNotification(
      content: NotificationContent(
          payload: {
            "MedicineName": "${medicine.Name}",
            "MedicineType": "${medicine.Type.name}",
            "Dosage": "$Dosage"
          },
          autoDismissible: false,
          // customSound: 'resource://raw/tone',
          id: DateTime.now().millisecond.hashCode,
          channelKey: 'AlertTone1',
          title: 'Time to take your Medicines',
          body: '${medicine.Name} ${Dosage} ${medicine.Type.name}'),
      actionButtons: [
        NotificationActionButton(
            key: 'MarkTaken',
            label: 'MarkTaken',
            autoDismissible: false,
            buttonType: ActionButtonType.KeepOnTop),
        NotificationActionButton(
            key: 'Snooze', label: 'Snooze 10min', autoDismissible: false)
      ],
      schedule: NotificationCalendar(
          repeats: false, hour: hour, minute: minute, second: 0)
      // Future.delayed(Duration(seconds: 3), () {
      //   newNOtfy();
      //}
      );
}

void scheduleDailyNotification(
    Medicine medicine, String Dosage, int hour, int minute) async {
  print("notification scheduled at ${hour} ${minute}");
  AwesomeNotifications().createNotification(
      content: NotificationContent(
          payload: {
            "MedicineName": "${medicine.Name}",
            "MedicineType": "${medicine.Type.name}",
            "Dosage": "$Dosage"
          },
          autoDismissible: false,
          // customSound: 'resource://raw/tone',
          id: DateTime.now().millisecond.hashCode,
          channelKey: 'AlertTone1',
          title: 'Time to take your Medicines',
          body: '${medicine.Name} ${Dosage} ${medicine.Type.name}'),
      actionButtons: [
        NotificationActionButton(
            key: 'MarkTaken',
            label: 'MarkTaken',
            autoDismissible: false,
            buttonType: ActionButtonType.KeepOnTop),
        NotificationActionButton(
            key: 'Snooze', label: 'Snooze 10min', autoDismissible: false)
      ],
      schedule: NotificationCalendar(
          repeats: true,
          // month: DateTime.now().month,
          // weekday: DateTime.now().weekday,
          // day: DateTime.now().day,
          hour: hour,
          minute: minute,
          second: 0)
      // Future.delayed(Duration(seconds: 3), () {
      //   newNOtfy();
      //}
      );
}

void bulkScheduleDailyNotification(
    ScheduleList list, Medicine medicine, String Dosage) async {
  // List<InventoryItem> a = await DatabaseLink.link.getInventoryItems();
  InventoryItem i = await DatabaseLink.getInventoryByMedicine(medicine);
  List<Schedule> getList = i.slist.scheduleList;
  list.scheduleList.forEach((element) {
    getList.add(element);
  });
  i.dumpSchedule(ScheduleList(getList));
  await DatabaseLink.link.UpdateInventoryItem(i, medicine);

  for (Schedule s in list.scheduleList) {
    scheduleDailyNotification(i.medicine, Dosage, s.hour, s.minute);
  }
  InventoryItem inew = await DatabaseLink.getInventoryByMedicine(medicine);
  print('new schedule');
  print(inew.toMap());
}

void AddReminder(String medName, String Dosage) async {
  AwesomeNotifications().createNotification(
      content: NotificationContent(
          // customSound: 'resource://raw/tone',
          id: DateTime.now().millisecond.hashCode,
          channelKey: 'ch2',
          title: 'Time to take your Medicines',
          body: '${medName} ${Dosage}'),
      schedule: NotificationCalendar(
          repeats: false,
          month: DateTime.now().month,
          weekday: DateTime.now().weekday,
          day: DateTime.now().day,
          hour: DateTime.now().hour,
          millisecond: DateTime.now().millisecond,
          second: DateTime.now().second)
      // Future.delayed(Duration(seconds: 3), () {
      //   newNOtfy();
      //}
      );
}

void CancelAllSchedules() {
  AwesomeNotifications().cancelAllSchedules();
}
