import 'package:flutter/material.dart';
import 'package:tablets/BlocsNProviders/InventoryProvider.dart';
import 'package:tablets/BlocsNProviders/TodoProvider.dart';
import 'package:tablets/Repository/Snacker.dart';
import 'package:tablets/Repository/dblink.dart';
import 'package:tablets/ShowCase/showcaser.dart';
import 'package:tablets/sizer.dart';

class ConfirmDelete extends StatelessWidget {
  const ConfirmDelete(
      {Key? key,
      required this.Id,
      required this.MedName,
      this.immediateDelete = false})
      : super(key: key);
  final int Id;
  final String MedName;
  final bool immediateDelete;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(getWidthByFactor(context, 0.1))),
      title: Text(
        'Sure to Delete $MedName ?',
        textAlign: TextAlign.center,
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () async {
                await DatabaseLink.link.deleteMedicine(Id);
                Navigator.popUntil(
                    context, (Route<dynamic> route) => route.isFirst);
                if (!immediateDelete) {
                  await Future.delayed(const Duration(seconds: 1));
                }
                InventoryRecon().update();
                TodoProvider().updateFetch();
                ShowSnack(context, 3, SnackType.Info, 'Deleted ${MedName}');
              },
              child: const Text('Yes'),
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          getWidthByFactor(context, 0.1)))),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('No'),
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          getWidthByFactor(context, 0.1)))),
            ),
          ],
        ),
      ],
    );
  }
}
