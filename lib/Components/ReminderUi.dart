import 'package:flutter/material.dart';
import 'package:tablets/BlocsNProviders/SelectedDays.dart';
import 'package:tablets/Models/reminderList.dart';
import 'package:provider/provider.dart';
import 'package:tablets/Repository/timerBuilder.dart';
import 'package:tablets/sizer.dart';

Widget ReminderUiBuilder(BuildContext context, String selected,
    int numReminders, ScheduleList schedules, int MedId) {
  if (selected == 'Daily') {
    schedules.Modify([
      ReminderTimeList.ToSchedule(TimeOfDay.now(), MedId)
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
            Consumer<ReminderTimeList>(builder: (context, reminderTimeList, _) {
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
                        schedules.Modify(
                            reminderTimeList.toScheduleList(MedId));
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
      ReminderTimeList.ToSchedule(TimeOfDay.now(), MedId)
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
            Consumer<ReminderTimeList>(builder: (context, reminderTimeList, _) {
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
                        schedules.Modify(
                            reminderTimeList.toScheduleList(MedId));
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
      ReminderTimeList.ToSchedule(TimeOfDay.now(), MedId)
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
            Consumer<ReminderTimeList>(builder: (context, reminderTimeList, _) {
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
                        schedules.Modify(
                            reminderTimeList.toScheduleList(MedId));
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
