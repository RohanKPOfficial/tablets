import 'package:flutter/material.dart';
import 'package:tablets/main.dart';
import 'package:tablets/sizer.dart';

class Splasher extends StatefulWidget {
  const Splasher({Key? key}) : super(key: key);

  @override
  State<Splasher> createState() => _SplasherState();
}

class _SplasherState extends State<Splasher> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const MyHomePage(title: 'Tablets')));
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
              Image.asset('Images/output-onlinegiftools.gif'),
              Text(
                'Tablets',
                style: TextStyle(
                  fontSize: getHeightByFactor(context, 0.05),
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
