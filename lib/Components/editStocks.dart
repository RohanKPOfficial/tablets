import 'package:flutter/material.dart';
import 'package:tablets/BlocsNProviders/InventoryProvider.dart';
import 'package:tablets/BlocsNProviders/TodoProvider.dart';
import 'package:tablets/Repository/Snacker.dart';
import 'package:tablets/Repository/dblink.dart';
import 'package:tablets/ShowCase/showcaser.dart';
import 'package:tablets/sizer.dart';

class EditStocks extends StatefulWidget {
  const EditStocks(
      {Key? key,
      required this.InvId,
      required this.MedName,
      required this.currentString,
      required this.curr})
      : super(key: key);
  final int InvId;
  final double curr;
  final String MedName, currentString;

  @override
  State<EditStocks> createState() => _EditStocksState();
}

class _EditStocksState extends State<EditStocks> {
  late TextEditingController controller;
  String errorMsg = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = TextEditingController();
    controller.text = widget.curr.toString();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(getWidthByFactor(context, 0.1))),
      title: Text(
        'Modify Inventory',
        textAlign: TextAlign.center,
      ),
      content: Container(
        height: getHeightByFactor(context, 0.2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Text('Current : ${widget.currentString}'),
            ),
            Expanded(
              child: TextField(
                onSubmitted: (text) {
                  setState(() {
                    errorMsg = getErrorMsg(text);
                  });
                },
                decoration: InputDecoration(
                  errorText: errorMsg == '' ? null : errorMsg,
                ),
                controller: controller,
                maxLength: 5,
                keyboardType: TextInputType.numberWithOptions(signed: false),
              ),
            ),
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () async {
                String msg = getErrorMsg(controller.text);
                if (msg == 'OK') {
                  await DatabaseLink.link
                      .updateStock(widget.InvId, double.parse(controller.text));
                  Navigator.pop(context);
                  InventoryRecon().update();
                  ShowSnack(context, 3, SnackType.Info,
                      'Modified Inventory for ${widget.MedName}');
                } else {
                  setState(() {
                    errorMsg = msg;
                  });
                }
              },
              child: const Text('Modify'),
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          getWidthByFactor(context, 0.1)))),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
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

  String getErrorMsg(String input) {
    double x = double.parse(input);
    if (x < 0) {
      return 'Can\'t be negative';
    } else {
      return 'OK';
    }
  }
}
