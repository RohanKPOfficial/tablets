import 'package:flutter/material.dart';

import 'package:tablets/Models/TodoSchedules.dart';

class TodoProvider extends ChangeNotifier {
  static late TodoProvider sharedInstance;

  late TodoSchedules tds;

  TodoProvider() {
    sharedInstance = this;
    tds = TodoSchedules();
    BeginProvider();
  }

  void BeginProvider() async {
    await tds.init();
    notifyListeners();
  }

  Future<void> SyncTodos() async {
    List<int> MarkedIds = [];
    tds.Todos.forEach((element) {
      if (element.done) {
        MarkedIds.add(element.s.Id!);
      }
    });
    tds.fetchTodoItems();
    await tds.updateTodos(forceResync: true, MarkedIds: MarkedIds);
    notifyListeners();
  }

  void MarkNotify(int index) async {
    await tds.MarkTodo(index);
    notifyListeners();
  }
}
