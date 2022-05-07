import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:tablets/BlocsNProviders/InventoryProvider.dart';
import 'package:tablets/Components/ReminderUi.dart';
import 'package:tablets/Components/splashscreen.dart';
import 'package:tablets/Repository/Notifier.dart';
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
    return MaterialApp(
      showPerformanceOverlay: false,
      scrollBehavior: MaterialScrollBehavior().copyWith(dragDevices: {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown
      }),
      title: 'Tablets',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Splasher(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;
//
//   // @override
//   // State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   @override
//   void initState() {
//     super.initState();
//   }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<InventoryRecon>(
            create: (context) => InventoryRecon()),
        ChangeNotifierProvider<TodoProvider>(create: (_) => TodoProvider()),
      ],
      child: Scaffold(
        backgroundColor: Colors.greenAccent.shade400,
        body: BodyWidget(),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Consumer<InventoryRecon>(builder: (context, _inventoryRecon, _) {
              return FloatingActionButton(
                heroTag: null,
                onPressed: () async {},
                child: Icon(Icons.paste),
              );
            }),
            Consumer2<TodoProvider, InventoryRecon>(
                builder: (context, _todoProvider, _inventoryRecon, _) {
              return FloatingActionButton(
                heroTag: null,
                onPressed: () async {
                  String dropdownValue = 'Daily';
                  late Medicine selectedMedicine;
                  int numReminders = 1;
                  // List<Schedule> Schedules = [];
                  ScheduleList sList = ScheduleList([]);

                  List<Medicine> meds = await DatabaseLink.link.getMedicines();

                  if (meds.length == 0) {
                    print('was empty');
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
                                                  primary:
                                                      Colors.grey.shade100),
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
                                                  primary:
                                                      Colors.grey.shade100),
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
                                                element.dosage = double.parse(
                                                    controller.text);
                                              });
                                              await bulkScheduleNotification(
                                                  sList,
                                                  selectedMedicine.Id!,
                                                  controller.text);
                                              _inventoryRecon.update();

                                              Navigator.pop(context);
                                              break;

                                            case 'Weekly':
                                              sList.scheduleList
                                                  .forEach((element) {
                                                element.Type = 'Weekly';
                                                element.dosage = double.parse(
                                                    controller.text);
                                              });

                                              List<int> _selctedDays =
                                                  _selectedDays.selected();

                                              sList = sList.getWeeklySchedules(
                                                  _selctedDays);

                                              bulkScheduleNotification(
                                                  sList,
                                                  selectedMedicine.Id!,
                                                  controller.text);

                                              Navigator.pop(context);
                                              break;

                                            case 'Monthly':
                                              sList.scheduleList
                                                  .forEach((element) {
                                                element.Type = 'Monthly';
                                                element.dosage = double.parse(
                                                    controller.text);
                                              });

                                              List<int> _selctedMonths =
                                                  _selectedMonths.selected();

                                              sList = sList.getMonthlySchedules(
                                                  _selctedMonths);

                                              bulkScheduleNotification(
                                                  sList,
                                                  selectedMedicine.Id!,
                                                  controller.text);

                                              Navigator.pop(context);
                                              break;
                                            default:
                                              print('Defaulted');
                                          }
                                          _todoProvider.SyncTodos();
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
                child: const Icon(Icons.add),
              );
            }),
            FloatingActionButton(
              heroTag: null,
              onPressed: () {
                CancelAllSchedules();
              },
              child: Icon(Icons.delete_forever),
            ),
            Consumer<InventoryRecon>(builder: (context, _inventoryRecon, _) {
              return FloatingActionButton(
                  heroTag: null,
                  child: Icon(Icons.medication),
                  onPressed: () {
                    TextEditingController controller = TextEditingController();
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
                                height: getHeightByFactor(context, 0.7),
                                child: Column(
                                  children: [
                                    TextField(
                                      controller: controller,
                                      decoration: InputDecoration(
                                          hintText: 'Enter Medicine Name',
                                          labelText: 'Medicine Name'),
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

                                        print("Medicine Name : ${MedName}");

                                        await DatabaseLink.link
                                            .InsertInventoryItem(Medicine(
                                                MedName, selectedMedType!));
                                        _inventoryRecon.update();
                                        Navigator.pop(context);
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
                  });
            })
          ],
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }

  void ListCopier(List l1, List l2) {
    l2 = l1;
  }
}
