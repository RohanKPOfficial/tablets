import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tablets/ShowCase/showcaser.dart';
import 'package:tablets/sizer.dart';
import 'namescreen.dart';

class Splasher extends StatefulWidget {
  const Splasher({Key? key}) : super(key: key);

  @override
  State<Splasher> createState() => _SplasherState();
}

class _SplasherState extends State<Splasher> {
  @override
  void initState() {
    super.initState();
    delayedNameCheckRedir();
  }

  void delayedNameCheckRedir() async {
    SharedPreferences instance = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(seconds: 3));
    String? Name = instance.getString('UserName');
    if (Name == null) {
      Navigator.pushReplacement(
          context,
          PageRouteBuilder(
              transitionDuration: const Duration(seconds: 2),
              pageBuilder: (_, __, ___) => NameScreen()));
    } else {
      Navigator.pushReplacement(
          context,
          PageRouteBuilder(
              transitionDuration: const Duration(seconds: 2),
              pageBuilder: (_, __, ___) => Introduction()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image.asset('Images/output-onlinegiftools.gif'),
              Hero(
                tag: 'Logo',
                child: Container(
                    height: 512,
                    width: 512,
                    alignment: Alignment.center,
                    child: const RiveAnimation.asset(
                      'Images/splash (1).riv',
                      alignment: Alignment.center,
                      fit: BoxFit.scaleDown,
                    )),
              ),
              Hero(
                tag: '2',
                child: Text(
                  'Tablets',
                  style: TextStyle(
                    fontSize: getHeightByFactor(context, 0.05),
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
