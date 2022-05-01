import 'dart:convert';

import 'package:tablets/Repository/DBInterfacer.dart';

import 'package:tablets/Models/Medicine.dart';
import 'reminderList.dart';

class InventoryItem implements DBSerialiser {
  late Medicine medicine;
  ScheduleList slist = ScheduleList(List<Schedule>.empty());
  double medStock = 0;

  InventoryItem(Medicine medicine) {
    this.medicine = medicine;
  }

  dumpSchedule(ScheduleList list) {
    this.slist = list;
  }

  dumpStock(double Stock) {
    this.medStock = Stock;
  }

  incrementStock(int newUnits) {
    this.medStock += newUnits;
  }

  decrementStock(double consumedUnits) {
    this.medStock -= consumedUnits;
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'medicine': '\'${json.encode(medicine.toMap())}\'',
      'slist': '\'${json.encode(slist.toMap())}\'',
      'medStock': '\'${jsonEncode(medStock)}\''
    };
  }

  @override
  static toObject(String jsonString) {
    var decoded = json.decode(jsonString.substring(1, jsonString.length - 1));

    InventoryItem i = new InventoryItem(Medicine.toObject(decoded['medicine']));
    i.dumpStock(double.parse(decoded['medStock']));
    i.dumpSchedule(ScheduleList.toObject(decoded['slist']));

    return i;
  }
}
