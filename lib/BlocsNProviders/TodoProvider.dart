import 'package:flutter/material.dart';

import 'package:tablets/Models/TodoSchedules.dart';

class TodoProvider extends ChangeNotifier {
  static late TodoProvider sharedInstance = TodoProvider._internalConstrutor();
  bool allChecked = true;
  late TodoSchedules tds;

  TodoProvider._internalConstrutor() {
    tds = TodoSchedules();
    BeginProvider();
  }

  factory TodoProvider() {
    return sharedInstance;
  }

  // TodoProvider() {
  //   sharedInstance = this;
  //   tds = TodoSchedules();
  //   BeginProvider();
  // }

  void BeginProvider() async {
    await tds.init();
    areAllChecked();
    notifyListeners();
  }

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
    for (var element in tds.Todos) {
      if (element.done) {
        Marked.add(element.s.Id!);
      }
    }

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
