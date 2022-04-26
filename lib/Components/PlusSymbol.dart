import 'package:flutter/material.dart';

class PlusSymbol extends StatelessWidget {
  const PlusSymbol({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      '+',
      style: TextStyle(
          fontSize: 550,
          fontWeight: FontWeight.bold,
          color: Colors.greenAccent.shade700),
    );
  }
}
