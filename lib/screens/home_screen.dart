import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:recipe_flutter_provider/provider/auth.dart';
import 'package:recipe_flutter_provider/provider/theme_provider.dart';
import 'package:recipe_flutter_provider/screens/favorite_screen.dart';
import 'package:recipe_flutter_provider/screens/profile_screen.dart';
import 'package:recipe_flutter_provider/widget/google_admob.dart';
import 'package:recipe_flutter_provider/locale/app_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:recipe_flutter_provider/locale/app_localization.dart';
import '../constant/shared_preferences_helper.dart';

import '../constant/static_string.dart';
import '../widget/app_drawer.dart';
import './categories_screen.dart';
import './recipes_screen.dart';
import './main_home_screen.dart';
import '../screens/search_screen.dart';
import '../screens/shopping_list_screen.dart';
import '../screens/main_auth_screen.dart';
import '../screens/subscription_screen.dart';
import '../api/api_call.dart';
import '../widget/safearea_with_banner.dart';
import '../provider/recipe.dart';
import '../provider/category.dart';
import '../provider/user.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home-screen';
  final bool isFromDrawer;

  const HomeScreen(this.isFromDrawer);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ThemeData themeData;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _initState = true;
  bool _isLoading = true;
  bool _isAd = false;
  int selectPage = 0;
  TabController _tabController;
  InterstitialAd myInterstitial;
  interstitialLoad() {
    if (!Provider.of<AuthProvider>(context, listen: false).getAdmobStatus) {
      return;
    }
    myInterstitial = buildInterstitialAd();
    myInterstitial.load();
    _isAd = true;
  }

  InterstitialAd buildInterstitialAd() {
    return InterstitialAd(
      adUnitId: InterstitialAd.testAdUnitId,
      targetingInfo: MobileAdTargetingInfo(),
      listener: (MobileAdEvent event) {
        print("InterstitialAd event is $event");
        if (event == MobileAdEvent.loaded && myInterstitial != null) {
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
      setState(() {
        _isAd = false;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    // interstitialLoad();
    SharedPreferencesHelper.getLangStatus().then((value) {
        setState(() {
          if (value == "es")
            S.load(Locale('es', 'ES'));
          else 
            S.load(Locale('en', 'US'));
        });
      });
  }

  @override
  void didChangeDependencies() async {
    if (_initState) {
      setState(() {
        _isLoading = true;
      });
      print("_initState");
    }
    if (!await ApiCall.checkCon()) {
      selectPage = 2;
      await Provider.of<RecipesProvider>(context, listen: false)
          .readAndSetFavs(context: context);
    } else {

      await Provider.of<RecipesProvider>(context, listen: false)
          .fetchAndSetRecipes(context: context);
      await Provider.of<RecipesProvider>(context, listen: false)
          .fetchAndSetFavRecipes(context: context);
      await Provider.of<CategoryProvider>(context, listen: false)
          .fetchAndSetCategories(context: context);
    }
    if (Provider.of<AuthProvider>(context, listen: false).loginStatus) {
      await Provider.of<RecipesProvider>(context, listen: false)
          .fetchAndSetSLRecipes(context: context);
    }

    setState(() {
      _isLoading = false;
    });
    _initState = false;
    super.didChangeDependencies();
 
    if (_scaffoldKey?.currentState?.isDrawerOpen == true) {
      print(" ================ ${_scaffoldKey?.currentState?.isDrawerOpen}");
      Provider.of<AuthProvider>(context).setAdmobStatus = false;
    } else if (_scaffoldKey?.currentState?.isDrawerOpen == false) {
      Provider.of<AuthProvider>(context).setAdmobStatus = true;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final HomeScreen args = ModalRoute.of(context)?.settings?.arguments;
    print(" -------------------------------- ${args?.isFromDrawer ?? false}");

    ThemeNotifier themeNotifier = Provider.of<ThemeNotifier>(context);
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : DefaultTabController(
            length: 5,
            initialIndex: selectPage,
            child: Scaffold(
              key: _scaffoldKey,
              bottomNavigationBar: BottomAppBar(
                child: TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).accentColor,
                  unselectedLabelColor: Colors.grey,
                  onTap: (int d) {
                    if (!_isAd) {
                      interstitialLoad();
                    }
                  },
                  tabs: <Widget>[
                    Consumer<UserProvider>(
                        builder: (ctx, userProvider, child) => Tab(
                              text: S.of(context).home,
                              icon: Icon(Icons.home),
                            )),
                    Consumer<UserProvider>(
                        builder: (ctx, userProvider, child) => Tab(
                              text: S.of(context).shoppingList,
                              icon: Icon(Icons.shopping_basket),
                            )),
                    Consumer<UserProvider>(
                        builder: (ctx, userProvider, child) => Tab(
                              text: S.of(context).favourite,
                              icon: Icon(Icons.favorite),
                            )),
                    Consumer<UserProvider>(
                        builder: (ctx, userProvider, child) => Tab(
                              text: S.of(context).profile,
                              icon: Icon(Icons.supervised_user_circle),
                            )),
                    Consumer<UserProvider>(
                        builder: (ctx, userProvider, child) => Tab(
                              text: S.of(context).subscription,
                              icon: Icon(Icons.subscriptions),
                            ))
                  ],
                ),
              ),
              body: Column(
                children: <Widget>[
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: <Widget>[
                        MainHomeScreen(),
                        ShoppingListScreen(),
                        FavoriteScreen(widget.isFromDrawer),
                        ProfileScreen(),
                        SubscriptionScreen(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
