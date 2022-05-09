import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:tablets/Components/Temp.dart';
import 'package:tablets/main.dart';
import 'package:tablets/sizer.dart';
import 'package:flutter/scheduler.dart' show timeDilation;

class Splasher extends StatefulWidget {
  const Splasher({Key? key}) : super(key: key);

  @override
  State<Splasher> createState() => _SplasherState();
}

class _SplasherState extends State<Splasher> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3, milliseconds: 500), () {
      timeDilation = 20;
      Navigator.pushReplacement(

          // MyHomePage(title: 'Tablets')
          //   Temp()
          context,
          MaterialPageRoute(
              builder: (context) => MyHomePage(title: 'Tablets')));
    });
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
                    child: RiveAnimation.asset(
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
