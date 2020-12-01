import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:recipe_flutter_provider/api/api_call.dart';
import 'package:recipe_flutter_provider/provider/auth.dart';
import 'package:recipe_flutter_provider/provider/theme_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:recipe_flutter_provider/widget/google_admob.dart';
import 'package:recipe_flutter_provider/locale/app_localization.dart';

import '../widget/safearea_with_banner.dart';
import '../screens/search_screen.dart';
import '../constant/static_string.dart';
import '../widget/app_drawer.dart';
import '../provider/recipe.dart';
import '../widget/recipes_grid.dart';
import '../widget/fav_recipes_grid.dart';
import '../widget/no_recipes.dart';

class FavoriteScreen extends StatefulWidget {
  static const routeName = '/favorite-screen';
  final bool isFromDrawer;

  const FavoriteScreen(this.isFromDrawer);
  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  bool _isInit = true;
  bool _isLoading = false;
  bool _isAdLoading = false;
  bool _netState = true;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String filePath = "";
  InterstitialAd myInterstitial;
  interstitialLoad() {
    myInterstitial = buildInterstitialAd();
    myInterstitial.load();
  }

  InterstitialAd buildInterstitialAd() {
    setState(() {
      _isAdLoading = true;
    });
    return InterstitialAd(
      // Replace the testAdUnitId with an ad unit id from the AdMob dash.
      // https://developers.google.com/admob/android/test-ads
      // https://developers.google.com/admob/ios/test-ads
      adUnitId: InterstitialAd.testAdUnitId,
      targetingInfo: MobileAdTargetingInfo(),
      listener: (MobileAdEvent event) {
        print("InterstitialAd event is $event");
        if (event == MobileAdEvent.loaded && myInterstitial != null) {
          setState(() {
            _isAdLoading = false;
          });
          // bannerHeight = 50.0;
          myInterstitial.show(anchorOffset: 0.0, horizontalCenterOffset: 0.0);
        } else if (event == MobileAdEvent.failedToLoad) {
          // myInterstitial.dispose();
          disposeInterstitial();
        } else if (event == MobileAdEvent.closed) {
          disposeInterstitial();
        }
      },
    );
  }

  disposeInterstitial() {
    try {
      if (myInterstitial == null) return;

      myInterstitial?.dispose();
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    // GoogleAddmob.loadAd();
    // interstitialLoad();
  }

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });

      try {
        _netState = await ApiCall.checkCon();
        filePath = await ApiCall.getFilePath();

        // if (_netState){
        //   await Provider.of<RecipesProvider>(context, listen: false)
        //       .fetchAndSetFavRecipes(context: context);
        // print("1111111");
        // }
        // else{
        //   await Provider.of<RecipesProvider>(context, listen: false)
        //       .readAndSetFavs(context: context);
        // print("2222222222");
        // }
        setState(() {
          _isLoading = false;
        });
      } catch (error) {
        setState(() {
          _isLoading = false;
        });
      }
    }
    _isInit = false;

    super.didChangeDependencies();
    // if (Provider.of<AuthProvider>(context).getScreenIsModel == true) {
    //   return;
    // }
    // if (_scaffoldKey?.currentState?.isDrawerOpen == true) {
    //   print(" ================ ${_scaffoldKey?.currentState?.isDrawerOpen}");
    //   Provider.of<AuthProvider>(context).setAdmobStatus = false;
    // } else if (_scaffoldKey?.currentState?.isDrawerOpen == false) {
    //   Provider.of<AuthProvider>(context).setAdmobStatus = true;
    // }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final FavoriteScreen args = ModalRoute.of(context)?.settings?.arguments;
    // print(" -------------------------------- ${args?.isFromDrawer ?? false}");
    List<RecipeItem> recipes =
        Provider.of<RecipesProvider>(context, listen: false).favRecipes;

    return _isAdLoading
        ? Center(child: CircularProgressIndicator())
        : Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: Text(S.of(context).favourite),
              // actions: <Widget>[
              //   IconButton(
              //     icon: Icon(Icons.search),
              //     onPressed: () {
              //       showSearch(
              //         context: context,
              //         delegate: SearchScreen(SearchType.values[2]),
              //       );
              //     },
              //   )
              // ],
            ),
            // drawer: AppDrawer(),
            body: _isLoading
                ? Center(child: CircularProgressIndicator())
                : Column(
                    children: <Widget>[
                      Expanded(
                          child: _netState
                              ? Consumer<RecipesProvider>(
                                  builder: (ctx, recipeProvider, _) {
                                  return recipeProvider.favRecipes.length > 0
                                      ? RecipesGrid(
                                          recipeProvider.favRecipes,
                                          showFavorite: false,
                                          netConnectivity: _netState,
                                        )
                                      : NoRecipes();
                                })
                              : FavRecipesGrid(
                                  recipes,
                                  showFavorite: false,
                                  netConnectivity: _netState,
                                  filePath: filePath,
                                )),
                      // mounted
                      //     ? GoogleAdmob(
                      //         adState: 1,
                      //       )
                      //     : null,
                      // GoogleAdmob(adState: 1,),
                    ],
                  ));
  }
}
