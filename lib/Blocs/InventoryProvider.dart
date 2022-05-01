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
    notifyListeners();
  }

  List<InventoryItem> getInventory() {
    return currentInventory;
  }
}
