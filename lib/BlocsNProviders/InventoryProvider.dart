import 'package:flutter/material.dart';
import 'package:tablets/Models/inventoryItem.dart';
import 'package:tablets/Repository/dblink.dart';

class InventoryRecon extends ChangeNotifier {
  static late final InventoryRecon instance =
      InventoryRecon._internalConstructor();

  InventoryRecon._internalConstructor() {
    update();
  }

  List<InventoryItem> currentInventory = [];

  factory InventoryRecon() {
    // instance = this;
    // update();
    return instance;
  }

  int getInvIndex(String MedicineName) {
    for (int i = 0; i < currentInventory.length; i++) {
      if (currentInventory[i].medicine!.Name == MedicineName) {
        return i;
      }
    }
    return -1; //not found
  }

  Future update() async {
    currentInventory = await DatabaseLink.link.getInventoryItems();
    notifyListeners();
  }

  List<InventoryItem> getInventory() {
    return currentInventory;
  }
}
