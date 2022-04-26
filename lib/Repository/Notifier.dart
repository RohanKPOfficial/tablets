import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

void initNotificationService() {
  AwesomeNotifications().initialize(
      // set the icon to null if you want to use the default app icon
      null //'resource://drawable/res_app_icon'
      ,
      [
        NotificationChannel(
            channelGroupKey: 'basic_channel_group',
            channelKey: 'ch2',
            channelName: 'Dosage Reminders',
            channelDescription: 'Scheduled Reminders for your medication',
            defaultColor: Color(0xFF9D50DD),
            ledColor: Colors.white,
            playSound: true,
            soundSource: 'resource://raw/tone'),
      ],
      // Channel groups are only visual and are not required
      channelGroups: [
        NotificationChannelGroup(
            channelGroupkey: 'basic_channel_group',
            channelGroupName: 'Tablets Reminders')
      ],
      debug: true);

  AwesomeNotifications()
      .actionStream
      .listen((ReceivedNotification receivedNotification) {
    if (receivedNotification != null) {
      print("Notification clicked and intercepted");
    }
  });
}

void newNOtfy() async {
  String localTimeZone =
      await AwesomeNotifications().getLocalTimeZoneIdentifier();
  String utcTimeZone =
      await AwesomeNotifications().getLocalTimeZoneIdentifier();
  AwesomeNotifications().createNotification(
      content: NotificationContent(
          // customSound: 'resource://raw/tone',
          id: DateTime.now().millisecond.hashCode,
          channelKey: 'ch2',
          title: 'Time to take your Medicines',
          body: 'Medicine Names'),
      schedule: NotificationCalendar(
          repeats: true,
          month: DateTime.now().month,
          weekday: DateTime.now().weekday,
          day: DateTime.now().day,
          hour: DateTime.now().hour,
          millisecond: 0,
          second: 0)
      // Future.delayed(Duration(seconds: 3), () {
      //   newNOtfy();
      //}
      );
}

void AddReminder(String medName, String Dosage) async {
  String localTimeZone =
      await AwesomeNotifications().getLocalTimeZoneIdentifier();
  String utcTimeZone =
      await AwesomeNotifications().getLocalTimeZoneIdentifier();
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
