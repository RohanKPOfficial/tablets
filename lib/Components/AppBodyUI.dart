import 'package:flutter/material.dart';
// import 'package:path/path.dart';
import 'package:tablets/Components/PlusSymbol.dart';
import 'package:tablets/sizer.dart';

Center AppBodyBuilder(BuildContext context) {
  return Center(
    child: Stack(
      children: [
        Center(
          child: PlusSymbol(),
        ),
        Container(
          // color: Colors.greenAccent.shade400,
          child: Column(
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
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        color: Color(0x00000036),
                        child: Container(
                          child: Text("No medication reminders"),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        DraggableScrollableSheet(
            minChildSize: 0.1,
            maxChildSize: 1,
            snapSizes: [0.1, 1],
            snap: true,
            initialChildSize: 0.1,
            builder: (context, controller) => Container(
                  color: Colors.white,
                  child: ListView.builder(
                    controller: controller,
                    itemCount: 1,
                    itemBuilder: (context, index) {
                      return ItemBuilder(context);
                    },
                  ),
                ))
      ],
    ),
  );
}

Widget ItemBuilder(context) {
  return Column(
    children: [
      Icon(
        Icons.expand_more,
        size: getWidthByFactor(context, 0.1),
      ),
      SizedBox(
        height: getHeightByFactor(context, 0.015),
      ),
      Text("Medication Reminders"),
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
                        BoxShadow(
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
                        Center(
                            child: SizedBox(
                                height: getHeightByFactor(context, 0.08),
                                child: Image.asset(
                                  'Images/settimer.png',
                                  fit: BoxFit.scaleDown,
                                ))),
                        Text(
                            'No Medication reminders . Set one by tapping \'+\''),
                      ],
                    )),
              ),
            ),
          ),
        ],
      ),
      Text("Medication Inventory"),
    ],
  );
}
