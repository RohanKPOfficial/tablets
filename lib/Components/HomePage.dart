import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:tablets/Components/AddMeds.dart';
import 'package:tablets/Components/AddReminder.dart';
import 'package:tablets/Components/AppBodyUI.dart';
import 'package:tablets/Config/partenrlinks.dart';
import 'package:tablets/Models/Medicine.dart';
import 'package:tablets/Repository/Snacker.dart';
import 'package:tablets/Repository/dblink.dart';
import 'package:tablets/ShowCase/showcaser.dart';
import 'package:tablets/sizer.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title, required this.userName})
      : super(key: key);

  final String title, userName;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      startShowCase();
    });
  }

  Future startShowCase() async {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('firstTime') == null ||
        prefs.getBool('firstTime') == true) {
      prefs.setBool('firstTime', false);
      ShowCaser.StartShowCase(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BodyWidget2(
        userName: widget.userName,
      ),
      floatingActionButton: Showcase(
        shapeBorder: const CircleBorder(),
        key: ShowCaser.keys[1],
        title: 'Tap to Set Dosage Reminder',
        description:
            'Set a Daily Weekly or Monthly reminder for any medicines in the inventory. Tap Anywhere  to continue.',
        child: SizedBox(
          height: getHeightByFactor(context, 0.08),
          width: getHeightByFactor(context, 0.08),
          child: FittedBox(
            child: FloatingActionButton(
              heroTag: null,
              onPressed: () async {
                List<Medicine> meds = await DatabaseLink.link.getMedicines();
                if (meds.isEmpty) {
                  ShowSnack(context, 4, SnackType.Warn,
                      'No Medicines in inventory . Add Medicines by tapping \'+\'');
                } else {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AddReminder(meds: meds);
                      });
                }
              },
              tooltip: 'Add Dosage Reminder',
              child: const Icon(Icons.notification_add),
            ),
          ),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 5,
        color: Colors.blue,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: EdgeInsets.only(
                  left: 8,
                  right: getWidthByFactor(context, 0.1),
                  top: 8,
                  bottom: 12),
              child: Showcase(
                key: ShowCaser.keys[0],
                showArrow: true,
                title: 'Tap to buy medicines online',
                description:
                    'Get medicines delivered at your doorstep through NetMeds.Tap anywhere to continue.',
                child: FloatingActionButton(
                  elevation: 0,
                  heroTag: null,
                  tooltip: 'Shop for Medicines',
                  onPressed: () {
                    LaunchPartenerSite();
                  },
                  child: Icon(
                    Icons.shopping_bag,
                    size: getWidthByFactor(context, 0.1),
                  ),
                ), //Shop Medds Button
              ),
            ), //Shop MEds Button
            Padding(
              padding: EdgeInsets.only(
                  left: 10,
                  right: getWidthByFactor(context, 0.43),
                  top: 8,
                  bottom: 12),
              child: Showcase(
                key: ShowCaser.keys[2],
                title: 'Tap to add a Medicine',
                description:
                    'Adds a medicine to your medicine inventory.Tap this button to continue',
                child: FloatingActionButton(
                    tooltip: 'Add a Medicine',
                    elevation: 0,
                    heroTag: null,
                    child: Icon(
                      Icons.medication,
                      size: getWidthByFactor(context, 0.1),
                    ),
                    onPressed: () {
                      TextEditingController controller =
                          TextEditingController();
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return const AddMeds();
                          });
                    }),
              ),
            ), //Add Medicines Button
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
