import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tablets/Config/partenrlinks.dart';
import 'package:tablets/sizer.dart';

class adtile extends StatefulWidget {
  adtile({Key? key, required this.bannerAd, required this.bannerReady})
      : super(key: key);
  BannerAd bannerAd;
  bool bannerReady;
  @override
  State<adtile> createState() => _adtileState();
}

class _adtileState extends State<adtile> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: widget.bannerReady
          ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: SizedBox(
                width: widget.bannerAd.size.width.toDouble(),
                height: widget.bannerAd.size.height.toDouble(),
                child: AdWidget(ad: widget.bannerAd),
              ),
            )
          : GestureDetector(
              onTap: () {
                LaunchPartenerSite();
              },
              child: Container(
                color: Colors.yellow.shade300,
                child: Stack(children: [
                  Image.asset(
                    'Images/gif6.gif',
                    fit: BoxFit.contain,
                  ),
                  Positioned(
                      top: getHeightByFactor(context, 0.01),
                      child: Text('  Forgot Buying medicines?')),
                  Positioned(
                      top: getHeightByFactor(context, 0.18),
                      child: Text('  Tap here to Order Online'))
                ]),
              ),
            ),
      borderRadius: BorderRadius.circular(10),
    );
  }
}
