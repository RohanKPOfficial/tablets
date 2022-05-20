import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tablets/BlocsNProviders/InventoryProvider.dart';
import 'package:tablets/Models/Medicine.dart';
import 'package:tablets/Repository/Snacker.dart';
import 'package:tablets/Repository/dblink.dart';
import 'package:tablets/sizer.dart';

class AddMeds extends StatefulWidget {
  const AddMeds({Key? key}) : super(key: key);

  @override
  State<AddMeds> createState() => _AddMedsState();
}

class _AddMedsState extends State<AddMeds> {
  bool fieldError = false;
  Medtype selectedMedType = Medtype.Tablets;
  List<Medtype> options = Medtype.values;
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Add Medicine',
        style: TextStyle(fontSize: getHeightByFactor(context, 0.03)),
      ),
      content: SizedBox(
        width: getWidthByFactor(context, 0.8),
        height: getHeightByFactor(context, 0.2),
        child: Column(
          children: [
            Expanded(
              flex: 5,
              child: TextField(
                maxLength: 50,
                textCapitalization: TextCapitalization.words,
                controller: controller,
                decoration: InputDecoration(
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            getWidthByFactor(context, 0.06))),
                    errorText: fieldError ? 'Cant be empty' : null,
                    hintText: 'Enter Medicine Name',
                    hintStyle:
                        TextStyle(fontSize: getHeightByFactor(context, 0.025)),
                    labelText: 'Enter Medicine Name',
                    labelStyle:
                        TextStyle(fontSize: getHeightByFactor(context, 0.025))),
              ),
            ),
            Expanded(
              flex: 4,
              child: DropdownButtonFormField<Medtype>(
                decoration: InputDecoration(
                  alignLabelWithHint: true,
                  contentPadding:
                      EdgeInsets.all(getHeightByFactor(context, 0.03)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                          Radius.circular(getWidthByFactor(context, 0.06)))),
                ),
                value: selectedMedType,
                items: options.map<DropdownMenuItem<Medtype>>((Medtype value) {
                  return DropdownMenuItem<Medtype>(
                    value: value,
                    child: Text(
                      value.name,
                      style: TextStyle(
                          fontSize: getHeightByFactor(context, 0.025)),
                    ),
                  );
                }).toList(),
                onChanged: (Medtype? value) {
                  setState(() {
                    selectedMedType = value!;
                  });
                },
              ),
            ),
          ],
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(getWidthByFactor(context, 0.1)),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              child: const Text('Add Medicine'),
              onPressed: () async {
                String MedName = controller.value.text.toString();
                if (MedName.isNotEmpty) {
                  int _success = await DatabaseLink.link
                      .InsertInventoryItem(Medicine(MedName, selectedMedType));
                  if (_success != -404) {
                    ShowSnack(context, 3, SnackType.Info,
                        'Added $MedName to Inventory');
                  }
                  InventoryRecon().update();
                  Navigator.pop(context);
                } else {
                  setState(() {
                    fieldError = true;
                  });
                }
              },
            ),
            TextButton(
              child: const Text('Dismiss'),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        ),
      ],
    );
  }
}
