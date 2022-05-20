import 'package:flutter/material.dart';
import 'package:tablets/BlocsNProviders/SelectedDays.dart';
import 'package:tablets/Models/reminderList.dart';
import 'package:provider/provider.dart';
import 'package:tablets/Repository/timerBuilder.dart';
import 'package:tablets/sizer.dart';

Widget ReminderUiBuilder(BuildContext context, String selected,
    int numReminders, ScheduleList schedules, int MedId) {
  ScrollController cont = ScrollController();
  if (selected == 'Daily') {
    DateTime initTime = DateTime.now().add(const Duration(minutes: 1));
    schedules.Modify([
      ReminderTimeList.ToSchedule(
          TimeOfDay(hour: initTime.hour, minute: initTime.minute), MedId)
    ]); //default current time
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ReminderTimeList(
            List.generate(
              numReminders,
              (index) => TimeOfDay.fromDateTime(
                DateTime.now().add(
                  Duration(minutes: index + 1),
                ),
              ),
            ),
          ),
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
                    const Icon(Icons.repeat),
                    const SizedBox(
                      width: 10,
                    ),
                    const Text('Repeat'),
                    TextButton(
                        style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            primary: Colors.grey.shade100),
                        child: const Icon(Icons.remove),
                        onPressed: () {
                          if (reminderTimeList.myList.length > 1) {
                            numReminders--;
                            reminderTimeList.regenDecrement();
                            schedules.Modify(
                                reminderTimeList.toScheduleList(MedId));
                          }
                        }),
                    Text('${reminderTimeList.myList.length}'),
                    TextButton(
                        style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            primary: Colors.grey.shade100),
                        child: const Icon(Icons.add),
                        onPressed: () {
                          if (reminderTimeList.myList.length < 24) {
                            numReminders++;
                            reminderTimeList.regenIncrement();
                            schedules.Modify(
                                reminderTimeList.toScheduleList(MedId));
                          }
                        }),
                  ],
                ),
              );
            }),
            Container(
              decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius:
                      BorderRadius.circular(getHeightByFactor(context, 0.03))),
              height: getHeightByFactor(context, 0.25),
              child: Scrollbar(
                controller: cont,
                isAlwaysShown: true,
                child: Consumer<ReminderTimeList>(
                  builder: (context, reminderTimeList, _) => ListView.builder(
                    controller: cont,
                    itemCount: reminderTimeList.myList.length,
                    itemBuilder: (context, index) => ListTile(
                      title: Text(
                        '${reminderTimeList.get(index).format(context)}',
                        style: TextStyle(
                            fontSize: getHeightByFactor(context, 0.04),
                            fontWeight: FontWeight.bold),
                      ),
                      leading: const Icon(Icons.timer),
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
    DateTime initTime = DateTime.now().add(const Duration(minutes: 1));
    schedules.Modify([
      ReminderTimeList.ToSchedule(
          TimeOfDay(hour: initTime.hour, minute: initTime.minute), MedId)
    ]); //default current time
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => ReminderTimeList(List.generate(
                numReminders,
                (index) => TimeOfDay.fromDateTime(
                    DateTime.now().add(Duration(minutes: index + 1))))),
          ),
        ],
        child: Column(
          children: [
            Consumer<ReminderTimeList>(builder: (context, reminderTimeList, _) {
              ScrollController _controller = ScrollController();
              return Padding(
                padding: const EdgeInsets.all(5),
                child: Column(
                  children: [
                    const Text('Repeat Days'),
                    SizedBox(
                      width: getFullWidth(context),
                      height: getHeightByFactor(context, 0.07),
                      child: ListView(
                          controller: _controller,
                          scrollDirection: Axis.horizontal,
                          children: [
                            Consumer<SelectedDays>(
                                builder: (context, selectedDays, _) {
                              return ToggleButtons(
                                borderRadius: BorderRadius.all(Radius.circular(
                                    getWidthByFactor(context, 0.04))),
                                selectedColor: Colors.primaries.first,
                                isSelected: selectedDays.selectedElements,
                                children: const [
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
                    const Text('Repeat per Day'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.repeat),
                        const SizedBox(
                          width: 10,
                        ),
                        TextButton(
                            style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                primary: Colors.grey.shade100),
                            child: const Icon(Icons.remove),
                            onPressed: () {
                              if (reminderTimeList.myList.length > 1) {
                                numReminders--;
                                reminderTimeList.regenDecrement();
                                schedules.Modify(
                                    reminderTimeList.toScheduleList(MedId));
                              }
                            }),
                        Text('${reminderTimeList.myList.length}'),
                        TextButton(
                            style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                primary: Colors.grey.shade100),
                            child: const Icon(Icons.add),
                            onPressed: () {
                              if (reminderTimeList.myList.length < 24) {
                                numReminders++;
                                reminderTimeList.regenIncrement();
                                schedules.Modify(
                                    reminderTimeList.toScheduleList(MedId));
                              }
                            }),
                      ],
                    ),
                  ],
                ),
              );
            }),
            Container(
              decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius:
                      BorderRadius.circular(getHeightByFactor(context, 0.03))),
              height: getHeightByFactor(context, 0.15),
              child: Scrollbar(
                isAlwaysShown: true,
                controller: cont,
                child: Consumer<ReminderTimeList>(
                  builder: (context, reminderTimeList, _) => ListView.builder(
                    controller: cont,
                    itemCount: reminderTimeList.myList.length,
                    itemBuilder: (context, index) => ListTile(
                      title: Text(
                        '${reminderTimeList.get(index).format(context)}',
                        style: TextStyle(
                            fontSize: getHeightByFactor(context, 0.04),
                            fontWeight: FontWeight.bold),
                      ),
                      leading: const Icon(Icons.timer),
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
    DateTime initTime = DateTime.now().add(const Duration(minutes: 1));
    schedules.Modify([
      ReminderTimeList.ToSchedule(
          TimeOfDay(hour: initTime.hour, minute: initTime.minute), MedId)
    ]); //default current time
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => ReminderTimeList(List.generate(
                numReminders,
                (index) => TimeOfDay.fromDateTime(
                    DateTime.now().add(Duration(minutes: index + 1))))),
          ),
        ],
        child: Column(
          children: [
            Consumer<ReminderTimeList>(builder: (context, reminderTimeList, _) {
              return Padding(
                padding: const EdgeInsets.all(5),
                child: Column(
                  children: [
                    const Text('Repeat Dates'),
                    SizedBox(
                      width: getFullWidth(context),
                      height: getHeightByFactor(context, 0.07),
                      child:
                          ListView(scrollDirection: Axis.horizontal, children: [
                        Consumer<SelectedMonths>(
                            builder: (context, _selectedMonths, _) {
                          return ToggleButtons(
                            borderRadius: BorderRadius.all(Radius.circular(
                                getWidthByFactor(context, 0.04))),
                            selectedColor: Colors.primaries.first,
                            isSelected: _selectedMonths.selectedElements,
                            direction: Axis.horizontal,
                            children: List.generate(
                                28, (index) => Text('${index + 1}')),
                            onPressed: (index) {
                              _selectedMonths.toggle(index);
                            },
                          );
                        }),
                      ]),
                    ),
                    const Text('Repeat per Day'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.repeat),
                        const SizedBox(
                          width: 10,
                        ),
                        TextButton(
                            style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                primary: Colors.grey.shade100),
                            child: const Icon(Icons.remove),
                            onPressed: () {
                              if (reminderTimeList.myList.length > 1) {
                                numReminders--;
                                reminderTimeList.regenDecrement();
                                schedules.Modify(
                                    reminderTimeList.toScheduleList(MedId));
                              }
                            }),
                        Text('${reminderTimeList.myList.length}'),
                        TextButton(
                            style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                primary: Colors.grey.shade100),
                            child: const Icon(Icons.add),
                            onPressed: () {
                              if (reminderTimeList.myList.length < 24) {
                                numReminders++;
                                reminderTimeList.regenIncrement();
                                schedules.Modify(
                                    reminderTimeList.toScheduleList(MedId));
                              }
                            }),
                      ],
                    ),
                  ],
                ),
              );
            }),
            Container(
              decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius:
                      BorderRadius.circular(getHeightByFactor(context, 0.03))),
              height: getHeightByFactor(context, 0.15),
              child: Scrollbar(
                controller: cont,
                isAlwaysShown: true,
                child: Consumer<ReminderTimeList>(
                  builder: (context, reminderTimeList, _) => ListView.builder(
                    controller: cont,
                    itemCount: reminderTimeList.myList.length,
                    itemBuilder: (context, index) => ListTile(
                      title: Text(
                        '${reminderTimeList.get(index).format(context)}',
                        style: TextStyle(
                            fontSize: getHeightByFactor(context, 0.04),
                            fontWeight: FontWeight.bold),
                      ),
                      leading: const Icon(Icons.timer),
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
