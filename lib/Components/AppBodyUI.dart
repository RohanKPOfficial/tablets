import 'dart:ui';

import 'package:flutter/material.dart';
// import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:tablets/BlocsNProviders/InventoryProvider.dart';
import 'package:tablets/Components/PlusSymbol.dart';
import 'package:tablets/Models/Medicine.dart';
import 'package:tablets/Models/TodoItem.dart';
import 'package:tablets/Models/inventoryItem.dart';
import 'package:tablets/Models/reminderList.dart';
import 'package:tablets/Repository/dblink.dart';
import 'package:tablets/sizer.dart';

import 'package:tablets/BlocsNProviders/TodoProvider.dart';

class BodyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Center(
            child: const PlusSymbol(),
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: getHeightByFactor(context, 0.1),
                  ),
                  Text(
                    "Hi Rohan",
                    style: TextStyle(fontSize: getWidthByFactor(context, 0.04)),
                  ),
                ],
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  "All Caught Up ! Hurray",
                  style: TextStyle(fontSize: getWidthByFactor(context, 0.04)),
                ),
              ]),
              Consumer<TodoProvider>(
                builder: (context, _todoProvider, _) {
                  return SizedBox(
                    width: getFullWidth(context),
                    height: getHeightByFactor(context, 0.2),
                    child: ListView.builder(
                        itemCount: _todoProvider.tds.Todos.length,
                        itemBuilder: (context, index) {
                          TodoItem tdi = _todoProvider.tds.Todos[index];
                          return Text(
                              '${tdi.med.Name} ${tdi.s.dosage == tdi.s.dosage.toInt() ? tdi.s.dosage.toInt() : tdi.s.dosage} ${Shorten(tdi.med.Type)} @ ${tdi.s.hour}:${tdi.s.minute} ${tdi.done == true ? "Yes" : 'No'}',
                              style: tdi.done == true
                                  ? TextStyle(
                                      decoration: TextDecoration.lineThrough)
                                  : null);
                        }),
                  );
                },
              ),
              Row(
                children: [
                  const Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        color: Color(0x00000036),
                        child: Text("No medication reminders"),
                      ),
                    ),
                  ),
                ],
              ),
              Row(children: [
                SizedBox(
                  height: getHeightByFactor(context, 0.5),
                  width: getWidthByFactor(context, 0.8),
                  child: Consumer<InventoryRecon>(
                      builder: (context, inventoryRecon, _) {
                    return ListView.builder(
                        itemCount: inventoryRecon.currentInventory.length,
                        itemBuilder: (context, position) {
                          return Text(
                              '$position ${inventoryRecon.currentInventory[position].medicine?.Name}');
                        });
                  }),
                )
              ])
            ],
          ),
          DraggableScrollableSheet(
              minChildSize: 0.1,
              maxChildSize: 1,
              snapSizes: const [0.1, 1],
              snap: true,
              initialChildSize: 0.1,
              builder: (context, controller) => Container(
                    color: Colors.white,
                    child: ListView(
                      controller: controller,
                      children: [
                        SheetUI(),
                      ],
                    ),

                    // ListView.builder(
                    //   controller: controller,
                    //   itemCount: 1,
                    //   itemBuilder: (context, index) {
                    //     return  SheetUI();
                    //   },
                    // ),
                  ))
        ],
      ),
    );
  }
}

class SheetUI extends StatelessWidget {
  const SheetUI({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.expand_more,
          size: getWidthByFactor(context, 0.1),
        ),
        SizedBox(
          height: getHeightByFactor(context, 0.015),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
                child: SizedBox(
                    height: getHeightByFactor(context, 0.04),
                    child: Image.asset(
                      'Images/settimer.png',
                      fit: BoxFit.scaleDown,
                    ))),
            const Text("Medication Reminders"),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: getHeightByFactor(context, 0.2),
                  ),
                  child: Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        boxShadow: [
                          const BoxShadow(
                            color: Color(0x264B4B3C),
                          )
                        ],
                        borderRadius: BorderRadius.circular(
                            getWidthByFactor(context, 0.05)),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: getHeightByFactor(context, 0.05),
                          ),
                          Consumer<InventoryRecon>(
                              builder: (context, _inventoryRecon, _) {
                            List<InventoryItem> currentInv =
                                _inventoryRecon.currentInventory;
                            return currentInv.length == 0
                                ? const Text(
                                    'No Medication reminders . Set one by tapping \'+\'')
                                : SizedBox(
                                    width: getFullWidth(context),
                                    height: getHeightByFactor(context, 0.3),
                                    child: ListView.builder(
                                        itemCount: currentInv.length,
                                        itemBuilder: (context, index) {
                                          List<Schedule> current =
                                              currentInv[index]
                                                  .slist
                                                  .scheduleList;
                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ExpansionTile(
                                              collapsedBackgroundColor:
                                                  Colors.blue,
                                              title: Text(currentInv[index]
                                                      .medicine
                                                      ?.Name ??
                                                  ''),
                                              subtitle: Text(
                                                  '${currentInv[index].medStock}'),
                                              trailing:
                                                  Icon(Icons.arrow_drop_down),
                                              children: List.generate(
                                                  current.length,
                                                  (index) => Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                              '${current[index].Type} Reminder @ ${[
                                                            current[index].hour
                                                          ]}:${[
                                                            current[index]
                                                                .minute
                                                          ]} '),
                                                          TextButton(
                                                            onPressed:
                                                                () async {
                                                              await DatabaseLink
                                                                  .link
                                                                  .deleteSchedule(
                                                                      current[index]
                                                                          .NotifId!);
                                                              InventoryRecon
                                                                  .instance
                                                                  .update();
                                                            },
                                                            child: Icon(
                                                                Icons.delete),
                                                          )
                                                        ],
                                                      )),
                                            ),
                                          );
                                        }),
                                  );
                          }),
                        ],
                      )),
                ),
              ),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            boxShadow: [
              BoxShadow(
                color: const Color(0x264B4B3C),
              )
            ],
            borderRadius:
                BorderRadius.circular(getWidthByFactor(context, 0.05)),
          ),
          child: Column(
            children: [
              Text("Medication Inventory"),
              Consumer<InventoryRecon>(builder: (context, inventoryRecon, _) {
                return SizedBox(
                  height: getHeightByFactor(context, 0.3),
                  width: getWidthByFactor(context, 1),
                  child: ListView.builder(
                      itemCount: inventoryRecon.currentInventory.length,
                      itemBuilder: (context, position) {
                        InventoryItem i =
                            inventoryRecon.currentInventory[position];
                        TextEditingController controller =
                            TextEditingController();
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            child: Container(
                              color: tileColor(i.medStock, 10),
                              width: getFullWidth(context),
                              height: getHeightByFactor(context, 0.13),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Column(
                                    children: [
                                      Text(
                                          '${i.medicine?.Name} ${i.medStock % 1 == 0 ? i.medStock.toInt() : i.medStock} ${i.medicine?.Type.name}'),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                              child: TextField(
                                            onSubmitted: (x) {
                                              i.medStock +=
                                                  int.parse(controller.text);
                                              // DatabaseLink.link
                                              //     .InsertInventoryItem(i);
                                              DatabaseLink.link.updateStock(
                                                  i.Id!, i.medStock);
                                              InventoryRecon.instance
                                                  .updateSingle(position);
                                            },
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              hintText: 'Restock Units',
                                            ),
                                            controller: controller,
                                          )),
                                          TextButton(
                                            onPressed: () {
                                              if (controller.text.isEmpty) {
                                                controller.text = '0';
                                              }
                                              int num =
                                                  int.parse(controller.text);
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
                                              int num =
                                                  int.parse(controller.text);
                                              if (num >= 1) {
                                                controller.text =
                                                    (num - 1).toString();
                                              }
                                            },
                                            child: Icon(Icons.remove),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              InventoryRecon.instance
                                                  .updateSingle(position);
                                              i.medStock +=
                                                  int.parse(controller.text);
                                              DatabaseLink.link.updateStock(
                                                  i.Id!, i.medStock);
                                              InventoryRecon.instance
                                                  .updateSingle(position);
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
                        );
                      }),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

Color tileColor(double stock, int i) {
  if (stock == 0) {
    return Colors.redAccent;
  } else if (stock > i) {
    return Colors.green.shade400;
  } else {
    return Colors.yellowAccent;
  }
}

String getScheduleType(Schedule s) {
  if (s.day != 0) {
    return 'Weekly';
  } else if (s.date != 0) {
    return 'Monthly';
  } else {
    return 'Daily';
  }
}
