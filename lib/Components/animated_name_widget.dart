import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:tablets/Repository/SharedPrefs.dart';
import 'package:tablets/Repository/Snacker.dart';
import 'package:tablets/sizer.dart';

class AnimatedNameWidget extends StatefulWidget {
  const AnimatedNameWidget({Key? key}) : super(key: key);

  @override
  State<AnimatedNameWidget> createState() => _AnimatedNameWidgetState();
}

class _AnimatedNameWidgetState extends State<AnimatedNameWidget> {
  String _name = SharedPref().obj!.getString('UserName')!;
  bool _changed = false;
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      if (_changed == true) {
        _changed = false;
      }
    });
    return AnimatedTextKit(
      onTap: () {
        setState(() {
          changeNamePopup(context);
        });
      },
      repeatForever: false,
      key: _changed ? UniqueKey() : null,
      totalRepeatCount: 1,
      animatedTexts: [
        TyperAnimatedText(
          _name,
          speed: Duration(milliseconds: 200),
          textStyle: TextStyle(
              fontSize: getWidthByFactor(context, 0.06),
              fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void changeNamePopup(BuildContext context) {
    TextEditingController controller = TextEditingController();
    controller.text = SharedPref().obj!.getString('UserName')!;
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(getHeightByFactor(context, 0.03))),
            content: Container(
              height: getHeightByFactor(context, 0.2),
              width: getWidthByFactor(context, 0.5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Edit Name',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: getHeightByFactor(context, 0.02))),
                  TextField(
                    maxLength: 20,
                    controller: controller,
                    decoration:
                        const InputDecoration(helperText: 'Enter First Name'),
                  ),
                ],
              ),
              // decoration:
              //     BoxDecoration(borderRadius: BorderRadius.circular(100)),
            ),
            actions: [
              Center(
                child: TextButton(
                  onPressed: () async {
                    if (controller.text.isEmpty) {
                      ShowSnack(
                          context, 2, SnackType.Warn, 'Name can\'t be empty');
                    } else {
                      // SharedPreferences Prefs =
                      // await SharedPreferences.getInstance();
                      await SharedPref()
                          .obj!
                          .setString('UserName', controller.text);
                      setState(() {
                        _name = SharedPref().obj!.getString('UserName')!;
                        _changed = true;
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Change Name'),
                ),
              )
            ],
          );
        });
  }
}
