import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:tablets/Components/HomePage.dart';

//Keys fro showcase
class ShowCaser {
  static List<GlobalKey> keys =
      List.generate(6, (index) => GlobalKey()); //initial 3 buttons
  // static List<GlobalKey> addmedskeys =
  //     List.generate(1, (index) => GlobalKey()); //add medicine

  static StartShowCase(context) {
    ShowCaseWidget.of(context)?.startShowCase(keys);
  }
}

class Introduction extends StatelessWidget {
  const Introduction({Key? key, required this.User}) : super(key: key);
  final String User;
  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      builder: Builder(
        builder: (context) => MyHomePage(title: 'Tablets', userName: User),
      ),
    );
  }
}
