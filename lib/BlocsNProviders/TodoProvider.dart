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

  // Future<void> SyncTodos() async {
  //   List<int> MarkedIds = getMarked();
  //   areAllChecked();
  //   tds.fetchTodoItems();
  //   await tds.updateTodos(forceResync: true, MarkedIds: MarkedIds);
  //   areAllChecked();
  //   notifyListeners();
  // }

  Future updateFetch() async {
    await tds.updateTodos(available: true);
    notifyListeners();
    return;
  }

  void MarkNotify(int index) async {
    await tds.MarkTodo(index);
    areAllChecked();
    notifyListeners();
  }

  List<int> getMarked() {
    List<int> Marked = [];
    tds.Todos.forEach((element) {
      if (element.done) {
        Marked.add(element.s.Id!);
      }
    });
    print('Marked Sid');
    print(Marked.toString());
    return Marked;
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
