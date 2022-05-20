import 'dart:ui';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:basic_utils/basic_utils.dart' as Stringy;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:tablets/BlocsNProviders/InventoryProvider.dart';
import 'package:tablets/Components/animated_name_widget.dart';
import 'package:tablets/Components/inventorytile.dart';
import 'package:tablets/Components/meddetails.dart';
import 'package:tablets/Components/todo_list_item.dart';
import 'package:tablets/Models/Medicine.dart';
import 'package:tablets/Models/TodoItem.dart';
import 'package:tablets/Models/inventoryItem.dart';
import 'package:tablets/Models/reminderList.dart';
import 'package:tablets/Monetisation/ad_helper.dart';
import 'package:tablets/Monetisation/adtile.dart';
import 'package:tablets/Repository/SharedPrefs.dart';
import 'package:tablets/Repository/Snacker.dart';
import 'package:tablets/Repository/dblink.dart';
import 'package:tablets/sizer.dart';

import 'package:tablets/BlocsNProviders/TodoProvider.dart';

import '../Monetisation/interstitialengine.dart';
import '../Repository/timerBuilder.dart';
import '../ShowCase/showcaser.dart';

class BodyWidget2 extends StatefulWidget {
  BodyWidget2();

  @override
  State<BodyWidget2> createState() => _BodyWidget2State();
}

class _BodyWidget2State extends State<BodyWidget2> {
  List<TodoItem> pending = [];

  late BannerAd _bannerAd;
  // InterstitialAd? interstitialAd;

  bool _isBannerAdReady = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      InventoryRecon().update(); //refresh inventory on app open
    });
    loadAds();
  }

  loadAds() {
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

    // InterstitialAd.load(
    //     adUnitId: AdHelper.interstitialAdUnitId,
    //     request: AdRequest(),
    //     adLoadCallback: InterstitialAdLoadCallback(
    //       onAdLoaded: (InterstitialAd ad) {
    //         // Keep a reference to the ad so you can show it later.
    //         interstitialAd = ad;
    //       },
    //       onAdFailedToLoad: (LoadAdError error) {
    //         print('InterstitialAd failed to load: $error');
    //       },
    //     ));
    _bannerAd.load();
    InterstitialEngine();
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
                          child: Container(
                            child: AnimatedNameWidget(),
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
                      builder: (context, _inventoryRecon, child) {
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
                                              1,
                                          (index) {
                                            if (index > 1) {
                                              InventoryItem current =
                                                  _inventoryRecon
                                                          .currentInventory[
                                                      index - 1];
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: inventorytile(
                                                  invIndex: index,
                                                  item: current,
                                                  context: context,
                                                ),
                                              );
                                            } else {
                                              if (index == 0) {
                                                InventoryItem current =
                                                    _inventoryRecon
                                                            .currentInventory[
                                                        index];
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: inventorytile(
                                                    invIndex: index,
                                                    item: current,
                                                    context: context,
                                                  ),
                                                );
                                              }
                                              return child!;
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                          ),
                        );
                      },
                      child: adtile(
                        bannerAd: _bannerAd,
                        bannerReady: _isBannerAdReady,
                      )),
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
}
