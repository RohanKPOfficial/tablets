import 'package:flutter/material.dart';
import 'package:tablets/Models/inventoryItem.dart';
import 'package:tablets/Repository/dblink.dart';

class InventoryRecon extends ChangeNotifier {
  static late final InventoryRecon instance;

  List<InventoryItem> currentInventory = [];

  InventoryRecon() {
    instance = this;
    update();
  }

  void update() async {
    currentInventory = await DatabaseLink.link.getInventoryItems();
    currentInventory.sort((InventoryItem i1, InventoryItem i2) {
      return i1.medicine.Name.compareTo(i2.medicine.Name);
    });
    notifyListeners();
  }

  List<InventoryItem> getInventory() {
    currentInventory.sort((InventoryItem i1, InventoryItem i2) {
      return i1.medicine.Name.compareTo(i2.medicine.Name);
    });
    return currentInventory;
  }
}
