import 'package:firebase_admob/firebase_admob.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_flutter_provider/provider/auth.dart';
import 'package:recipe_flutter_provider/provider/theme_provider.dart';
import './../constant/static_string.dart';
import 'package:recipe_flutter_provider/locale/app_localization.dart';

class GoogleAddmob {
  static BannerAd myBanner;
  static InterstitialAd myInterstitial;

  // static bool isAdShow = true;
  static double bannerHeight = 0.0;

  static loadAd() {
    interstitialLoad();
    // if (myInterstitial == null) {
    //   print("LOAD BANNER");
    //   bannerHeight = 50.0;
    // } else {
    //   print(" DISPOSE BANNER ");
    //   // disposeBanner();
    //   // myInterstitial?.dispose();
    //   disposeInterstitial();
    //   // bannerHeight = 0.0;
    // }
  }

  // static loadAdI() {
  //   if (myInterstitial == null) {
  //     print("LOAD BANNER");
  //     loadBannerAd();
  //     bannerHeight = 50.0;
  //   } else {
  //     print(" DISPOSE BANNER ");
  //     disposeBanner();
  //     bannerHeight = 0.0;
  //   }
  // }

  static loadBannerAd() {
    myBanner = buildBannerAd();
    myBanner.load();
  }


  static BannerAd buildBannerAd() {
    return BannerAd(
        adUnitId: BannerAd.testAdUnitId,
        size: AdSize.banner,
        targetingInfo: MobileAdTargetingInfo(),
        listener: (MobileAdEvent event) {
          print("Mobile EVENTS : $event");
          if (event == MobileAdEvent.loaded && myBanner != null) {
            bannerHeight = 50.0;
            myBanner.show(anchorOffset: 0.0, horizontalCenterOffset: 0.0);
          } else if (event == MobileAdEvent.failedToLoad) {
            myBanner.dispose();
            bannerHeight = 0.0;
          }
        });
  }

  static interstitialLoad() {
    myInterstitial = buildInterstitialAd();
    myInterstitial.load();
    // myInterstitial.show(
    //   // Positions the banner ad 60 pixels from the bottom of the screen
    //   anchorOffset: 75.0,
    //   // Positions the banner ad 10 pixels from the center of the screen to the right
    //   horizontalCenterOffset: 10.0,
    //   // Banner Position
    //   anchorType: AnchorType.bottom,
    // );
  }

  static InterstitialAd buildInterstitialAd() {
    return InterstitialAd(
      // Replace the testAdUnitId with an ad unit id from the AdMob dash.
      // https://developers.google.com/admob/android/test-ads
      // https://developers.google.com/admob/ios/test-ads
      adUnitId: InterstitialAd.testAdUnitId,
      targetingInfo: MobileAdTargetingInfo(),
      listener: (MobileAdEvent event) {
        print("InterstitialAd event is $event");
        if (event == MobileAdEvent.loaded && myInterstitial != null) {
          // bannerHeight = 50.0;
          // myInterstitial.show(anchorOffset: 0.0, horizontalCenterOffset: 0.0);
        } else if (event == MobileAdEvent.failedToLoad) {
          // myInterstitial.dispose();
          disposeInterstitial();
        }else if (event == MobileAdEvent.closed){
          disposeInterstitial();
        }
      },
    );
  }

  static disposeInterstitial() {
    try {
      if (myInterstitial == null) return;

      myInterstitial?.dispose();
    } catch (e) {
      print(e);
    }
  }

  static disposeBanner() {
    try {
      if (myBanner == null) return;

      myBanner?.dispose();
    } catch (e) {
      print(e);
    }
  }
}

class GoogleAdmob extends StatefulWidget {
  final int adState; // 0: bannerAd, 1: interstitialAd, 2: rewardAd
  GoogleAdmob({Key key, this.adState = 0}) : super(key: key);
  @override
  _GoogleAdmobState createState() => _GoogleAdmobState();
}

class _GoogleAdmobState extends State<GoogleAdmob> {
  BannerAd myBanner;
  InterstitialAd myInterstitial;
  // static bool isAdShow = true;
  double bannerHeight = 0.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print("GoogleAdmob DIDCHANGE Called");
  }

  @override
  void dispose() {
    disposeBanner();
    super.dispose();
  }

  // static loadAd() {
  //   if (Provider.of(context)) {
  //     print("LOAD BANNER");
  //     load();
  //     bannerHeight = 50.0;
  //   } else {
  //     print(" DISPOSE BANNER ");
  //     disposeBanner();
  //     bannerHeight = 0.0;
  //   }
  // }

  bannerLoad() {
    myBanner = buildBannerAd();
    myBanner.load();
    myBanner.show(
      // Positions the banner ad 60 pixels from the bottom of the screen
      anchorOffset: 75.0,
      // Positions the banner ad 10 pixels from the center of the screen to the right
      horizontalCenterOffset: 10.0,
      // Banner Position
      anchorType: AnchorType.bottom,
    );
  }

  interstitialLoad() {
    myInterstitial = buildInterstitialAd();
    myInterstitial.load();
    print("interstitialLoad load");
    myInterstitial.show(
      // Positions the banner ad 60 pixels from the bottom of the screen
      anchorOffset: 75.0,
      // Positions the banner ad 10 pixels from the center of the screen to the right
      horizontalCenterOffset: 10.0,
      // Banner Position
      anchorType: AnchorType.bottom,
    );
    print("interstitialLoad show");
  }
 
  BannerAd buildBannerAd() {
    return BannerAd(
        adUnitId: Platform.isAndroid
            ? StaticString.addMobAndroidBannerUnitId
            : StaticString.addMobiOSBannerUnitId,
        size: AdSize.fullBanner,
        targetingInfo: MobileAdTargetingInfo(),
        listener: (MobileAdEvent event) {
          print("Mobile EVENTS : $event");
          if (event == MobileAdEvent.loaded && myBanner != null) {
            bannerHeight = 50.0;
            myBanner.show(anchorOffset: 0.0, horizontalCenterOffset: 0.0);
          } else if (event == MobileAdEvent.failedToLoad) {
            myBanner.dispose();
            bannerHeight = 0.0;
          }
        });
  }

  InterstitialAd buildInterstitialAd() {
    // Replace the testAdUnitId with an ad unit id from the AdMob dash.
    // https://developers.google.com/admob/android/test-ads
    // https://developers.google.com/admob/ios/test-ads
    return InterstitialAd(
        adUnitId: InterstitialAd.testAdUnitId,
        targetingInfo: MobileAdTargetingInfo(),
        listener: (MobileAdEvent event) {
          print("InterstitialAd event is $event");
          print("Mobile EVENTS : $event");
          if (event == MobileAdEvent.loaded && myInterstitial != null) {
            myInterstitial.show(anchorOffset: 0.0, horizontalCenterOffset: 0.0);
          } else if (event == MobileAdEvent.failedToLoad) {
            myInterstitial.dispose();
          }
        });
  }

  disposeBanner() {
    try {
      if (myBanner == null) return;

      myBanner?.dispose();
      myInterstitial?.dispose();
      myBanner = null;
      myInterstitial = null;
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    print("GoogleAdmob`s BUILD  called");
    if (Provider.of<AuthProvider>(context).getAdmobStatus == true &&
        myBanner == null) {
      print("true");
      bannerHeight = 50.0;
      switch (widget.adState) {
        case 0:
          buildBannerAd();
          print("bannerLoad");
          break;
        case 1:
          interstitialLoad();
          bannerHeight = 0.0;
          print("interstitialLoad");
          break;
        default:
          bannerLoad();
          break;
      }
    } else if (Provider.of<AuthProvider>(context).getAdmobStatus == false) {
      print("false");
      disposeBanner();
      myBanner = null;
      bannerHeight = 0.0;
    }
    ThemeNotifier themeNotifier = Provider.of<ThemeNotifier>(context);
    return AnimatedContainer(
      duration: Duration(milliseconds: 250),
      height: bannerHeight,
      width: double.infinity,
      color:
          themeNotifier.getTheme() == lightTheme ? Colors.white : Colors.black,
    );
  }
}
