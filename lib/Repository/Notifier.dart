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
            defaultColor: Colors.green,
            ledColor: Colors.white,
            playSound: true,
            locked: true,
            importance: NotificationImportance.Max,
            channelShowBadge: true,
            soundSource: 'resource://raw/tone'),
        NotificationChannel(
            channelGroupKey: 'basic_channel_group',
            channelKey: 'lowStockReminder',
            channelName: 'LowStockReminders',
            channelDescription: 'Time to buy Medicines',
            defaultColor: Colors.green,
            ledColor: Colors.white,
            playSound: true,
            locked: false,
            importance: NotificationImportance.Max,
            channelShowBadge: true,
            soundSource: 'resource://raw/low_stock'),
        NotificationChannel(
            channelGroupKey: 'basic_channel_group',
            channelKey: 'noStockReminder',
            channelName: 'NoStockReminders',
            channelDescription: 'Time to buy Medicines',
            defaultColor: Colors.green,
            ledColor: Colors.white,
            playSound: true,
            locked: false,
            importance: NotificationImportance.Max,
            channelShowBadge: true,
            soundSource: 'resource://raw/cant_consume'),
        NotificationChannel(
            channelGroupKey: 'basic_channel_group',
            channelKey: 'AllDone',
            channelName: 'Sleep Tight',
            channelDescription: 'Relax all meds taken',
            defaultColor: Colors.green,
            ledColor: Colors.white,
            playSound: true,
            locked: false,
            importance: NotificationImportance.Default,
            channelShowBadge: true,
            soundSource: 'resource://raw/cant_consume'),
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
            "NotifId": '${s.NotifId}',
            "orgTime":
                '${s.hour % 12 == 0 ? 12 : s.hour % 12}:${s.minute}${s.hour >= 12 ? 'pm' : 'am'}'
          },
          notificationLayout: NotificationLayout.BigPicture,
          bigPicture: 'asset://Images/gif1.gif',
          autoDismissible: false,
          locked: true,
          wakeUpScreen: true,
          id: s.NotifId!,
          channelKey: 'alerttone1',
          title: 'Time to take your Medicines',
          body: '${medicine.Name} ${Dosage} ${medicine.Type.name}'),
      actionButtons: [
        NotificationActionButton(
            key: 'MarkTaken',
            label: 'MarkTaken',
            autoDismissible: false,
            actionType: ActionType.KeepOnTop),
        NotificationActionButton(
            key: 'Snooze',
            label: 'Snooze 10min',
            autoDismissible: false,
            actionType: ActionType.KeepOnTop)
      ],
      schedule: calendar);
}

//delayed schedule
void Snooze10min(ReceivedAction action) {
  try {
    Map<String, String> load = action.payload!;
    String medName = load["MedicineName"].toString();
    String medType = load["MedicineType"].toString();
    int Sid = int.parse(load["SId"].toString());
    int MedId = int.parse(load["MedId"]!);
    String dosage = load["Dosage"].toString();
    int NotifId = int.parse(load["NotifId"].toString());
    String orgTime = load["orgTime"].toString();
    DateTime snoozeTime = DateTime.now().add(Duration(minutes: 1));
    Medicine med = Medicine(medName, isMedType(medType));
    med.Id = MedId;

    print(WidgetsBinding.instance?.lifecycleState.toString());
    scheduleNotificationOnce(
        med, dosage, snoozeTime.hour, snoozeTime.minute, Sid, NotifId, orgTime);
  } catch (e) {
    print(e);
  } finally {
    print("done576");
  }
}

void NoInventoryNotif(String MedName) {
  AwesomeNotifications().createNotification(
    content: NotificationContent(
        payload: {"MedName": MedName},
        autoDismissible: true,
        locked: false,
        notificationLayout: NotificationLayout.BigPicture,
        bigPicture: 'asset://Images/8712cbcfca47a97413070306f00de56a.gif',
        id: DateTime.now().microsecond,
        channelKey: 'noStockReminder',
        title: 'No stocks available in inventory for ${MedName}!',
        body: 'Forgot to update medicine restock?Tap Update or Order'),
    actionButtons: [
      NotificationActionButton(
          key: 'OnlineMedSearch',
          label: 'Order Medicine',
          autoDismissible: false,
          actionType: ActionType.Default),
      NotificationActionButton(
          key: 'UpdateStocks',
          label: 'Update Inventory',
          autoDismissible: true,
          actionType: ActionType.Default)
    ],
  );
}

void LowStockNotif(String lowStockMed, int left) {
  AwesomeNotifications().createNotification(
    content: NotificationContent(
        payload: {"MedName": lowStockMed},
        autoDismissible: false,
        locked: false,
        notificationLayout: NotificationLayout.BigText,
        id: DateTime.now().microsecond + 8,
        channelKey: 'lowStockReminder',
        title: 'Low Stocks for Meds!',
        body: 'Shop for meds before they run out. Tap order to order online.'
            '* ${lowStockMed} only ${left} units left'),
    actionButtons: [
      NotificationActionButton(
          key: 'OnlineMedSearch',
          label: 'Order Medicine',
          autoDismissible: false,
          actionType: ActionType.Default)
    ],
  );
}

void AllTodosDoneNotif() {
  AwesomeNotifications().createNotification(
    content: NotificationContent(
        autoDismissible: false,
        locked: false,
        bigPicture: 'asset://Images/allDone.jpg',
        notificationLayout: NotificationLayout.BigPicture,
        id: DateTime.now().microsecond + 8,
        channelKey: 'AllDone',
        title: 'All meds taken for today',
        body: 'Congrats all meds in health issues out.'),
  );
}

void scheduleNotificationOnce(Medicine medicine, String Dosage, int hour,
    int minute, int SId, int NotifId, String orgTime) {
  print("notification scheduled immonfo $hour $minute");
  // await (Future.delayed(Duration(seconds: 2)));
  AwesomeNotifications().createNotification(
      content: NotificationContent(
          payload: {
            "MedId": "${medicine.Id}",
            "MedicineName": "${medicine.Name}",
            "MedicineType": "${medicine.Type.name}",
            "Dosage": "$Dosage",
            "SId": '${SId}',
            "NotifId": '${NotifId}',
            "orgTime": orgTime
          },
          autoDismissible: false,
          locked: true,
          notificationLayout: NotificationLayout.BigPicture,
          bigPicture: 'asset://Images/gif6.gif',
          id: NotifId,
          channelKey: 'alerttone1',
          title:
              'Alert : Late for your medicines @ ${orgTime}. Take meds ASAP!',
          body: '${medicine.Name} ${Dosage} ${medicine.Type.name}'),
      actionButtons: [
        NotificationActionButton(
            key: 'MarkTaken',
            label: 'MarkTaken',
            autoDismissible: false,
            actionType: ActionType.KeepOnTop),
        NotificationActionButton(
            key: 'Snooze',
            label: 'Snooze 10min',
            autoDismissible: false,
            actionType: ActionType.KeepOnTop)
      ],
      schedule: NotificationCalendar(
        day: DateTime.now().day,
        weekday: DateTime.now().weekday,
        hour: hour,
        minute: minute,
        second: 0,
        repeats: false,
      ));
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

//cancelALlSchedules
void CancelAllSchedules() {
  AwesomeNotifications().cancelAllSchedules();
}

void cancelSchedule(int NotifId) async {
  AwesomeNotifications().cancel(NotifId);
}
