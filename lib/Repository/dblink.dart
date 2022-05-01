import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as Path;
import 'package:tablets/Models/Medicine.dart';
import 'package:tablets/Models/inventoryItem.dart';

import '../Blocs/InventoryProvider.dart';
import '../Models/reminderList.dart';

class DatabaseLink {
  var dbInstance;
  // var inventoryDBInstance;
  static late DatabaseLink link;
  DatabaseLink() {
    link = this;
  }

  Future<int> InitDB() async {
    int initCode = 0;
    dbInstance = await openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      Path.join(await getDatabasesPath(), 'tablets_database_3.db'),

      onCreate: (db, version) async {
// Run the CREATE TABLE statement on the database.
        await db.execute(
          'CREATE TABLE Medicines(Name TEXT PRIMARY KEY, Type VARCHAR);',
        );
        await db.execute(
          'CREATE TABLE Inventory(medicine TEXT PRIMARY KEY,slist TEXT ,medStock TEXT);',
        );
        // ,CONSTRAINT fk_Medicines FOREIGN KEY (Name) REFERENCES Medicines(Name)'
        // db.execute(
        //     '');
      },
      version: 1,
    ).whenComplete(() => initCode = 1);

    return initCode;
  }

  void InsertMedicine(Medicine med) async {
    var db = await dbInstance;

    await db.insert('Medicines', med.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);

    print('inserted medicine');
  }

  Future<List<Medicine>> getMedicines() async {
    final List<Map<String, dynamic>> maps = await dbInstance.query('Medicines');
    print("Avail meds ${maps.length}");
    List<Medicine> allMedicines = List.generate(maps.length, (i) {
      return Medicine(maps[i]['Name'], isMedType(maps[i]['Type']));
    });
    return allMedicines;
  }

  Future<List<InventoryItem>> getInventoryItems() async {
    final List<Map<String, dynamic>> maps = await dbInstance.query('Inventory');

    List<InventoryItem> allItems = List.generate(maps.length, (i) {
      InventoryItem item =
          InventoryItem(Medicine.toObject(maps[i]['medicine']));
      item.dumpSchedule(ScheduleList.toObject(maps[i]['slist']));
      String StockString = maps[i]['medStock'];
      // print(
      //     "stock ${double.parse(StockString.substring(1, StockString.length - 1))}");
      item.dumpStock(
          double.parse(StockString.substring(1, StockString.length - 1)));
      return item;
    });
    return allItems;
  }

  Future<int> UpdateInventoryItem(
      InventoryItem updatedItem, Medicine med) async {
    // InventoryItem i =await getInventoryByMedicine(medicine);

    var db = await dbInstance;
    await db.update('Inventory', updatedItem.toMap(),
        where:
            'medicine  like \'\'\'{"Name":"${med.Name}","Type":"${med.Type.name}"}\'\'\'');
    return 0;
  }

  void InsertInventoryItem(InventoryItem i) async {
    this.InsertMedicine(i.medicine);

    print('Inventory to be inserted');
    print(i.toMap().toString());

    try {
      var db = await dbInstance;

      db.insert(
        'Inventory',
        i.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      InventoryRecon.instance.update();
    } catch (e) {
      print("Caught here ${e}");
    }
  }

  void deleteInventoryItem(InventoryItem i) async {
    var db = await dbInstance;
    db.delete('Inventory', where: 'medicine=${i.medicine.toMap()}');
  }

  static Future<InventoryItem> getInventoryByMedicine(Medicine med) async {
    var db = await DatabaseLink.link.dbInstance;

    List<Map<String, dynamic>> result = await db.query('Inventory',
        where:
            'medicine  like \'\'\'{"Name":"${med.Name}","Type":"${med.Type.name}"}\'\'\'');
    InventoryItem item =
        InventoryItem(Medicine.toObject(result[0]['medicine']));
    item.dumpSchedule(ScheduleList.toObject(result[0]['slist']));
    String StockString = result[0]['medStock'];
    item.dumpStock(
        double.parse(StockString.substring(1, StockString.length - 1)));
    return item;
  }
}
