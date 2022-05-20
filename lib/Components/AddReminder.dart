import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablets/BlocsNProviders/InventoryProvider.dart';
import 'package:tablets/BlocsNProviders/SelectedDays.dart';
import 'package:tablets/BlocsNProviders/TodoProvider.dart';
import 'package:tablets/Components/ReminderUi.dart';
import 'package:tablets/Models/Medicine.dart';
import 'package:tablets/Models/reminderList.dart';
import 'package:tablets/Repository/Notifier.dart';
import 'package:tablets/Repository/Snacker.dart';
import 'package:tablets/sizer.dart';

class AddReminder extends StatefulWidget {
  AddReminder({Key? key, required this.meds, this.selectedIndex = 0})
      : super(key: key);
  List<Medicine> meds;
  int selectedIndex;
  @override
  State<AddReminder> createState() => _AddReminderState();
}

class _AddReminderState extends State<AddReminder> {
  String dropdownValue = 'Daily';
  late Medicine selectedMedicine;
  int numReminders = 1;
  ScheduleList sList = ScheduleList([]);
  late Widget dropDownUi;
  double Dosage = 1;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    selectedMedicine = widget.meds[widget.selectedIndex];
    dropDownUi = ReminderUiBuilder(
        context, dropdownValue, numReminders, sList, selectedMedicine.Id!);
    controller.text = 1.toString();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SelectedDays(7)),
        ChangeNotifierProvider(create: (_) => SelectedMonths(28))
      ],
      child: AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(getWidthByFactor(context, 0.1))),
        title: const Text('Create a Dosage Reminder'),
        content: StatefulBuilder(builder: (context, StateSetter setState) {
          return Container(
            child: ListView(
              children: [
                Expanded(
                  child: Text(
                    'Medicine',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.all(getHeightByFactor(context, 0.01)),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(
                                getWidthByFactor(context, 0.06))))),
                    value: selectedMedicine.Name,
                    icon: const Icon(Icons.arrow_drop_down),
                    elevation: 16,
                    style: const TextStyle(color: Colors.deepPurple),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedMedicine = widget.meds
                            .firstWhere((element) => element.Name == newValue);

                        dropDownUi = ReminderUiBuilder(context, dropdownValue,
                            numReminders, sList, selectedMedicine.Id!);
                      });
                    },
                    items: widget.meds
                        .map<DropdownMenuItem<String>>((Medicine value) {
                      return DropdownMenuItem<String>(
                        value: value.Name,
                        child: Text(value.Name),
                      );
                    }).toList(),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Dosage',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                          child: TextField(
                        controller: controller,
                      )),
                      Text(Shorten(selectedMedicine.Type)),
                      TextButton(
                          style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              primary: Colors.grey.shade100),
                          child: const Icon(Icons.remove),
                          onPressed: () {
                            int curr = int.parse(controller.text);
                            if (curr > 1) {
                              controller.text = (curr - 1).toString();
                            }
                          }),
                      TextButton(
                          style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              primary: Colors.grey.shade100),
                          child: const Icon(Icons.add),
                          onPressed: () {
                            int curr = int.parse(controller.text);
                            if (curr < 10) {
                              controller.text = (curr + 1).toString();
                            }
                          }),
                    ],
                  ),
                ),
                Expanded(
                  child: Text(
                    'Schedule',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.all(getHeightByFactor(context, 0.01)),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(
                                getWidthByFactor(context, 0.06))))),
                    value: dropdownValue,
                    icon: const Icon(Icons.arrow_drop_down),
                    elevation: 16,
                    style: const TextStyle(color: Colors.deepPurple),
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownValue = newValue!;
                        dropDownUi = ReminderUiBuilder(context, dropdownValue,
                            numReminders, sList, selectedMedicine.Id!);
                      });
                    },
                    items: <String>['Daily', 'Weekly', 'Monthly']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                Flexible(child: dropDownUi),
              ],
            ),
          );
        }),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Consumer2<SelectedDays, SelectedMonths>(
                    builder: (context, _selectedDays, _selectedMonths, _) {
                  return TextButton(
                    child: const Text('Set Reminder'),
                    onPressed: () async {
                      switch (dropdownValue) {
                        case 'Daily':
                          for (var element in sList.scheduleList) {
                            element.Type = 'Daily';
                            element.dosage = double.parse(controller.text);
                          }
                          await bulkScheduleNotification(
                              sList, selectedMedicine.Id!, controller.text);

                          Navigator.pop(context);
                          break;

                        case 'Weekly':
                          for (var element in sList.scheduleList) {
                            element.Type = 'Weekly';
                            element.dosage = double.parse(controller.text);
                          }

                          List<int> _selctedDays = _selectedDays.selected();

                          sList = sList.getWeeklySchedules(_selctedDays);

                          await bulkScheduleNotification(
                              sList, selectedMedicine.Id!, controller.text);
                          Navigator.pop(context);
                          break;

                        case 'Monthly':
                          for (var element in sList.scheduleList) {
                            element.Type = 'Monthly';
                            element.dosage = double.parse(controller.text);
                          }

                          List<int> _selctedMonths = _selectedMonths.selected();

                          sList = sList.getMonthlySchedules(_selctedMonths);

                          await bulkScheduleNotification(
                              sList, selectedMedicine.Id!, controller.text);

                          Navigator.pop(context);
                          break;
                        default:
                          break;
                      }
                      ShowSnack(context, 2, SnackType.Info,
                          'Scheduled Reminder(s) for ${selectedMedicine.Name}');
                      InventoryRecon().update();
                      await TodoProvider().updateFetch();
                    },
                  );
                }),
              ),
              Expanded(
                child: TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
