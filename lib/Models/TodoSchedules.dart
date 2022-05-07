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

  updateTodos(
      {bool available = false,
      bool forceResync = false,
      List<int> MarkedIds = const []}) async {
    bool exists = false;
    exists = available
        ? available
        : await DatabaseLink.link.TodoExists(today.day, today.month);
    exists = forceResync ? false : exists;
    if (exists) {
      print("TODOS Exist fetch from table");
      //TODO exists fetch from schedules table
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
        if (forceResync) {
          if (MarkedIds.contains(dbts.SId)) {
            dbts.Marked = 1;
          }
        }
        batch.insert('TodoSchedules', dbts.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit();

      //all todos for today created and inserted  into db
      print("updateCall #3 true modifier");
      updateTodos(available: true);
    }
  }

  MarkTodo(int index) async {
    TodoItem t = Todos[index];
    int SId = t.s.Id!;
    await DatabaseLink.link.MarkTodo(SId);
  }

  static MarkTodoBySId(int SId) async {
    await DatabaseLink.link.MarkTodo(SId);
  }
}
