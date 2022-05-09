import 'package:flutter/material.dart';

import 'package:tablets/Models/TodoSchedules.dart';

class TodoProvider extends ChangeNotifier {
  static late TodoProvider sharedInstance;
  bool allChecked = true;
  late TodoSchedules tds;

  TodoProvider() {
    sharedInstance = this;
    tds = TodoSchedules();
    BeginProvider();
  }

  void BeginProvider() async {
    await tds.init();
    areAllChecked();
    notifyListeners();
  }

  Future<void> SyncTodos() async {
    List<int> MarkedIds = [];
    areAllChecked();
    tds.fetchTodoItems();
    await tds.updateTodos(forceResync: true, MarkedIds: MarkedIds);
    areAllChecked();
    notifyListeners();
  }

  void MarkNotify(int index) async {
    await tds.MarkTodo(index);
    areAllChecked();
    notifyListeners();
  }

  void areAllChecked() {
    for (int i = 0; i < tds.Todos.length; i++) {
      if (!tds.Todos[i].done) {
        allChecked = false;
        return;
      }
    }
  }
}
