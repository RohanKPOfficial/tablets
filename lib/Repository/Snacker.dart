import 'package:flutter/material.dart';

enum SnackType { Info, Warn }
void ShowSnack(
    BuildContext context, int seconds, SnackType type, String content) {
  SnackBar _snack = SnackBar(
    content: Text(content),
    duration: Duration(seconds: seconds),
    backgroundColor: type == SnackType.Info
        ? Colors.greenAccent.shade400
        : Colors.amberAccent,
  );

  ScaffoldMessenger.of(context).showSnackBar(_snack);
}
