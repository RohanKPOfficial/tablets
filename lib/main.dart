import 'dart:ui';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as Path;
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:tablets/Repository/Notifier.dart';
import 'package:tablets/Repository/dblink.dart';
import 'package:tablets/sizer.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import 'Components/PlusSymbol.dart';
import 'package:tablets/Models/Medicine.dart';
import 'package:tablets/Repository/timerBuilder.dart';
import 'package:tablets/Models/reminderList.dart';
import 'package:tablets/Components/AppBodyUI.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //initialize DbLinks
  var singletonLink = DatabaseLink();
  await singletonLink.InitDB();
  List<Medicine> a = await singletonLink.getMedicines();
  for (Medicine m in a) {
    print('${m.Name}');
  }

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
  @override
  void initState() {
    super.initState();
  }

  // void newNOtfy() async {
  //   String localTimeZone =
  //       await AwesomeNotifications().getLocalTimeZoneIdentifier();
  //   String utcTimeZone =
  //       await AwesomeNotifications().getLocalTimeZoneIdentifier();
  //   AwesomeNotifications().createNotification(
  //       content: NotificationContent(
  //           // customSound: 'resource://raw/tone',
  //           id: DateTime.now().millisecond.hashCode,
  //           channelKey: 'ch2',
  //           title: 'Time to take your Medicines',
  //           body: 'Medicine Names'),
  //       schedule: NotificationCalendar(
  //           repeats: true,
  //           month: DateTime.now().month,
  //           weekday: DateTime.now().weekday,
  //           day: DateTime.now().day,
  //           hour: DateTime.now().hour,
  //           millisecond: 0,
  //           second: 0)
  //       // Future.delayed(Duration(seconds: 3), () {
  //       //   newNOtfy();
  //       //}
  //       );
  // }
  //
  // void AddReminder(String medName, String Dosage) async {
  //   String localTimeZone =
  //       await AwesomeNotifications().getLocalTimeZoneIdentifier();
  //   String utcTimeZone =
  //       await AwesomeNotifications().getLocalTimeZoneIdentifier();
  //   AwesomeNotifications().createNotification(
  //       content: NotificationContent(
  //           // customSound: 'resource://raw/tone',
  //           id: DateTime.now().millisecond.hashCode,
  //           channelKey: 'ch2',
  //           title: 'Time to take your Medicines',
  //           body: '${medName} ${Dosage}'),
  //       schedule: NotificationCalendar(
  //           repeats: false,
  //           month: DateTime.now().month,
  //           weekday: DateTime.now().weekday,
  //           day: DateTime.now().day,
  //           hour: DateTime.now().hour,
  //           millisecond: DateTime.now().millisecond,
  //           second: DateTime.now().second)
  //       // Future.delayed(Duration(seconds: 3), () {
  //       //   newNOtfy();
  //       //}
  //       );
  // }

  // int getNumReminders() {
  //   return numReminders;
  // }

  // bool play = false;
  // List<bool> isSelected = [true, false, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.greenAccent.shade400,
      body: AppBodyBuilder(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String dropdownValue = 'Daily';
          late Medicine selectedMedicine;
          int numReminders = 1;
          late Widget dropDownUi =
              ReminderUiBuilder(dropdownValue, numReminders);

          List<Medicine> meds = await DatabaseLink.link.getMedicines();
          selectedMedicine = meds[0];
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Create a Dosage Reminder'),
                  content:
                      StatefulBuilder(builder: (context, StateSetter setState) {
                    return Container(
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            value: selectedMedicine.Name,
                            icon: const Icon(Icons.arrow_drop_down),
                            elevation: 16,
                            style: const TextStyle(color: Colors.deepPurple),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedMedicine = meds.firstWhere(
                                    (element) => element.Name == newValue);
                                // dropdownValue = newValue!;
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
                            padding: const EdgeInsets.all(5.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text('Dose'),
                                Text('5'),
                                Text('${Shorten(selectedMedicine.Type)}'),
                                TextButton(
                                    style: ElevatedButton.styleFrom(
                                        shape: CircleBorder(),
                                        primary: Colors.grey.shade100),
                                    child: Icon(Icons.remove),
                                    onPressed: () {}),
                                TextButton(
                                    style: ElevatedButton.styleFrom(
                                        shape: CircleBorder(),
                                        primary: Colors.grey.shade100),
                                    child: Icon(Icons.add),
                                    onPressed: () {}),
                              ],
                            ),
                          ),
                          DropdownButtonFormField<String>(
                            value: dropdownValue,
                            icon: const Icon(Icons.arrow_drop_down),
                            elevation: 16,
                            style: const TextStyle(color: Colors.deepPurple),
                            onChanged: (String? newValue) {
                              setState(() {
                                dropdownValue = newValue!;
                                dropDownUi = ReminderUiBuilder(
                                    dropdownValue, numReminders);
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
                          child: TextButton(
                            child: Text('Set Reminder'),
                            onPressed: () {
                              AddReminder('Paracetamol', '2Tab;lets');
                            },
                          ),
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
                );
              });
          // newNOtfy();
        },
        tooltip: 'Add Dosage Reminder',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget ReminderUiBuilder(String selected, int numReminders) {
    if (selected == 'Daily') {
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
    } else {
      return Text('Else');
    }
  }
}
