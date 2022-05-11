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

  Future update() async {
    if (currentInventory.length == 0) {
      print("empty inventory");
    }
    currentInventory = await DatabaseLink.link.getInventoryItems();
    notifyListeners();
  }

  List<InventoryItem> getInventory() {
    return currentInventory;
  }
}
