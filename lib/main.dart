import 'dart:ui';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as Path;
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:tablets/Blocs/InventoryProvider.dart';
import 'package:tablets/Repository/Notifier.dart';
import 'package:tablets/Repository/dblink.dart';
import 'package:tablets/sizer.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import 'Blocs/SelectedDays.dart';
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
  await DatabaseLink.link.InitDB();
  await DatabaseLink.link.initNewDB();

  //lock Screen orientation to portrait only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const MyApp());
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
      home: const MyHomePage(title: 'Tablets'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<InventoryItem> inventoryList = [];
  @override
  void initState() {
    super.initState();
    getItems();
  }

  void getItems() async {
    inventoryList = await DatabaseLink.link.getInventoryItems();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<InventoryRecon>(
      create: (_) => InventoryRecon(),
      child: Scaffold(
        backgroundColor: Colors.greenAccent.shade400,
        body: BodyWidget(),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Consumer<InventoryRecon>(builder: (context, _inventoryRecon, _) {
              return FloatingActionButton(
                onPressed: () async {
                  // await DatabaseLink.ConsumeMedicine(
                  //     Medicine('
                  //     Crocin', Medtype.Tablets), 1);
                  // _inventoryRecon.update();
                  ScheduleImmediateNotif(
                      Medicine('Crocin', Medtype.Tablets), '1');
                },
                child: Icon(Icons.paste),
              );
            }),
            FloatingActionButton(
              onPressed: () async {
                String dropdownValue = 'Daily';
                late Medicine selectedMedicine;
                int numReminders = 1;
                // List<Schedule> Schedules = [];
                ScheduleList sList = ScheduleList([]);

                late Widget dropDownUi =
                    ReminderUiBuilder(dropdownValue, numReminders, sList);

                List<Medicine> meds = await DatabaseLink.link.getMedicines();
                print(meds);
                if (meds.length == 0) {
                  print('was empty');
                  // DatabaseLink.link
                  //     .InsertMedicine(Medicine('Crocin 650', Medtype.Tablets));
                  // meds = await DatabaseLink.link.getMedicines();
                }
                selectedMedicine = meds[0];
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
                                  Padding(
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
                                  Padding(
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
                                  Padding(
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
                                            dropdownValue, numReminders, sList);
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
                                              element.dosage =
                                                  double.parse(controller.text);
                                            });
                                            bulkScheduleDailyNotification(
                                                sList,
                                                selectedMedicine,
                                                controller.text);

                                            Navigator.pop(context);
                                            break;

                                          case 'Weekly':
                                            sList.scheduleList
                                                .forEach((element) {
                                              element.dosage =
                                                  double.parse(controller.text);
                                            });

                                            List<int> _selctedDays =
                                                _selectedDays.selected();

                                            sList = sList.getWeeklySchedules(
                                                _selctedDays);

                                            bulkScheduleDailyNotification(
                                                sList,
                                                selectedMedicine,
                                                controller.text);

                                            Navigator.pop(context);
                                            break;

                                          case 'Monthly':
                                            sList.scheduleList
                                                .forEach((element) {
                                              element.dosage =
                                                  double.parse(controller.text);
                                            });

                                            List<int> _selctedMonths =
                                                _selectedMonths.selected();

                                            sList = sList.getMonthlySchedules(
                                                _selctedMonths);

                                            bulkScheduleDailyNotification(
                                                sList,
                                                selectedMedicine,
                                                controller.text);

                                            Navigator.pop(context);
                                            break;
                                          default:
                                            print('Defaulted');
                                        }
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
            ),
            FloatingActionButton(
              onPressed: () {
                CancelAllSchedules();
              },
              child: Icon(Icons.delete_forever),
            ),
            FloatingActionButton(
                child: Icon(Icons.medication),
                onPressed: () {
                  TextEditingController controller = TextEditingController();
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        List<Medtype> options = Medtype.values;

                        Medtype? selectedMedType = options[0];
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
                                  items: options.map<DropdownMenuItem<Medtype>>(
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
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextButton(
                                  child: Text('Add Medicine'),
                                  onPressed: () {
                                    String MedName =
                                        controller.value.text.toString();

                                    print("Medicine Name : ${MedName}");

                                    InventoryItem i = InventoryItem(
                                        Medicine(MedName, selectedMedType!));
                                    print(i.toMap());
                                    DatabaseLink.link.InsertInventoryItem(i);
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
                })
          ],
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }

  void ListCopier(List l1, List l2) {
    l2 = l1;
  }

  Widget ReminderUiBuilder(
      String selected, int numReminders, ScheduleList schedules) {
    if (selected == 'Daily') {
      schedules.Modify([
        ReminderTimeList.ToSchedule(TimeOfDay.now())
      ]); //default current time
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => ReminderTimeList(List.generate(
                numReminders,
                (index) => TimeOfDay.fromDateTime(
                    DateTime.now().add(Duration(minutes: index))))),
          ),
        ],
        child: StatefulBuilder(builder: (context, StateSetter setState) {
          return Column(
            children: [
              Consumer<ReminderTimeList>(
                  builder: (context, reminderTimeList, _) {
                return Padding(
                  padding: const EdgeInsets.all(5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.repeat),
                      SizedBox(
                        width: 10,
                      ),
                      Text('Repeat'),
                      TextButton(
                          style: ElevatedButton.styleFrom(
                              shape: CircleBorder(),
                              primary: Colors.grey.shade100),
                          child: Icon(Icons.remove),
                          onPressed: () {
                            if (reminderTimeList.myList.length > 1) {
                              numReminders--;
                              reminderTimeList.regenDecrement();
                            }
                          }),
                      Text('${reminderTimeList.myList.length}'),
                      TextButton(
                          style: ElevatedButton.styleFrom(
                              shape: CircleBorder(),
                              primary: Colors.grey.shade100),
                          child: Icon(Icons.add),
                          onPressed: () {
                            if (reminderTimeList.myList.length < 24) {
                              numReminders++;
                              reminderTimeList.regenIncrement();
                            }
                          }),
                    ],
                  ),
                );
              }),
              Container(
                height: getHeightByFactor(context, 0.3),
                child: Scrollbar(
                  isAlwaysShown: true,
                  child: Consumer<ReminderTimeList>(
                    builder: (context, reminderTimeList, _) => ListView.builder(
                      itemCount: reminderTimeList.myList.length,
                      itemBuilder: (context, index) => ListTile(
                        title: Text(
                          '${reminderTimeList.get(index).format(context)}',
                          style: TextStyle(
                              fontSize: getHeightByFactor(context, 0.04),
                              fontWeight: FontWeight.bold),
                        ),
                        leading: Icon(Icons.timer),
                        subtitle: Text('Reminder ${index + 1}'),
                        onTap: () async {
                          TimeOfDay? x = await showTimer(
                              reminderTimeList.get(index), context);

                          reminderTimeList.modify(index, x!);
                          schedules.Modify(reminderTimeList.toScheduleList());
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      );
    } else if (selected == 'Weekly') {
      schedules.Modify([
        ReminderTimeList.ToSchedule(TimeOfDay.now())
      ]); //default current time
      return MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => ReminderTimeList(List.generate(
                  numReminders,
                  (index) => TimeOfDay.fromDateTime(
                      DateTime.now().add(Duration(minutes: index))))),
            ),
            // ChangeNotifierProvider(
            //   create: (_) => SelectedDays(7),
            // )
          ],
          child: Column(
            children: [
              Consumer<ReminderTimeList>(
                  builder: (context, reminderTimeList, _) {
                ScrollController _controller = ScrollController();
                return Padding(
                  padding: const EdgeInsets.all(5),
                  child: Column(
                    children: [
                      Text('Repeat Days'),
                      Container(
                        width: getFullWidth(context),
                        height: getHeightByFactor(context, 0.05),
                        child: ListView(
                            controller: _controller,
                            scrollDirection: Axis.horizontal,
                            children: [
                              Consumer<SelectedDays>(
                                  builder: (context, selectedDays, _) {
                                return ToggleButtons(
                                  selectedColor: Colors.primaries.first,
                                  isSelected: selectedDays.selectedElements,
                                  children: [
                                    Text('Mo'),
                                    Text('Tu'),
                                    Text('We'),
                                    Text('Th'),
                                    Text('Fr'),
                                    Text('Sa'),
                                    Text('Su'),
                                  ],
                                  onPressed: (index) {
                                    selectedDays.toggle(index);
                                  },
                                );
                              }),
                            ]),
                      ),
                      Text('Repeat per Day'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.repeat),
                          SizedBox(
                            width: 10,
                          ),
                          TextButton(
                              style: ElevatedButton.styleFrom(
                                  shape: CircleBorder(),
                                  primary: Colors.grey.shade100),
                              child: Icon(Icons.remove),
                              onPressed: () {
                                if (reminderTimeList.myList.length > 1) {
                                  numReminders--;
                                  reminderTimeList.regenDecrement();
                                }
                              }),
                          Text('${reminderTimeList.myList.length}'),
                          TextButton(
                              style: ElevatedButton.styleFrom(
                                  shape: CircleBorder(),
                                  primary: Colors.grey.shade100),
                              child: Icon(Icons.add),
                              onPressed: () {
                                if (reminderTimeList.myList.length < 24) {
                                  numReminders++;
                                  reminderTimeList.regenIncrement();
                                }
                              }),
                        ],
                      ),
                    ],
                  ),
                );
              }),
              Container(
                height: getHeightByFactor(context, 0.2),
                child: Scrollbar(
                  isAlwaysShown: true,
                  child: Consumer<ReminderTimeList>(
                    builder: (context, reminderTimeList, _) => ListView.builder(
                      itemCount: reminderTimeList.myList.length,
                      itemBuilder: (context, index) => ListTile(
                        title: Text(
                          '${reminderTimeList.get(index).format(context)}',
                          style: TextStyle(
                              fontSize: getHeightByFactor(context, 0.04),
                              fontWeight: FontWeight.bold),
                        ),
                        leading: Icon(Icons.timer),
                        subtitle: Text('Reminder ${index + 1}'),
                        onTap: () async {
                          TimeOfDay? x = await showTimer(
                              reminderTimeList.get(index), context);

                          reminderTimeList.modify(index, x!);
                          schedules.Modify(reminderTimeList.toScheduleList());
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ));
    } else {
      schedules.Modify([
        ReminderTimeList.ToSchedule(TimeOfDay.now())
      ]); //default current time
      return MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => ReminderTimeList(List.generate(
                  numReminders,
                  (index) => TimeOfDay.fromDateTime(
                      DateTime.now().add(Duration(minutes: index))))),
            ),
          ],
          child: Column(
            children: [
              Consumer<ReminderTimeList>(
                  builder: (context, reminderTimeList, _) {
                return Padding(
                  padding: const EdgeInsets.all(5),
                  child: Column(
                    children: [
                      Text('Repeat Dates'),
                      Container(
                        width: getFullWidth(context),
                        height: getHeightByFactor(context, 0.15),
                        child:
                            ListView(scrollDirection: Axis.vertical, children: [
                          Consumer<SelectedMonths>(
                              builder: (context, _selectedMonths, _) {
                            return ToggleButtons(
                              selectedColor: Colors.primaries.first,
                              isSelected: _selectedMonths.selectedElements,
                              direction: Axis.vertical,
                              children: List.generate(
                                  28, (index) => Text('${index + 1}')),
                              onPressed: (index) {
                                _selectedMonths.toggle(index);
                              },
                            );
                          }),
                        ]),
                      ),
                      Text('Repeat per Day'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.repeat),
                          SizedBox(
                            width: 10,
                          ),
                          TextButton(
                              style: ElevatedButton.styleFrom(
                                  shape: CircleBorder(),
                                  primary: Colors.grey.shade100),
                              child: Icon(Icons.remove),
                              onPressed: () {
                                if (reminderTimeList.myList.length > 1) {
                                  numReminders--;
                                  reminderTimeList.regenDecrement();
                                }
                              }),
                          Text('${reminderTimeList.myList.length}'),
                          TextButton(
                              style: ElevatedButton.styleFrom(
                                  shape: CircleBorder(),
                                  primary: Colors.grey.shade100),
                              child: Icon(Icons.add),
                              onPressed: () {
                                if (reminderTimeList.myList.length < 24) {
                                  numReminders++;
                                  reminderTimeList.regenIncrement();
                                }
                              }),
                        ],
                      ),
                    ],
                  ),
                );
              }),
              Container(
                height: getHeightByFactor(context, 0.2),
                child: Scrollbar(
                  isAlwaysShown: true,
                  child: Consumer<ReminderTimeList>(
                    builder: (context, reminderTimeList, _) => ListView.builder(
                      itemCount: reminderTimeList.myList.length,
                      itemBuilder: (context, index) => ListTile(
                        title: Text(
                          '${reminderTimeList.get(index).format(context)}',
                          style: TextStyle(
                              fontSize: getHeightByFactor(context, 0.04),
                              fontWeight: FontWeight.bold),
                        ),
                        leading: Icon(Icons.timer),
                        subtitle: Text('Reminder ${index + 1}'),
                        onTap: () async {
                          TimeOfDay? x = await showTimer(
                              reminderTimeList.get(index), context);

                          reminderTimeList.modify(index, x!);
                          schedules.Modify(reminderTimeList.toScheduleList());
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ));
    }
  }
}
