import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:tablets/BlocsNProviders/InventoryProvider.dart';
import 'package:tablets/Components/inventorytile.dart';
import 'package:tablets/Components/meddetails.dart';
import 'package:tablets/Models/Medicine.dart';
import 'package:tablets/Models/TodoItem.dart';
import 'package:tablets/Models/inventoryItem.dart';
import 'package:tablets/Models/reminderList.dart';
import 'package:tablets/Monetisation/ad_helper.dart';
import 'package:tablets/Repository/Snacker.dart';
import 'package:tablets/Repository/dblink.dart';
import 'package:tablets/sizer.dart';

import 'package:tablets/BlocsNProviders/TodoProvider.dart';

import '../Repository/timerBuilder.dart';
import '../ShowCase/showcaser.dart';

class BodyWidget2 extends StatefulWidget {
  BodyWidget2({required this.userName});
  String userName;

  @override
  State<BodyWidget2> createState() => _BodyWidget2State();
}

class _BodyWidget2State extends State<BodyWidget2> {
  List<TodoItem> pending = [];

  late BannerAd _bannerAd;

  bool _isBannerAdReady = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      InventoryRecon().update(); //refresh inventory on app open
    });
    loadAds();
  }

  Future<void> loadAds() async {
    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: const AdSize(width: 200, height: 175),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );

    _bannerAd.load();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Stack(
          children: [
            Positioned(
              top: getHeightByFactor(context, 0.23),
              left: getWidthByFactor(context, 0.57),
              child: SizedBox(
                  height: getHeightByFactor(context, 0.23),
                  width: getHeightByFactor(context, 0.23),
                  child: Image.asset(
                    'Images/box1.png',
                  )),
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: getHeightByFactor(context, 0.1),
                    ),
                    Row(
                      children: [
                        Text(
                          "Hi ",
                          style: TextStyle(
                              fontSize: getWidthByFactor(context, 0.06),
                              fontWeight: FontWeight.bold),
                        ),
                        Showcase(
                          key: ShowCaser.keys[3],
                          title: 'Change Name',
                          description: 'Tap here to edit your Name',
                          child: Hero(
                            tag: 'HeroName',
                            child: Container(
                              child: GestureDetector(
                                onTap: () {
                                  changeNamePopup(context);
                                },
                                child: Text(
                                  widget.userName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                          color: Colors.black,
                                          fontSize:
                                              getWidthByFactor(context, 0.06),
                                          fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                Consumer<TodoProvider>(
                  builder: (context, _todoProvider, _) {
                    return Column(
                      children: [
                        Text(
                          _todoProvider.tds.Todos.isEmpty
                              ? "No reminders set for today"
                              : _todoProvider.allChecked
                                  ? "All Caught Up ! Hurray"
                                  : "Upcoming Medication Dosages",
                          style: TextStyle(
                              fontSize: getWidthByFactor(context, 0.045),
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: getFullWidth(context),
                          height: getHeightByFactor(context, 0.35),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                itemCount: _todoProvider.tds.Todos.length,
                                itemBuilder: (context, index) {
                                  TodoItem tdi = _todoProvider.tds.Todos[index];
                                  return TodoListItem(tdi: tdi);
                                }),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: getHeightByFactor(context, 0.1)),
              child: DraggableScrollableSheet(
                minChildSize: 0.5,
                maxChildSize: 1,
                initialChildSize: 0.5,
                snap: true,
                snapSizes: const [0.5, 1],
                builder: (context, controller) => Container(
                  color: Colors.white,
                  height: getFullHeight(context),
                  child: Consumer<InventoryRecon>(
                      builder: (context, _inventoryRecon, _) {
                    return Card(
                      color: Colors.grey.shade100,
                      child: Column(
                        children: _inventoryRecon.currentInventory.isEmpty
                            ? [
                                Expanded(
                                  child: ListView(
                                    controller: controller,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: getHeightByFactor(
                                                context, 0.1)),
                                        child: const Center(
                                            child: Text(
                                                'No medicines in inventory add one by tapping \'+\'')),
                                      ),
                                    ],
                                  ),
                                )
                              ]
                            : [
                                const Icon(Icons.keyboard_arrow_up),
                                Expanded(
                                  child: GridView(
                                    controller: controller,
                                    physics: const BouncingScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            crossAxisSpacing: 4.0,
                                            mainAxisSpacing: 4.0),
                                    children: List.generate(
                                        _inventoryRecon
                                                .currentInventory.length +
                                            1, (index) {
                                      if (index <
                                          _inventoryRecon
                                              .currentInventory.length) {
                                        InventoryItem current = _inventoryRecon
                                            .currentInventory[index];
                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: inventorytile(
                                            invIndex: index,
                                            item: current,
                                            context: context,
                                          ),
                                        );
                                      } else {
                                        Widget adTile = const Text('');
                                        if (_isBannerAdReady) {
                                          _bannerAd.dispose();
                                          loadAds();
                                          adTile = ClipRRect(
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              physics:
                                                  const BouncingScrollPhysics(),
                                              child: SizedBox(
                                                width: _bannerAd.size.width
                                                    .toDouble(),
                                                height: _bannerAd.size.height
                                                    .toDouble(),
                                                child: AdWidget(ad: _bannerAd),
                                              ),
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          );
                                        }
                                        return adTile;
                                      }
                                    }),
                                  ),
                                ),
                              ],
                      ),
                    );
                  }),
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
            Positioned(
              left: getWidthByFactor(context, 0.8),
              child: Showcase(
                radius: BorderRadius.circular(getHeightByFactor(context, 0.1)),
                key: ShowCaser.keys[4],
                title: 'All Done',
                description:
                    'Tap here to start this demonstartion again . Add a medicine and set your first medicine reminder now',
                child: ElevatedButton(
                  style: ButtonStyle(
                      elevation: MaterialStateProperty.all(0.0),
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                      shape: MaterialStateProperty.all(const CircleBorder())),
                  child: Icon(
                    Icons.help,
                    color: Theme.of(context).primaryColor,
                    size: getHeightByFactor(context, 0.05),
                  ),
                  onPressed: () {
                    ShowCaser.StartShowCase(context);
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void changeNamePopup(BuildContext context) {
    TextEditingController controller = TextEditingController();
    controller.text = widget.userName;
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
                      SharedPreferences Prefs =
                          await SharedPreferences.getInstance();
                      await Prefs.setString('UserName', controller.text);
                      setState(() {
                        widget.userName = controller.text;
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

class TodoListItem extends StatefulWidget {
  const TodoListItem({
    Key? key,
    required this.tdi,
  }) : super(key: key);

  final TodoItem tdi;

  @override
  State<TodoListItem> createState() => _TodoListItemState();
}

class _TodoListItemState extends State<TodoListItem>
    with TickerProviderStateMixin {
  late AnimationController controller;
  // late AnimationController controller2;
  late Animation animation;
  // Color buttonColor = Colors.yellow.shade300;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);

    animation = ColorTween(begin: Colors.yellow.shade300, end: Colors.red)
        .animate(controller);
    controller.repeat();
    controller.addListener(() {
      setState(() {});
    });
    Future.delayed(const Duration(seconds: 10), () {
      controller.reset();
      controller.stop();
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: Checkbox(
            onChanged: (x) {},
            value: widget.tdi.done,
          ),
        ),
        Expanded(
          flex: 6,
          child: Text(
            '${widget.tdi.done ? '' : widget.tdi.s.hour < DateTime.now().hour ? 'Missed!-' : ''}${widget.tdi.med.Name} ${widget.tdi.s.dosage == widget.tdi.s.dosage.toInt() ? widget.tdi.s.dosage.toInt() : widget.tdi.s.dosage} ${Shorten(widget.tdi.med.Type)} @ ${TodoItem.to12Hour(widget.tdi.s.hour, widget.tdi.s.minute)}',
            style: widget.tdi.done == true
                ? const TextStyle(decoration: TextDecoration.lineThrough)
                : DateTime.now().hour > widget.tdi.s.hour
                    ? const TextStyle(
                        color: Colors.redAccent, fontWeight: FontWeight.bold)
                    : null,
            textAlign: TextAlign.left,
          ),
        ),
        Expanded(
          flex: 2,
          child: EarlierThanNow(widget.tdi.s.hour, widget.tdi.s.minute) &&
                  !widget.tdi.done
              ? TextButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            getHeightByFactor(context, 0.1)),
                        side: BorderSide(
                            color: Colors.grey.shade400,
                            width: getHeightByFactor(context, 0.001)))),
                    backgroundColor: MaterialStateProperty.all(animation.value),
                  ),
                  child: const Text('Taken'),
                  onPressed: () async {
                    controller.reset();
                    controller.stop();
                    int _success = await DatabaseLink.ConsumeMedicine(
                        widget.tdi.med.Id!,
                        widget.tdi.med.Name,
                        widget.tdi.s.dosage,
                        widget.tdi.s.Id!);
                    if (_success == 1) {
                      InventoryRecon().update();
                      TodoProvider().updateFetch();
                    } else {
                      ShowSnack(context, 2, SnackType.Warn,
                          'Not Enough Stocks please update inventory or shop online');
                      Navigator.push(
                          context,
                          PageRouteBuilder(
                              transitionDuration:
                                  const Duration(milliseconds: 350),
                              pageBuilder: (_, __, ___) => MedDetails(
                                    InvIndex: InventoryRecon()
                                        .getInvIndex(widget.tdi.med.Name),
                                  )));
                    }
                  },
                )
              : const Text(''),
        )
      ],
    );
  }
}

Color tileColor(double stock, int i) {
  if (stock == 0) {
    return Colors.redAccent;
  } else if (stock > i) {
    return Colors.green.shade400;
  } else {
    return Colors.orange;
  }
}

String getScheduleType(Schedule s) {
  if (s.day != 0) {
    return 'Weekly';
  } else if (s.date != 0) {
    return 'Monthly';
  } else {
    return 'Daily';
  }
}
