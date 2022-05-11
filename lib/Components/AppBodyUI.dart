import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
// import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tablets/BlocsNProviders/InventoryProvider.dart';
import 'package:tablets/Components/PlusSymbol.dart';
import 'package:tablets/Components/inventorytile.dart';
import 'package:tablets/Models/Medicine.dart';
import 'package:tablets/Models/TodoItem.dart';
import 'package:tablets/Models/inventoryItem.dart';
import 'package:tablets/Models/reminderList.dart';
import 'package:tablets/Repository/dblink.dart';
import 'package:tablets/sizer.dart';

import 'package:tablets/BlocsNProviders/TodoProvider.dart';

class BodyWidget2 extends StatelessWidget {
  BodyWidget2({required this.userName});
  final String userName;
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 1), () {
      //reset time dilation to defaullt;
      // timeDilation = 1.0;
    });
    return SafeArea(
      child: Center(
        child: Stack(
          children: [
            Positioned(
              top: 100,
              left: 200,
              child: Container(
                  height: 200,
                  width: 200,
                  child: Image.asset(
                    'Images/box1.png',
                  )),
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: getHeightByFactor(context, 0.1),
                    ),
                    Row(
                      children: [
                        Text(
                          "Hi ",
                          style: TextStyle(
                              fontSize: getWidthByFactor(context, 0.06),
                              fontWeight: FontWeight.bold),
                        ),
                        Hero(
                          tag: 'HeroName',
                          child: Container(
                            child: Text(
                              "${userName}",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                      color: Colors.black,
                                      fontSize: getWidthByFactor(context, 0.06),
                                      fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                Consumer<TodoProvider>(
                  builder: (context, _todoProvider, _) {
                    return Column(
                      children: [
                        Text(
                          _todoProvider.tds.Todos.length == 0
                              ? "No reminders set for today"
                              : _todoProvider.allChecked
                                  ? "All Caught Up ! Hurray"
                                  : "Upcoming Medication Dosages",
                          style: TextStyle(
                              fontSize: getWidthByFactor(context, 0.045),
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: getFullWidth(context),
                          height: getHeightByFactor(context, 0.35),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListView.builder(
                                physics: BouncingScrollPhysics(),
                                itemCount: _todoProvider.tds.Todos.length,
                                itemBuilder: (context, index) {
                                  TodoItem tdi = _todoProvider.tds.Todos[index];
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Checkbox(
                                          onChanged: (x) {},
                                          value: tdi.done,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 8,
                                        child: Text(
                                          '${tdi.done ? '' : tdi.s.hour < DateTime.now().hour ? 'Missed!-' : ''}${tdi.med.Name} ${tdi.s.dosage == tdi.s.dosage.toInt() ? tdi.s.dosage.toInt() : tdi.s.dosage} ${Shorten(tdi.med.Type)} @ ${TodoItem.to12Hour(tdi.s.hour, tdi.s.minute)}',
                                          style: tdi.done == true
                                              ? TextStyle(
                                                  decoration: TextDecoration
                                                      .lineThrough)
                                              : DateTime.now().hour > tdi.s.hour
                                                  ? TextStyle(
                                                      color: Colors.redAccent,
                                                      fontWeight:
                                                          FontWeight.bold)
                                                  : null,
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: getHeightByFactor(context, 0.1)),
              child: DraggableScrollableSheet(
                minChildSize: 0.5,
                maxChildSize: 1,
                initialChildSize: 0.5,
                snap: true,
                snapSizes: [0.5, 1],
                builder: (context, controller) => Container(
                  color: Colors.white,
                  height: getFullHeight(context),
                  child: Consumer<InventoryRecon>(
                      builder: (context, _inventoryRecon, _) {
                    return Card(
                      color: Colors.grey.shade100,
                      child: _inventoryRecon.currentInventory.length == 0
                          ? Center(
                              child: Text(
                                  'No medicines in inventory add one by tapping \'+\''))
                          : Column(
                              children: [
                                Icon(Icons.keyboard_arrow_up),
                                Expanded(
                                  child: GridView.builder(
                                    controller: controller,
                                    physics: BouncingScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            crossAxisSpacing: 4.0,
                                            mainAxisSpacing: 4.0),
                                    itemBuilder: (context, index) {
                                      InventoryItem current = _inventoryRecon
                                          .currentInventory[index];
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: inventorytile(
                                          invIndex: index,
                                          item: current,
                                          context: context,
                                        ),
                                      );
                                    },
                                    itemCount:
                                        _inventoryRecon.currentInventory.length,
                                  ),
                                ),
                              ],
                            ),
                    );
                  }),
                ),
              ),
            ),
            Hero(
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
          ],
        ),
      ),
    );
  }
}

Color tileColor(double stock, int i) {
  if (stock == 0) {
    return Colors.redAccent;
  } else if (stock > i) {
    return Colors.green.shade400;
  } else {
    return Colors.orange;
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
