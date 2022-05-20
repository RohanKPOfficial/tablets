import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tablets/ShowCase/showcaser.dart';
import 'package:tablets/sizer.dart';

class NameScreen extends StatefulWidget {
  TextEditingController cont = TextEditingController();

  NameScreen({Key? key}) : super(key: key);
  bool InputError = false;
  String text = '';
  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> with TickerProviderStateMixin {
  late AnimationController controller, SpinnerController;
  late Animation _walkAnim;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(seconds: 3, milliseconds: 500), vsync: this);
    SpinnerController =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
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
          widget.text = widget.cont.text;
        });
        // timeDilation = 20;
        Navigator.pushReplacement(
            context,
            PageRouteBuilder(
                transitionDuration: const Duration(seconds: 2),
                pageBuilder: (_, __, ___) => Introduction()));
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    SpinnerController.dispose();
    super.dispose();
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
            Hero(
              tag: 'Logo',
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: getHeightByFactor(context, 0.05),
                  width: getHeightByFactor(context, 0.05),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const RiveAnimation.asset(
                    'Images/logo (2).riv',
                    controllers: [],
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                  ),
                ),
              ),
            ),
            controller.isAnimating
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SpinKitThreeBounce(
                            color: Colors.blue,
                            size: getWidthByFactor(context, 0.1),
                            controller: SpinnerController),
                        SizedBox(
                          height: getHeightByFactor(context, 0.05),
                        ),
                        Text('Setting things up ...'),
                      ],
                    ),
                  )
                : Center(
                    child: SizedBox(
                      width: getWidthByFactor(context, 0.6),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
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
                                        widget.text = widget.cont.text;
                                      });
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                    },
                                    style: TextStyle(
                                        fontSize:
                                            getWidthByFactor(context, 0.045),
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
        child: const Icon(Icons.arrow_forward),
      ),
    );
  }

  void redirCheck(TextEditingController cont) async {
    if (cont.text.isNotEmpty) {
      controller.forward();
      FocusManager.instance.primaryFocus?.unfocus();
    } else {
      setState(() {
        widget.InputError = true;
        widget.text = cont.text;
      });
    }
  }
}
