import 'package:flutter/material.dart';
import 'package:tablets/Models/Medicine.dart';
import 'package:tablets/Models/inventoryItem.dart';
import 'package:tablets/sizer.dart';

import 'AppBodyUI.dart';
import 'meddetails.dart';

class inventorytile extends StatelessWidget {
  late InventoryItem item;
  late int invIndex;
  // late InventoryRecon recon;
  inventorytile(
      {required InventoryItem item,
      required int invIndex,
      required BuildContext context}) {
    this.item = item;

    this.invIndex = invIndex;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 350),
                pageBuilder: (_, __, ___) => MedDetails(
                      InvIndex: invIndex > 1 ? invIndex - 1 : invIndex,
                    )));
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(getHeightByFactor(context, 0.02)),
          color: Colors.yellow.shade300,
        ),
        width: getWidthByFactor(context, 0.4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Hero(
                tag: 'MedName$invIndex',
                child: Text(
                  '${item.medicine?.Name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: getHeightByFactor(context, 0.02),
                      fontWeight: FontWeight.bold),
                )),
            Hero(
              tag: 'MedIcon$invIndex',
              child: Icon(
                Medicine.medIcon(
                  item.medicine?.Type,
                ),
                size: getWidthByFactor(context, 0.13),
                color: Colors.white,
              ),
            ),
            Text(
              '${item.medStock % 1 == 0 ? item.medStock.toInt() : item.medStock} ${Shorten(item.medicine?.Type ?? Medtype.Tablets)} inStock',
              style: TextStyle(color: tileColor(item.medStock, 10)),
            ),
          ],
        ),
      ),
    );
  }
}
