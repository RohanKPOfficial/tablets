import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:tablets/BlocsNProviders/InventoryProvider.dart';
import 'package:tablets/Components/ReminderUi.dart';
import 'package:tablets/Components/splashscreen.dart';
import 'package:tablets/Repository/Notifier.dart';
import 'package:tablets/Repository/Snacker.dart';
import 'package:tablets/Repository/dblink.dart';
import 'package:tablets/sizer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import 'BlocsNProviders/SelectedDays.dart';
import 'package:tablets/BlocsNProviders/TodoProvider.dart';
import 'Components/PlusSymbol.dart';
import 'package:tablets/Models/Medicine.dart';
import 'package:tablets/Repository/timerBuilder.dart';
import 'package:tablets/Models/reminderList.dart';
import 'package:tablets/Components/AppBodyUI.dart';

import 'package:tablets/Models/inventoryItem.dart';

import 'Config/partenrlinks.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //initialise Platform Notification Service
  initNotificationService();

  //initialize DbLinks
  DatabaseLink();
  // await DatabaseLink.link.InitDB();
  await DatabaseLink.link.initNewDB();

  //lock Screen orientation to portrait only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<InventoryRecon>(
            create: (context) => InventoryRecon()),
        ChangeNotifierProvider<TodoProvider>(create: (_) => TodoProvider()),
      ],
      child: MaterialApp(
        showPerformanceOverlay: false,
        scrollBehavior: MaterialScrollBehavior().copyWith(dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown
        }),
        title: 'Tablets',
        theme: ThemeData(
            // primarySwatch: Colors.red,
            // primarySwatch: Colors.orange,
            ),
        home: Splasher(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key, required this.title, required this.userName})
      : super(key: key);

  final String title, userName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BodyWidget2(
        userName: this.userName,
      ),
      floatingActionButton: Consumer2<TodoProvider, InventoryRecon>(
          builder: (context, _todoProvider, _inventoryRecon, _) {
        return Container(
          height: getHeightByFactor(context, 0.08),
          width: getHeightByFactor(context, 0.08),
          child: FittedBox(
            child: FloatingActionButton(
              heroTag: null,
              onPressed: () async {
                String dropdownValue = 'Daily';
                late Medicine selectedMedicine;
                int numReminders = 1;
                ScheduleList sList = ScheduleList([]);

                List<Medicine> meds = await DatabaseLink.link.getMedicines();

                if (meds.length == 0) {
                  ShowSnack(context, 4, SnackType.Warn,
                      'No Medicines in inventory . Add Medicines by tapping \'+\'');
                }
                selectedMedicine = meds[0];

                Widget dropDownUi = ReminderUiBuilder(context, dropdownValue,
                    numReminders, sList, selectedMedicine.Id!);

                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      double Dosage = 1;

                      TextEditingController controller =
                          TextEditingController();
                      controller.text = 1.toString();
                      return MultiProvider(
                        providers: [
                          ChangeNotifierProvider(
                              create: (_) => SelectedDays(7)),
                          ChangeNotifierProvider(
                              create: (_) => SelectedMonths(28))
                        ],
                        child: AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  getWidthByFactor(context, 0.1))),
                          title: Text('Create a Dosage Reminder'),
                          content: StatefulBuilder(
                              builder: (context, StateSetter setState) {
                            return Container(
                              child: Column(
                                children: [
                                  const Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0,
                                        top: 10,
                                        bottom: 1,
                                        right: 8),
                                    child: Text(
                                      'Medicine',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  DropdownButtonFormField<String>(
                                    value: selectedMedicine.Name,
                                    icon: const Icon(Icons.arrow_drop_down),
                                    elevation: 16,
                                    style: const TextStyle(
                                        color: Colors.deepPurple),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedMedicine = meds.firstWhere(
                                            (element) =>
                                                element.Name == newValue);
                                        dropDownUi = ReminderUiBuilder(
                                            context,
                                            dropdownValue,
                                            numReminders,
                                            sList,
                                            selectedMedicine.Id!);
                                      });
                                    },
                                    items: meds.map<DropdownMenuItem<String>>(
                                        (Medicine value) {
                                      return DropdownMenuItem<String>(
                                        value: value.Name,
                                        child: Text(value.Name),
                                      );
                                    }).toList(),
                                  ),
                                  const Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0,
                                        top: 10,
                                        bottom: 1,
                                        right: 8),
                                    child: Text(
                                      'Dosage',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Expanded(
                                            child: TextField(
                                          controller: controller,
                                        )),
                                        Text(
                                            '${Shorten(selectedMedicine.Type)}'),
                                        TextButton(
                                            style: ElevatedButton.styleFrom(
                                                shape: CircleBorder(),
                                                primary: Colors.grey.shade100),
                                            child: Icon(Icons.remove),
                                            onPressed: () {
                                              int curr =
                                                  int.parse(controller.text);
                                              if (curr > 1) {
                                                controller.text =
                                                    (curr - 1).toString();
                                              }
                                            }),
                                        TextButton(
                                            style: ElevatedButton.styleFrom(
                                                shape: CircleBorder(),
                                                primary: Colors.grey.shade100),
                                            child: Icon(Icons.add),
                                            onPressed: () {
                                              int curr =
                                                  int.parse(controller.text);
                                              if (curr < 10) {
                                                controller.text =
                                                    (curr + 1).toString();
                                              }
                                            }),
                                      ],
                                    ),
                                  ),
                                  const Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0,
                                        top: 10,
                                        bottom: 1,
                                        right: 8),
                                    child: Text(
                                      'Schedule',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  DropdownButtonFormField<String>(
                                    value: dropdownValue,
                                    icon: const Icon(Icons.arrow_drop_down),
                                    elevation: 16,
                                    style: const TextStyle(
                                        color: Colors.deepPurple),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        dropdownValue = newValue!;
                                        dropDownUi = ReminderUiBuilder(
                                            context,
                                            dropdownValue,
                                            numReminders,
                                            sList,
                                            selectedMedicine.Id!);
                                      });
                                    },
                                    items: <String>[
                                      'Daily',
                                      'Weekly',
                                      'Monthly'
                                    ].map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                  dropDownUi,
                                ],
                              ),
                            );
                          }),
                          actions: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: getHeightByFactor(context, 0.05),
                                  width: getWidthByFactor(context, 0.35),
                                  child:
                                      Consumer2<SelectedDays, SelectedMonths>(
                                          builder: (context, _selectedDays,
                                              _selectedMonths, _) {
                                    return TextButton(
                                      child: Text('Set Reminder'),
                                      onPressed: () async {
                                        switch (dropdownValue) {
                                          case 'Daily':
                                            sList.scheduleList
                                                .forEach((element) {
                                              element.Type = 'Daily';
                                              element.dosage =
                                                  double.parse(controller.text);
                                            });
                                            await bulkScheduleNotification(
                                                sList,
                                                selectedMedicine.Id!,
                                                controller.text);

                                            Navigator.pop(context);
                                            break;

                                          case 'Weekly':
                                            sList.scheduleList
                                                .forEach((element) {
                                              element.Type = 'Weekly';
                                              element.dosage =
                                                  double.parse(controller.text);
                                            });

                                            List<int> _selctedDays =
                                                _selectedDays.selected();

                                            sList = sList.getWeeklySchedules(
                                                _selctedDays);

                                            await bulkScheduleNotification(
                                                sList,
                                                selectedMedicine.Id!,
                                                controller.text);
                                            Navigator.pop(context);
                                            break;

                                          case 'Monthly':
                                            sList.scheduleList
                                                .forEach((element) {
                                              element.Type = 'Monthly';
                                              element.dosage =
                                                  double.parse(controller.text);
                                            });

                                            List<int> _selctedMonths =
                                                _selectedMonths.selected();

                                            sList = sList.getMonthlySchedules(
                                                _selctedMonths);

                                            await bulkScheduleNotification(
                                                sList,
                                                selectedMedicine.Id!,
                                                controller.text);

                                            Navigator.pop(context);
                                            break;
                                          default:
                                            print('Defaulted');
                                        }
                                        ShowSnack(context, 2, SnackType.Info,
                                            'Scheduled Reminder(s) for ${selectedMedicine.Name}');
                                        _inventoryRecon.update();
                                        await _todoProvider.updateFetch();
                                      },
                                    );
                                  }),
                                ),
                                Container(
                                  width: getWidthByFactor(context, 0.35),
                                  height: getHeightByFactor(context, 0.05),
                                  child: TextButton(
                                    child: Text('Cancel'),
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
                    });
                // newNOtfy();
              },
              tooltip: 'Add Dosage Reminder',
              child: const Icon(Icons.notification_add),
            ),
          ),
        );
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 5,
        color: Colors.blue,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: EdgeInsets.only(
                  left: 8,
                  right: getWidthByFactor(context, 0.1),
                  top: 8,
                  bottom: 12),
              child: FloatingActionButton(
                elevation: 0,
                heroTag: null,
                tooltip: 'Shop for Medicines',
                onPressed: () {
                  LaunchPartenerSite();
                },
                child: Icon(
                  Icons.shopping_bag,
                  size: getWidthByFactor(context, 0.1),
                ),
              ),
            ),
            Consumer<InventoryRecon>(builder: (context, _inventoryRecon, _) {
              return Padding(
                padding: EdgeInsets.only(
                    left: 10,
                    right: getWidthByFactor(context, 0.43),
                    top: 8,
                    bottom: 12),
                child: FloatingActionButton(
                    tooltip: 'Add a Medicine',
                    elevation: 0,
                    heroTag: null,
                    child: Icon(
                      Icons.medication,
                      size: getWidthByFactor(context, 0.1),
                    ),
                    onPressed: () {
                      TextEditingController controller =
                          TextEditingController();
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            List<Medtype> options = Medtype.values;

                            Medtype? selectedMedType = options[0];
                            return StatefulBuilder(
                                builder: (context, StateSetter setState) {
                              return AlertDialog(
                                title: Text('Add Medicine'),
                                content: Container(
                                  width: getWidthByFactor(context, 0.8),
                                  height: getHeightByFactor(context, 0.2),
                                  child: Column(
                                    children: [
                                      TextField(
                                        textCapitalization:
                                            TextCapitalization.words,
                                        controller: controller,
                                        decoration: InputDecoration(
                                            hintText: 'Enter Medicine Name',
                                            labelText: 'Enter Medicine Name'),
                                      ),
                                      DropdownButtonFormField<Medtype>(
                                        value: selectedMedType,
                                        items: options
                                            .map<DropdownMenuItem<Medtype>>(
                                                (Medtype value) {
                                          return DropdownMenuItem<Medtype>(
                                            value: value,
                                            child: Text(value.name),
                                          );
                                        }).toList(),
                                        onChanged: (Medtype? value) {
                                          setState(() {
                                            selectedMedType = value;
                                          });
                                          print(selectedMedType);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      getWidthByFactor(context, 0.1)),
                                ),
                                actions: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      TextButton(
                                        child: Text('Add Medicine'),
                                        onPressed: () async {
                                          String MedName =
                                              controller.value.text.toString();
                                          if (MedName.isNotEmpty) {
                                            int _success = await DatabaseLink
                                                .link
                                                .InsertInventoryItem(Medicine(
                                                    MedName, selectedMedType!));
                                            if (_success != -404)
                                              ShowSnack(
                                                  context,
                                                  3,
                                                  SnackType.Info,
                                                  'Added $MedName to Inventory');
                                            _inventoryRecon.update();
                                            Navigator.pop(context);
                                          } else {
                                            //TOdo Error on empty med name
                                          }
                                        },
                                      ),
                                      TextButton(
                                        child: Text('Dismiss'),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      )
                                    ],
                                  ),
                                ],
                              );
                            });
                          });
                    }),
              );
            })
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void ListCopier(List l1, List l2) {
    l2 = l1;
  }
}
