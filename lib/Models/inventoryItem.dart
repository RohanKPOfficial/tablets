import 'dart:convert';

import 'package:tablets/Repository/DBInterfacer.dart';

import 'package:tablets/Models/Medicine.dart';
import 'reminderList.dart';

class InventoryItem implements DBSerialiser {
  Medicine? medicine;
  ScheduleList slist = ScheduleList(List<Schedule>.empty());
  double medStock = 0;
  int? MedId;
  int? Id;

  InventoryItem(int MedId) {
    this.MedId = MedId;
  }

  dumpMedicine(Medicine med) {
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
    // return {
    //
    //   'medicine': '\'${json.encode(medicine.toMap())}\'',
    //   'slist': '\'${json.encode(slist.toMap())}\'',
    //   'medStock': '\'${jsonEncode(medStock)}\''
    // };
    Map<String, dynamic> map = {
      "MedId": MedId,
      "medStock": medStock,
    };
    if (Id != null) {
      map["Id"] = Id;
    }
    return map;
  }

  @override
  static toObject(Map<String, dynamic> map) {
    // var decoded = json.decode(jsonString.substring(1, jsonString.length - 1));

    InventoryItem i = new InventoryItem(map["MedId"]);
    i.dumpStock(double.parse(map['medStock']));
    // i.dumpSchedule(ScheduleList.toObject(decoded['slist']));

    return i;
  }
}
