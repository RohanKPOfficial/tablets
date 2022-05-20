import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import 'package:tablets/BlocsNProviders/InventoryProvider.dart';
import 'package:tablets/Components/AddReminder.dart';
import 'package:tablets/Components/AppBodyUI.dart';
import 'package:tablets/Components/confirmdelete.dart';
import 'package:tablets/Config/partenrlinks.dart';
import 'package:tablets/Models/Medicine.dart';
import 'package:tablets/Models/TodoItem.dart';
import 'package:tablets/Models/inventoryItem.dart';
import 'package:tablets/Models/reminderList.dart';
import 'package:tablets/Monetisation/interstitialengine.dart';
import 'package:tablets/Repository/dblink.dart';
import 'package:tablets/Repository/misc.dart';
import 'package:tablets/sizer.dart';

import '../BlocsNProviders/TodoProvider.dart';
import 'editStocks.dart';

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
  String errorText = '';
  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Consumer2<InventoryRecon, TodoProvider>(
        builder: (context, _inventoryRecon, _todoProvider, _) {
      InventoryItem i = _inventoryRecon.currentInventory[widget.InvIndex];
      return Scaffold(
        backgroundColor: Colors.yellow.shade300,
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
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const RiveAnimation.asset(
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
                padding: EdgeInsets.only(top: getHeightByFactor(context, 0.05)),
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                          flex: 1,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Center(
                                  child: Hero(
                                    tag: 'MedIcon${widget.InvIndex}',
                                    child: Icon(
                                      Medicine.medIcon(
                                        i.medicine?.Type,
                                      ),
                                      size: getWidthByFactor(context, 0.2),
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Hero(
                                        tag: 'MedName${widget.InvIndex}',
                                        child: Text(
                                          '${i.medicine?.Name} ${Shorten(i.medicine?.Type ?? Medtype.Tablets)}',
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: getWidthByFactor(
                                                  context, 0.06),
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )),
                      Expanded(
                        flex: 4,
                        child: Container(
                          margin:
                              EdgeInsets.all(getWidthByFactor(context, 0.02)),
                          decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(
                                  getWidthByFactor(context, 0.1))),
                          child: Column(
                            children: [
                              Expanded(
                                flex: 3,
                                child: SizedBox(
                                  width: getFullWidth(context),
                                  height: getHeightByFactor(context, 0.13),
                                  child: Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(
                                          getHeightByFactor(context, 0.01)),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  '${i.medStock % 1 == 0 ? i.medStock.toInt() : i.medStock} ${i.medicine?.Type.name} In Stock',
                                                  style: TextStyle(
                                                      textBaseline: TextBaseline
                                                          .alphabetic,
                                                      color: tileColor(
                                                          i.medStock, 10),
                                                      fontSize:
                                                          getWidthByFactor(
                                                              context, 0.05),
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return EditStocks(
                                                              InvId: i.Id!,
                                                              MedName: i
                                                                  .medicine!
                                                                  .Name,
                                                              currentString:
                                                                  '${i.medStock % 1 == 0 ? i.medStock.toInt() : i.medStock} ${i.medicine?.Type.name} In Stock',
                                                              curr: i.medStock);
                                                        });
                                                  },
                                                  child: Container(
                                                    child: Icon(Icons.edit),
                                                    margin: EdgeInsets.only(
                                                        left: getWidthByFactor(
                                                            context, 0.04)),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                              flex: 3,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                    child: TextField(
                                                      onSubmitted: (x) async {
                                                        if (int.parse(x) > 0) {
                                                          i.medStock +=
                                                              int.parse(
                                                                  controller
                                                                      .text);
                                                          await DatabaseLink
                                                              .link
                                                              .updateStock(
                                                                  i.Id!,
                                                                  i.medStock);
                                                          _inventoryRecon
                                                              .update();
                                                        } else {
                                                          setState(() {
                                                            errorText =
                                                                'Cant\'t be negative';
                                                          });
                                                        }
                                                      },
                                                      style: TextStyle(
                                                          fontSize:
                                                              getWidthByFactor(
                                                                  context,
                                                                  0.05)),
                                                      keyboardType: TextInputType
                                                          .numberWithOptions(
                                                              signed: false),
                                                      decoration:
                                                          InputDecoration(
                                                        errorText:
                                                            errorText == ''
                                                                ? null
                                                                : errorText,
                                                        hintStyle: TextStyle(
                                                            fontSize:
                                                                getWidthByFactor(
                                                                    context,
                                                                    0.045)),
                                                        hintText:
                                                            'Restock Units',
                                                      ),
                                                      controller: controller,
                                                    ),
                                                  ),
                                                  TextButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                              shape:
                                                                  const CircleBorder(),
                                                              primary: Colors
                                                                  .grey
                                                                  .shade100),
                                                      child: Icon(
                                                        Icons.add,
                                                        size: getWidthByFactor(
                                                            context, 0.05),
                                                      ),
                                                      onPressed: () {
                                                        if (controller
                                                            .text.isEmpty) {
                                                          controller.text = '0';
                                                        }
                                                        int num = int.parse(
                                                            controller.text);
                                                        if (num >= 0) {
                                                          controller.text =
                                                              (num + 1)
                                                                  .toString();
                                                        }
                                                      }),
                                                  TextButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                              shape:
                                                                  const CircleBorder(),
                                                              primary: Colors
                                                                  .grey
                                                                  .shade100),
                                                      child: Icon(
                                                        Icons.remove,
                                                        size: getWidthByFactor(
                                                            context, 0.05),
                                                      ),
                                                      onPressed: () {
                                                        if (controller
                                                            .text.isEmpty) {
                                                          controller.text = '0';
                                                        }
                                                        int num = int.parse(
                                                            controller.text);
                                                        if (num >= 1) {
                                                          controller.text =
                                                              (num - 1)
                                                                  .toString();
                                                        }
                                                      }),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors
                                                            .grey.shade100,
                                                        borderRadius: BorderRadius
                                                            .all(Radius.circular(
                                                                getWidthByFactor(
                                                                    context,
                                                                    0.1)))),
                                                    child: TextButton(
                                                      onPressed: () async {
                                                        if (int.parse(controller
                                                                .text) >
                                                            0) {
                                                          i.medStock +=
                                                              int.parse(
                                                                  controller
                                                                      .text);
                                                          await DatabaseLink
                                                              .link
                                                              .updateStock(
                                                                  i.Id!,
                                                                  i.medStock);
                                                          _inventoryRecon
                                                              .update();
                                                        } else {
                                                          setState(() {
                                                            errorText =
                                                                'Can\'t be negative';
                                                          });
                                                        }
                                                      },
                                                      child: Text(
                                                        'Restock',
                                                        style: TextStyle(
                                                          fontSize:
                                                              getWidthByFactor(
                                                                  context,
                                                                  0.04),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Flexible(
                                flex: 2,
                                child: Text(
                                  'Scheduled Reminders',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          getWidthByFactor(context, 0.04)),
                                ),
                              ),
                              Expanded(
                                flex: 7,
                                // height: getHeightByFactor(context, 0.35),
                                // width: getFullWidth(context),
                                child: i.slist.scheduleList.isEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          'No reminders scheduled for ${i.medicine?.Name}',
                                          textAlign: TextAlign.center,
                                        ),
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
                                                child: Tooltip(
                                                  message:
                                                      'Delete this Schedule',
                                                  triggerMode:
                                                      TooltipTriggerMode
                                                          .longPress,
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
                                                    child: const Icon(
                                                        Icons.delete),
                                                  ),
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
        floatingActionButton: SizedBox(
          height: getWidthByFactor(context, 0.17),
          width: getWidthByFactor(context, 0.17),
          child: Consumer2<InventoryRecon, TodoProvider>(
              builder: (context, _invRecon, _tdProv, _) {
            return FittedBox(
              child: FloatingActionButton(
                onPressed: () async {
                  List<Medicine> meds = await DatabaseLink.link.getMedicines();
                  int selectedInd = 0;
                  for (int j = 0; j < meds.length; j++) {
                    if (meds[j].Id == i.medicine?.Id) {
                      selectedInd = j;
                      break;
                    }
                  }
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AddReminder(
                          meds: meds,
                          selectedIndex: selectedInd,
                        );
                      });
                },
                tooltip: 'Delete ${i.medicine?.Name}',
                child: const Icon(Icons.notification_add),
              ),
            );
          }),
        ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniEndDocked,
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 5,
          color: Colors.blue,
          child: Row(
            children: [
              FloatingActionButton(
                tooltip: 'Order ${i.medicine!.Name} online',
                elevation: 0,
                heroTag: null,
                onPressed: () {
                  InterstitialEngine().showAd();
                  LaunchPartenerSite(i.medicine!.Name);
                },
                child: Icon(
                  Icons.shopping_bag,
                  size: getWidthByFactor(context, 0.1),
                ),
              ),
              FloatingActionButton(
                elevation: 0,
                heroTag: null,
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return ConfirmDelete(
                          Id: i.medicine!.Id!,
                          MedName: i.medicine!.Name,
                        );
                      });
                },
                tooltip: 'Delete ${i.medicine?.Name}',
                child: Icon(
                  Icons.delete_forever,
                  size: getWidthByFactor(context, 0.1),
                ),
              ),
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
