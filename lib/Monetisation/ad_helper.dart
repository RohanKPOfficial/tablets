import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdHelper {
  static bool testMode = true;
  static Future<InitializationStatus> initGoogleMobileAds() {
    return MobileAds.instance.initialize();
  }

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return AdHelper.testMode
          ? 'ca-app-pub-3940256099942544/6300978111' //testAdunit
          : 'ca-app-pub-7368683137693144/9724419920';
      // 'ca-app-pub-3940256099942544/6300978111 testadunit

    } else if (Platform.isIOS) {
      return AdHelper.testMode
          ? 'ca-app-pub-3940256099942544/6300978111' //testAdunit
          : 'ca-app-pub-7368683137693144/9724419920';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  // static String get interstitialAdUnitId {
  //   if (Platform.isAndroid) {
  //     return "ca-app-pub-3940256099942544/1033173712";
  //   } else if (Platform.isIOS) {
  //     return "ca-app-pub-3940256099942544/4411468910";
  //   } else {
  //     throw UnsupportedError("Unsupported platform");
  //   }
  // }
  //
  // static String get rewardedAdUnitId {
  //   if (Platform.isAndroid) {
  //     return "ca-app-pub-3940256099942544/5224354917";
  //   } else if (Platform.isIOS) {
  //     return "ca-app-pub-3940256099942544/1712485313";
  //   } else {
  //     throw UnsupportedError("Unsupported platform");
  //   }
  // }
}
