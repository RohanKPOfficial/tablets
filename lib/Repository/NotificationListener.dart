import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:tablets/BlocsNProviders/InventoryProvider.dart';
import 'package:tablets/BlocsNProviders/TodoProvider.dart';
import 'package:tablets/Components/meddetails.dart';
import 'package:tablets/Config/partenrlinks.dart';
import 'package:tablets/Repository/Notifier.dart';
import 'package:tablets/Repository/dblink.dart';
import 'navkey.dart';

class NotificationReaction {
  static Future<void> onActionReceivedMethod(ReceivedAction action) async {
    if (action.actionType == ActionType.Default) {
      onTapAction tapAction = toOnTapAction(action.payload!["onTapAction"]!);
      switch (tapAction) {
        case onTapAction.NoInv:
          if (action.actionLifeCycle == NotificationLifeCycle.Foreground ||
              action.actionLifeCycle == NotificationLifeCycle.Background) {
            int InvId =
                (InventoryRecon().getInvIndex(action.payload!['MedName']!));
            navkey.currentState!.push(MaterialPageRoute(
                builder: (context) => MedDetails(InvIndex: (InvId))));
          }

          break;
        case onTapAction.LoStock:
          LaunchPartenerSite();
          break;
        case onTapAction.Reminder:
          break;
        default:
          break;
      }
    } else {
      //here if user taps on an action button
      if (action.buttonKeyPressed == "MarkTaken") {
        Map<String, String> receivedPayload = action.payload!;
        int MedId = int.parse(receivedPayload["MedId"]!);
        String medName = receivedPayload["MedicineName"].toString();
        String medType = receivedPayload["MedicineType"].toString();
        int SId = int.parse(action.payload!['SId'].toString());
        double Dosage = (double.parse(receivedPayload["Dosage"].toString()));

        int _success =
            await DatabaseLink.ConsumeMedicine(MedId, medName, Dosage, SId);

        if (_success == 1) {
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
        }
      } else if (action.buttonKeyPressed == "Snooze") {
        Snooze10min(action);
        AwesomeNotifications().dismiss(action.id!);
      } else if (action.buttonKeyPressed == "OrderOnline") {
        LaunchPartenerSite();
        AwesomeNotifications().dismiss(action.id!);
      } else if (action.buttonKeyPressed == "OnlineMedSearch") {
        LaunchPartenerSite(action.payload!['MedName']?.toString());
        AwesomeNotifications().dismiss(action.id!);
      }
    }
  }

  static Future<void> onDisplayedAction(ReceivedNotification action) async {
    if (action.displayedLifeCycle == NotificationLifeCycle.Foreground ||
        action.displayedLifeCycle == NotificationLifeCycle.Background) {
      TodoProvider().updateFetch();
    }
  }
}
