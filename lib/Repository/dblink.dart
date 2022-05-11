import 'dart:convert';
import 'dart:ui';
import 'package:tablets/BlocsNProviders/InventoryProvider.dart';
import 'package:tablets/Models/DbTodo.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as Path;
import 'package:tablets/BlocsNProviders/TodoProvider.dart';
import 'package:tablets/Models/DbTodo.dart';
import 'package:tablets/Models/Medicine.dart';
import 'package:tablets/Models/TodoItem.dart';
import 'package:tablets/Models/TodoSchedules.dart';
import 'package:tablets/Models/inventoryItem.dart';
import 'package:tablets/Repository/dblink.dart';
import 'package:tablets/Models/reminderList.dart';

import 'Notifier.dart';

class DatabaseLink {
  var dbInstance, dbInstance2;
  // var inventoryDBInstance;
  static late DatabaseLink link;
  DatabaseLink() {
    link = this;
  }

  void RecreateTables() async {
    var db = await dbInstance2;
    await db.rawQuery('DROP DATABASE tablets_database_4');
    db.close();
    initNewDB();
  }

  Future<int> initNewDB() async {
    int initCode = 0;
    dbInstance2 = await openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      Path.join(await getDatabasesPath(), 'tablets_database_4.db'),
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
// Run the CREATE TABLE statement on the database.
        await (db.execute('PRAGMA foreign_keys = ON'));
        await db.execute(
            'CREATE TABLE Todo(Id INTEGER PRIMARY KEY AUTOINCREMENT,Date INTEGER , MONTH INTEGER);');

        await db.execute(
          'CREATE TABLE Medicines(Id INTEGER PRIMARY KEY AUTOINCREMENT,Name TEXT UNIQUE, Type VARCHAR);',
        );
        await db.execute(
          'CREATE TABLE Inventory(Id INTEGER PRIMARY KEY AUTOINCREMENT,MedId INTEGER UNIQUE,medStock TEXT ,FOREIGN KEY (MedId) REFERENCES Medicines(Id) ON DELETE CASCADE ON UPDATE NO ACTION);',
        );

        await db.execute(
            'CREATE TABLE Schedules(Id INTEGER PRIMARY KEY AUTOINCREMENT,MedId INTEGER ,Type Text,date INTEGER ,day INTEGER,hour INTEGER,minute INTEGER ,dosage TEXT,NotifId INTEGER, FOREIGN KEY (MedId) REFERENCES Medicines(Id) ON DELETE CASCADE ON UPDATE NO ACTION);');
        await db.execute(
            'CREATE TABLE TodoSchedules(Id INTEGER PRIMARY KEY AUTOINCREMENT,SId INTEGER ,MId INTEGER,Marked INTEGER , FOREIGN KEY (SId) References Schedules(Id) ON DELETE CASCADE ON UPDATE NO ACTION , FOREIGN KEY (MId) References Medicines(Id) ON DELETE CASCADE ON UPDATE NO ACTION);');
      },
      version: 1,
    ).whenComplete(() => initCode = 1);

    return initCode;
  }

  Future<List<TodoItem>> getTodos() async {
    var db = await dbInstance2;
    List<Map<String, dynamic>> maps = await db.rawQuery(
        '''SELECT *,T.Id as 'TId',M.Id as'MId', S.Id as 'SId',M.Type as 'MType',S.Type as 'SType' FROM TODOSCHEDULES T JOIN SCHEDULES S ON T.SId=S.Id JOIN MEDICINES M ON M.Id=S.MedId''');
    List<TodoItem> items = List.generate(maps.length, (index) {
      Map<String, dynamic> medMap = {
        'Name': maps[index]['Name'],
        'Type': maps[index]['MType'],
        'Id': maps[index]['MId']
      };
      Map<String, dynamic> sMap = {
        'Id': maps[index]['SId'],
        'Type': maps[index]['SType'],
        'MedId': maps[index]['MedId'],
        'hour': maps[index]['hour'],
        'minute': maps[index]['minute'],
        'day': maps[index]['day'],
        'date': maps[index]['date'],
        'dosage': maps[index]['dosage']
      };

      TodoItem t = TodoItem(Medicine.toObject(medMap), Schedule.toObject(sMap));
      t.Id = maps[index]['TId'];
      t.done = maps[index]['Marked'] == 0 ? false : true;
      return t;
    });

    return items;
  }

  Future<void> MarkTodo(SId, {int markValue = 1}) async {
    var db = await dbInstance2;
    await db.rawQuery(
        '''UPDATE TodoSchedules SET Marked=${markValue} WHERE SId=${SId}''');
  }

  Future<int> InsertMedicine(Medicine med) async {
    try {
      var db = await dbInstance2;
      int id = await db.insert('Medicines', med.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);

      print('===Query Medicines=============');
      List<Map<String, dynamic>> result = await db.query('Medicines');
      result.forEach((ele) => {
            print("" +
                ele["Id"].toString() +
                " " +
                ele["Name"] +
                " " +
                ele["Type"] +
                " returned id" +
                id.toString())
          });

      return id;
    } catch (e) {
      print("Error " + e.toString());
      return -404; //error code
    }
  }

  Future<int> InsertInventoryItem(Medicine med) async {
    int MedId = await InsertMedicine(med);
    if (MedId == -404) {
      print("Insert medicine error");
      return -404;
    }
    InventoryItem i = InventoryItem(MedId);
    var db = await dbInstance2;
    int InvId = await db.insert(
      'Inventory',
      i.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return InvId;
  }

  Future<int> InsertSchedule(Schedule s) async {
    try {
      var db = await dbInstance2;
      int Sid = await db.insert('Schedules', s.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      if (isScheduledForToday(s)) {
        DbTodoSchedules dbts = DbTodoSchedules(Sid, s.MedId);
        await db.insert('TodoSchedules', dbts.toMap());
      }
      return Sid; //status code success
    } catch (e) {
      return -404; //error code
    }
  }

  bool isScheduledForToday(Schedule s) {
    if ((s.Type == 'Daily') ||
        (s.date == DateTime.now().day) ||
        (s.day == DateTime.now().weekday)) {
      return true;
    } else {
      return false;
    }
  }

  static Future<int> ConsumeMedicine(
      int MedId, String MedName, double units, int SId) async {
    InventoryItem i;
    try {
      i = await DatabaseLink.link.getInventoryItem(MedId);
    } catch (e) {
      print(e.toString());
      DatabaseLink();
      await DatabaseLink.link.initNewDB();
    } finally {
      i = await DatabaseLink.link.getInventoryItem(MedId);
    }

    if (i.medStock >= units) {
      i.medStock = i.medStock - units;

      print('consumed ${units} units new stcok ${i.medStock}');
    } else {
      return 0;
    }
    await DatabaseLink.link.updateStock(i.Id!, i.medStock);

    if (i.medStock < 10) {
      //10 is the low stock threshhold

      LowStockNotif(MedName, i.medStock.toInt());
    }

    if (WidgetsBinding.instance?.lifecycleState == AppLifecycleState.paused ||
        WidgetsBinding.instance?.lifecycleState == AppLifecycleState.resumed) {
      InventoryRecon.instance.update();
    }

    await TodoSchedules.MarkTodoBySId(SId);
    await DatabaseLink.link.allDoneCheckNNotify();
    return 1;
  }

  Future allDoneCheckNNotify() async {
    bool notify = await allMarked();
    if (notify) {
      AllTodosDoneNotif();
    }
    return;
  }

  Future<bool> allMarked() async {
    var batch = await dbInstance2.batch();
    batch.rawQuery("SELECT Count(*) as 'Total' from TodoSchedules");
    batch.rawQuery(
        "Select Count(*) as 'Marked' from TodoSchedules WHERE Marked=1");
    var results = await batch.commit();
    if (results[0][0]['Total'] == 0) {
      return false; //empty todos no schedules for today
    } else {
      return results[0][0]['Total'] == results[1][0]['Marked'] ? true : false;
    }
  }

  Future<List<InventoryItem>> getInventoryItems() async {
    var db = await dbInstance2;
    List<Map<String, dynamic>> maps = await db.rawQuery(
        '''Select i.Id as 'InvId' , i.MedId as 'MedId' ,medStock,Name,Type from Inventory i join Medicines m on i.MedId=m.Id''');

    List<InventoryItem> allItems = List.generate(maps.length, (i) {
      InventoryItem item = InventoryItem(maps[i]["MedId"]);

      String StockString = maps[i]['medStock'];
      item.Id = maps[i]["InvId"];
      item.dumpStock(double.parse(StockString));
      Medicine med = Medicine(maps[i]['Name'], isMedType(maps[i]['Type']));
      med.Id = int.parse(maps[i]['MedId'].toString());
      item.medicine = med;
      // element.slist = await getSListByMedId(element.MedId!);

      return item;
    });

    for (int i = 0; i < allItems.length; i++) {
      allItems[i].slist = await getSListByMedId(allItems[i].MedId!);
    }
    // allItems.forEach((e) async {
    //   e.slist = await getSListByMedId(e.MedId!);
    // });
    print(allItems.length.toString() + " Total Iteams7 in inventory");
    return allItems;
  } //checked

  Future<ScheduleList> getSListByMedId(int MedId) async {
    var db = await dbInstance2;
    List<Map<String, dynamic>> schedulesMapList =
        await db.query('Schedules', where: 'MedId=?', whereArgs: [MedId]);
    List<Schedule> scheduleList = [];
    schedulesMapList
        .forEach((ele) => {scheduleList.add(Schedule.toObject(ele))});
    ScheduleList slist = ScheduleList(scheduleList);
    return slist;
  } //checked

  Future<Medicine> getMedicineById(int MedId) async {
    var db = await dbInstance2;

    List<Map<String, dynamic>> medMaps = await db.query('Medicines',
        where: 'Id=?', whereArgs: [MedId], limit: 1);
    return Medicine.toObject(medMaps[0]);
  }
  //checked

  Future<List<TodoItem>> getTodoSchedules(int weekday, int day) async {
    var db = await dbInstance2;

    List<Map<String, dynamic>> maps = await db.rawQuery(
        '''Select *,m.Id as 'MId',m.Type as 'MType',s.Type as 'SType', s.Id as 'SId' from Schedules s join Medicines m on m.Id=s.MedId where s.Type='Daily' Or date=${day} Or day=${weekday}''');
    List<TodoItem> list = List.generate(maps.length, (index) {
      Map<String, dynamic> medMap = {
        'Name': maps[index]['Name'],
        'Type': maps[index]['MType'],
        'Id': maps[index]['MId']
      };
      Map<String, dynamic> sMap = {
        'Id': maps[index]['SId'],
        'Type': maps[index]['SType'],
        'MedId': maps[index]['MedId'],
        'hour': maps[index]['hour'],
        'minute': maps[index]['minute'],
        'day': maps[index]['day'],
        'date': maps[index]['date'],
        'dosage': maps[index]['dosage']
      };
      TodoItem tdi =
          TodoItem(Medicine.toObject(medMap), Schedule.toObject(sMap));
      return tdi;
    });
    return list;
  }

  Future<InventoryItem> getInventoryItem(int MedId) async {
    //shallow INventory Item
    var db = await dbInstance2;
    List<Map<String, dynamic>> maps = await db.query('Inventory',
        where: 'MedId=?', whereArgs: [MedId], limit: 1);
    InventoryItem item = InventoryItem(MedId);
    item.Id = maps[0]['Id'];
    item.dumpStock(double.parse(maps[0]['medStock']));
    return item;
  } //checked

  Future<InventoryItem> getInventoryItemDeep(int MedId) async {
    //shallow INventory Item
    var db = await dbInstance2;
    List<Map<String, dynamic>> maps = await db.query('Inventory',
        where: 'MedId=?', whereArgs: [MedId], limit: 1);
    InventoryItem item = InventoryItem(MedId);
    item.Id = maps[0]['Id'];
    item.dumpStock(double.parse(maps[0]['medStock']));
    item.medicine = await getMedicineById(MedId);
    item.slist = await getSListByMedId(MedId);

    return item;
  } //checked

  Future<int> updateStock(int InvId, double stock) async {
    var db = await dbInstance2;
    try {
      db.rawUpdate(
          '''UPDATE Inventory SET medStock = ? WHERE Id=?''', [stock, InvId]);
    } catch (e) {
      return 404;
    }

    return 1;
  } //checked

  Future<List<Medicine>> getMedicines() async {
    var db = await dbInstance2;
    final List<Map<String, dynamic>> maps = await db.query('Medicines');
    // print("Avail meds ${maps.length}");
    List<Medicine> allMedicines = List.generate(maps.length, (i) {
      Medicine med = Medicine(maps[i]['Name'], isMedType(maps[i]['Type']));
      med.Id = maps[i]['Id'];
      return med;
    });
    return allMedicines;
  } //checked

  Future<bool> TodoExists(int date, int month) async {
    var db = await dbInstance2;
    List<Map<String, dynamic>> maps = await db.query('Todo', limit: 1);
    if (maps.length > 0) {
      Map<String, dynamic> todo = maps[0];
      if (todo['Date'] == date && todo['MONTH'] == month) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<void> purgeTodos() async {
    var db = await dbInstance2;
    var batch = db.batch();
    batch.rawQuery('DELETE FROM Todo');
    batch.rawQuery('DELETE FROM TodoSchedules');
    batch.rawQuery('''delete from sqlite_sequence where name='Todo';''');
    batch.rawQuery(
        '''delete from sqlite_sequence where name='TodoSchedules';''');
    await batch.commit();
    return;
  }

  Future<void> deleteSchedule(int NotifId) async {
    cancelSchedule(NotifId);
    var db = await dbInstance2;
    await db.rawQuery(''' DELETE FROM Schedules where Notifid=${NotifId} ''');
    // TodoProvider.sharedInstance.SyncTodos();
  }

  Future<void> deleteMedicine(int? MedId) async {
    ScheduleList slist = await DatabaseLink.link.getSListByMedId(MedId!);
    slist.scheduleList.forEach((element) {
      AwesomeNotifications().cancel(element.NotifId!);
    });
    var db = await dbInstance2;
    await db.rawQuery('''DELETE FROM Medicines where Id=${MedId}''');
    //
    // TodoProvider.sharedInstance.updateFetch();
    // InventoryRecon().update();
    return;
  }
}
