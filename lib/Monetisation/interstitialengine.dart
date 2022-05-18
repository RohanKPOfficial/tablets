import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tablets/Monetisation/ad_helper.dart';

class InterstitialEngine {
  static InterstitialEngine instance = InterstitialEngine.internalCOnstructor();
  InterstitialEngine.internalCOnstructor() {
    fetchAd();
  }
  InterstitialAd? ad;

  factory InterstitialEngine() {
    return instance;
  }

  fetchAd() {
    InterstitialAd.load(
        adUnitId: AdHelper.interstitialAdUnitId,
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            // Keep a reference to the ad so you can show it later.
            this.ad = ad;
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error');
          },
        ));
  }

  showAd() {
    if (ad != null) {
      ad!.show();
      fetchAd();
    } else {
      fetchAd();
    }
  }
}
