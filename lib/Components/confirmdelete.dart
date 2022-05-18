import 'package:flutter/material.dart';
import 'package:tablets/BlocsNProviders/InventoryProvider.dart';
import 'package:tablets/BlocsNProviders/TodoProvider.dart';
import 'package:tablets/Repository/dblink.dart';
import 'package:tablets/ShowCase/showcaser.dart';
import 'package:tablets/sizer.dart';

class ConfirmDelete extends StatelessWidget {
  const ConfirmDelete({Key? key, required this.Id}) : super(key: key);
  final int Id;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(getWidthByFactor(context, 0.1))),
      title: const Text(
        'Sure to Delete ?',
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

                Future.delayed(const Duration(seconds: 1), () {
                  InventoryRecon().update();
                  TodoProvider().updateFetch();
                });
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
