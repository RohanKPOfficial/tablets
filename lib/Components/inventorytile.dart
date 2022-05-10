import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tablets/Models/Medicine.dart';
import 'package:tablets/Models/inventoryItem.dart';
import 'package:tablets/Models/reminderList.dart';
import 'package:tablets/Repository/dblink.dart';
import 'package:tablets/sizer.dart';

import 'meddetails.dart';

class inventorytile extends StatelessWidget {
  // static bool initialised = false;
  // static late double _tileWidth;
  late InventoryItem item;
  late int invIndex;
  // late InventoryRecon recon;
  inventorytile(
      {required InventoryItem item,
      required int invIndex,
      required BuildContext context}) {
    this.item = item;
    // if (!initialised) {
    //   _tileWidth = getWidthByFactor(context, 0.4);
    //   initialised = true;
    // }
    this.invIndex = invIndex;
  }
//
//   @override
//   State<inventorytile> createState() => _inventorytileState();
// }
//
// class _inventorytileState extends State<inventorytile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MedDetails(
                      InvIndex: invIndex,
                    )));
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.yellow,
        ),
        width: getWidthByFactor(context, 0.4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Hero(
                tag: 'MedName${invIndex}',
                child: Text(
                  '${item.medicine?.Name}',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: getHeightByFactor(context, 0.02),
                      fontWeight: FontWeight.bold),
                )),
            Hero(
              tag: 'MedIcon${invIndex}',
              child: Icon(
                Medicine.medIcon(
                  item.medicine?.Type,
                ),
                size: getWidthByFactor(context, 0.13),
                color: Colors.white,
              ),
            ),
            Text(
                '${item.medStock % 1 == 0 ? item.medStock.toInt() : item.medStock} ${Shorten(item.medicine?.Type ?? Medtype.Tablets)} inStock'),
          ],
        ),
      ),
    );
  }
}
