import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:tablets/BlocsNProviders/TodoProvider.dart';
import 'package:tablets/Repository/Notifier.dart';
import 'package:tablets/Repository/dblink.dart';
import 'package:url_launcher/url_launcher.dart';

import '../BlocsNProviders/InventoryProvider.dart';
import '../Config/partenrlinks.dart';
import '../main.dart';

class NotificationReaction {
  static Future<void> onActionReceivedMethod(ReceivedAction action) async {
    if (action != null) {
      if (action.buttonKeyPressed == "MarkTaken") {
        // print("here");
        // AwesomeNotifications().dismiss(action.id!);
        Map<String, String> receivedPayload = action.payload!;
        int MedId = int.parse(receivedPayload["MedId"]!);
        ;
        String medName = receivedPayload["MedicineName"].toString();
        String medType = receivedPayload["MedicineType"].toString();
        int SId = int.parse(action.payload!['SId'].toString());
        double Dosage = (double.parse(receivedPayload["Dosage"].toString()));

        int _success =
            await DatabaseLink.ConsumeMedicine(MedId, medName, Dosage, SId);

        print("ScheduleId " + action.payload!['SId'].toString());
        if (_success == 1) {
          print("MarkTaken");
          print(
              "life cycle ${WidgetsBinding.instance?.lifecycleState.toString()}");
          if (WidgetsBinding.instance?.lifecycleState ==
                  AppLifecycleState.paused ||
              WidgetsBinding.instance?.lifecycleState ==
                  AppLifecycleState.resumed) {
            //if app is running and not killed update ui providers.

            await TodoProvider.sharedInstance.tds.updateTodos(available: true);
            TodoProvider.sharedInstance.notifyListeners();
            InventoryRecon().update();
          }
          AwesomeNotifications().dismiss(action.id!);
        } else {
          NoInventoryNotif(medName);
          print("Unable to consume");
        }
      } else if (action.buttonKeyPressed == "Snooze") {
        Snooze10min(action);
        AwesomeNotifications().dismiss(action.id!);
      } else if (action.buttonKeyPressed == "OrderOnline") {
        print("Ordering");
        LaunchPartenerSite();
      } else if (action.buttonKeyPressed == "OnlineMedSearch") {
        LaunchPartenerSite(action.payload!['MedName']?.toString());
      }
    }
  }
}
