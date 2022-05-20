import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:tablets/BlocsNProviders/InventoryProvider.dart';
import 'package:tablets/Components/splashscreen.dart';
import 'package:tablets/Monetisation/ad_helper.dart';
import 'package:tablets/Repository/Notifier.dart';
import 'package:tablets/Repository/SharedPrefs.dart';
import 'package:tablets/Repository/dblink.dart';
import 'package:flutter/services.dart';
import 'package:tablets/BlocsNProviders/TodoProvider.dart';

import 'Repository/navkey.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AdHelper.initGoogleMobileAds();
  initNotificationService();
  DatabaseLink(); //initialize DbLinks
  SharedPref();
  await DatabaseLink.link.initNewDB();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]); //lock Screen orientation to portrait only
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<InventoryRecon>(create: (_) => InventoryRecon()),
        ChangeNotifierProvider<TodoProvider>(create: (_) => TodoProvider()),
      ],
      child: MaterialApp(
        showPerformanceOverlay: false,
        scrollBehavior: const MaterialScrollBehavior().copyWith(dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown
        }),
        builder: (BuildContext context, Widget? widget) {
          ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text('AwSnap!'), Text('Something Broke 😋')],
              ),
            );
          };
          return widget!;
        },
        title: 'Tablets',
        theme: ThemeData(fontFamily: 'Ubuntu'),
        home: const Splasher(),
        navigatorKey: navkey,
      ),
    );
  }
}
