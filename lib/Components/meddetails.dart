import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:tablets/Models/inventoryItem.dart';
import 'package:tablets/sizer.dart';

class MedDetails extends StatelessWidget {
  late InventoryItem item;
  MedDetails({Key? key, required InventoryItem item}) : super(key: key) {
    this.item = item;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: Hero(
          tag: 'Logo',
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
        floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
        body: Container(child: Text('${item.medicine?.Name}')));
  }
}
