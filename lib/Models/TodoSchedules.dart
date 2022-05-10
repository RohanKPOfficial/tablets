import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tablets/Models/DbTodo.dart';
import 'package:tablets/Models/Medicine.dart';
import 'package:tablets/Models/TodoItem.dart';
import 'package:tablets/Models/reminderList.dart';
import 'package:tablets/Repository/dblink.dart';

class TodoSchedules {
  static late TodoSchedules instance;
  late DateTime today;
  late List<TodoItem> Todos;

  TodoSchedules() {
    instance = this;
    today = DateTime.now();
    Todos = List<TodoItem>.empty();
  }

  Future<void> init() async {
    await fetchTodoItems();
    await updateTodos();
  }

  fetchTodoItems() async {
    Todos = await DatabaseLink.link.getTodoSchedules(today.weekday, today.day);
    //initial todos data fetch for reminder pending today;
  }

  updateTodos({
    bool available = false,
  }) async {
    bool exists = false;
    exists = available
        ? available
        : await DatabaseLink.link.TodoExists(today.day, today.month);
    if (exists) {
      print("TODOS Exist fetch from table");
      Todos = await DatabaseLink.link.getTodos();
      Todos.sort();
    } else {
      print("Does not exist rebuilding todos tables");
      await DatabaseLink.link.purgeTodos();
      await fetchTodoItems();
      Todos.sort();
      var db = await DatabaseLink.link.dbInstance2;
      DbTodo dbt = DbTodo(today.day, today.month);
      var batch = db.batch();
      batch.insert('Todo', dbt.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      for (int i = 0; i < Todos.length; i++) {
        DbTodoSchedules dbts =
            DbTodoSchedules(Todos[i].s.Id!, Todos[i].med.Id!);
        batch.insert('TodoSchedules', dbts.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit();

      updateTodos(available: true);
    }
  }

  MarkTodo(int index) async {
    TodoItem t = Todos[index];
    int SId = t.s.Id!;
    await DatabaseLink.link.MarkTodo(SId);
  }

  void InsertTodo(Schedule s) {}

  static MarkTodoBySId(int SId) async {
    await DatabaseLink.link.MarkTodo(SId);
  }
}
