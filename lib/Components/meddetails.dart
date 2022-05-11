import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import 'package:tablets/BlocsNProviders/InventoryProvider.dart';
import 'package:tablets/Components/AppBodyUI.dart';
import 'package:tablets/Config/partenrlinks.dart';
import 'package:tablets/Models/Medicine.dart';
import 'package:tablets/Models/TodoItem.dart';
import 'package:tablets/Models/inventoryItem.dart';
import 'package:tablets/Models/reminderList.dart';
import 'package:tablets/Repository/Notifier.dart';
import 'package:tablets/Repository/dblink.dart';
import 'package:tablets/sizer.dart';

import '../BlocsNProviders/TodoProvider.dart';

class MedDetails extends StatefulWidget {
  late int InvIndex;
  MedDetails({
    Key? key,
    // required InventoryItem item,
    required int InvIndex,
  }) : super(key: key) {
    this.InvIndex = InvIndex;
  }

  @override
  State<MedDetails> createState() => _MedDetailsState();
}

class _MedDetailsState extends State<MedDetails> {
  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();
    return Consumer2<InventoryRecon, TodoProvider>(
        builder: (context, _inventoryRecon, _todoProvider, _) {
      InventoryItem i = _inventoryRecon.currentInventory[widget.InvIndex];
      return Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              GestureDetector(
                child: Padding(
                  padding: EdgeInsets.all(getWidthByFactor(context, 0.05)),
                  child: Icon(
                    Icons.arrow_back,
                    size: getWidthByFactor(context, 0.08),
                  ),
                ),
                onTap: () => Navigator.pop(context),
              ),
              Positioned(
                left: getWidthByFactor(context, 0.8),
                child: Hero(
                  tag: 'Logo',
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: getHeightByFactor(context, 0.05),
                      width: getHeightByFactor(context, 0.05),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: RiveAnimation.asset(
                        'Images/logo (2).riv',
                        controllers: [],
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: getHeightByFactor(context, 0.1)),
                child: Container(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Hero(
                            tag: 'MedName${widget.InvIndex}',
                            child: Text(
                              '${i.medicine?.Name} ${Shorten(i.medicine?.Type ?? Medtype.Tablets)}',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: getHeightByFactor(context, 0.05),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      Hero(
                        tag: 'MedIcon${widget.InvIndex}',
                        child: Icon(
                          Medicine.medIcon(
                            i.medicine?.Type,
                          ),
                          size: getWidthByFactor(context, 0.25),
                          color: Colors.black,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin:
                              EdgeInsets.all(getWidthByFactor(context, 0.02)),
                          decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(
                                  getWidthByFactor(context, 0.1))),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  // color: tileColor(i.medStock, 10),
                                  width: getFullWidth(context),
                                  height: getHeightByFactor(context, 0.13),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(15),
                                      child: Column(
                                        children: [
                                          Text(
                                            '${i.medStock % 1 == 0 ? i.medStock.toInt() : i.medStock} ${i.medicine?.Type.name} In Stock',
                                            style: TextStyle(
                                                color:
                                                    tileColor(i.medStock, 10),
                                                fontSize: getHeightByFactor(
                                                    context, 0.02),
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                child: TextField(
                                                  onSubmitted: (x) async {
                                                    i.medStock += int.parse(
                                                        controller.text);
                                                    DatabaseLink.link
                                                        .updateStock(
                                                            i.Id!, i.medStock);
                                                    _inventoryRecon.update();
                                                  },
                                                  keyboardType:
                                                      TextInputType.number,
                                                  decoration: InputDecoration(
                                                    hintText: 'Restock Units',
                                                  ),
                                                  controller: controller,
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  if (controller.text.isEmpty) {
                                                    controller.text = '0';
                                                  }
                                                  int num = int.parse(
                                                      controller.text);
                                                  if (num >= 0) {
                                                    controller.text =
                                                        (num + 1).toString();
                                                  }
                                                },
                                                child: Icon(Icons.add),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  if (controller.text.isEmpty) {
                                                    controller.text = '0';
                                                  }
                                                  int num = int.parse(
                                                      controller.text);
                                                  if (num >= 1) {
                                                    controller.text =
                                                        (num - 1).toString();
                                                  }
                                                },
                                                child: Icon(Icons.remove),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  i.medStock += int.parse(
                                                      controller.text);
                                                  DatabaseLink.link.updateStock(
                                                      i.Id!, i.medStock);
                                                  _inventoryRecon.update();
                                                },
                                                child: const Text('Restock'),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                'Scheduled Reminders',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: getWidthByFactor(context, 0.04)),
                              ),
                              Expanded(
                                // height: getHeightByFactor(context, 0.35),
                                // width: getFullWidth(context),
                                child: i.slist.scheduleList.length == 0
                                    ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                            'No reminders scheduled for ${i.medicine?.Name}'),
                                      )
                                    : ListView(
                                        children: List.generate(
                                            i.slist.scheduleList.length,
                                            (index) {
                                          List<Schedule> current =
                                              i.slist.scheduleList;
                                          return Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                flex: 6,
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                      left: getWidthByFactor(
                                                          context, 0.06)),
                                                  child: Text(
                                                      '${toScheduleText(current[index])} ${current[index].dosage % 1 == 0 ? current[index].dosage.toInt() : current[index].dosage} ${Shorten(i.medicine?.Type ?? Medtype.Tablets)} @ ${TodoItem.to12Hour(current[index].hour, current[index].minute)}'),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: TextButton(
                                                  onPressed: () async {
                                                    await DatabaseLink.link
                                                        .deleteSchedule(
                                                            current[index]
                                                                .NotifId!);
                                                    _inventoryRecon.update();
                                                    await _todoProvider.tds
                                                        .updateTodos(
                                                            available: true);
                                                    _todoProvider
                                                        .notifyListeners();
                                                  },
                                                  child: Icon(Icons.delete),
                                                ),
                                              )
                                            ],
                                          );
                                        }),
                                      ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        floatingActionButton: Container(
          height: getHeightByFactor(context, 0.08),
          width: getHeightByFactor(context, 0.08),
          child: Consumer2<InventoryRecon, TodoProvider>(
              builder: (context, _invRecon, _tdProv, _) {
            return FittedBox(
              child: FloatingActionButton(
                onPressed: () async {
                  await DatabaseLink.link.deleteMedicine(i.medicine?.Id);
                  Future.delayed(Duration(milliseconds: 700), () {
                    _inventoryRecon.update();
                    _tdProv.updateFetch();
                  });
                  Navigator.pop(context);
                },
                child: Icon(Icons.delete_forever),
              ),
            );
          }),
        ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniEndDocked,
        bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          notchMargin: 5,
          color: Colors.blue,
          child: Row(
            children: [
              Padding(
                  padding: const EdgeInsets.only(
                      left: 8, right: 8, top: 8, bottom: 20),
                  child: FloatingActionButton(
                    elevation: 0,
                    heroTag: null,
                    onPressed: () {
                      LaunchPartenerSite();
                    },
                    child: Icon(
                      Icons.shopping_bag,
                      size: getWidthByFactor(context, 0.1),
                    ),
                  )),
            ],
          ),
        ),
      );
    });
  }
}

String toScheduleText(Schedule s) {
  switch (s.Type) {
    case 'Daily':
      return 'Daily';
    case 'Weekly':
      return 'Weekly ${toDay(s.day)}';
    case 'Monthly':
      return 'Date :${s.date} Every Month';
    default:
      return '';
  }
}

String toDay(int day) {
  List<String> Days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  return Days[day - 1];
}
