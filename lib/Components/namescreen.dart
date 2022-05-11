import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tablets/main.dart';
import 'package:tablets/sizer.dart';

class NameScreen extends StatefulWidget {
  TextEditingController cont = TextEditingController();

  NameScreen({Key? key}) : super(key: key);
  bool flying = false;
  bool InputError = false;
  String text = '';
  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation _walkAnim;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: Duration(seconds: 3, milliseconds: 500), vsync: this);
    _walkAnim = Tween<double>(begin: 0.05, end: 0.9).animate(controller);
    _walkAnim.addListener(() {
      setState(() {});
    });
    _walkAnim.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        String Name = widget.cont.text;
        SharedPreferences Prefs = await SharedPreferences.getInstance();
        Prefs.setString('UserName', Name);
        setState(() {
          widget.flying = true;
          widget.text = widget.cont.text;
        });
        // timeDilation = 20;
        Navigator.pushReplacement(
            context,
            PageRouteBuilder(
                transitionDuration: Duration(seconds: 2),
                pageBuilder: (_, __, ___) =>
                    MyHomePage(title: 'Tablets', userName: Name)));
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
                left: getWidthByFactor(context, _walkAnim.value),
                top: getHeightByFactor(context, 0.06),
                child: Image.asset('Images/transpWalk.gif')),
            Positioned(
              left: getWidthByFactor(context, 0.2),
              top: getHeightByFactor(context, 0.655),
              child: Visibility(
                visible: widget.flying,
                child: Hero(
                  tag: 'HeroName',
                  child: Container(
                    child: Text(
                      '${widget.text}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.black,
                          fontSize: getWidthByFactor(context, 0.045),
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                ),
              ),
            ),
            Hero(
              tag: 'Logo',
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: getHeightByFactor(context, 0.05),
                  width: getHeightByFactor(context, 0.05),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: RiveAnimation.asset(
                    'Images/logo (2).riv',
                    controllers: [],
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                  ),
                ),
              ),
            ),
            Center(
              child: Container(
                width: getWidthByFactor(context, 0.6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // left: getWidthByFactor(context, _walkAnim.value),
                    // top: getHeightByFactor(context, 0.06),
                    // child:

                    // Container(
                    //   height: 400,
                    //   width: ,
                    //   child: Stack(
                    //     fit: StackFit.loose,
                    //     children: [
                    //
                    //     ],
                    //   ),
                    // ),
                    Text(
                      'What should I call you?',
                      style: TextStyle(
                          fontSize: getWidthByFactor(context, 0.1),
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: getHeightByFactor(context, 0.05),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                              onSubmitted: (String x) {
                                redirCheck(widget.cont);
                                setState(() {
                                  widget.flying = true;
                                  widget.text = widget.cont.text;
                                });
                              },
                              style: TextStyle(
                                  fontSize: getWidthByFactor(context, 0.045),
                                  fontWeight: FontWeight.normal),
                              controller: widget.cont,
                              maxLength: 20,
                              decoration: InputDecoration(
                                  hintText: 'Please Provide a First Name',
                                  errorText: widget.InputError
                                      ? "Name Can't be empty"
                                      : null)),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: getHeightByFactor(context, 0.1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          redirCheck(widget.cont);
        },
        child: Icon(Icons.arrow_forward),
      ),
    );
  }

  void redirCheck(TextEditingController cont) async {
    if (cont.text.isNotEmpty) {
      controller.forward();
    } else {
      setState(() {
        widget.InputError = true;
        widget.text = cont.text;
      });
    }
  }
}
