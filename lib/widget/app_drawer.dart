import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_flutter_provider/provider/recipe.dart';
import 'package:recipe_flutter_provider/widget/google_admob.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:share/share.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:recipe_flutter_provider/locale/app_localization.dart';

import '../provider/theme_provider.dart';
import '../constant/static_string.dart';
import '../screens/home_screen.dart';
import '../screens/favorite_screen.dart';
import '../provider/auth.dart';
import '../screens/main_auth_screen.dart';
import '../screens/profile_screen.dart';

class AppDrawer extends StatelessWidget {
  final RateMyApp _rateMyApp = RateMyApp();
  GlobalKey _drawerKey = GlobalKey();


  @override
  Widget build(BuildContext context) {
    print(_drawerKey?.currentContext?.findRenderObject());
    return Drawer(
      key: _drawerKey,
      child: Column(
        children: <Widget>[
          AppBar(
            automaticallyImplyLeading: false,
            title: Text(S.of(context).appTitle),
            elevation: 1.5,
          ),
          ListTile(
              leading: Icon(Icons.local_dining),
              title: Text(S.of(context).recipe),
              onTap: () {
                if (ModalRoute.of(context).settings.name ==
                        HomeScreen.routeName ||
                    ModalRoute.of(context).settings.name == '/') {
                  Provider.of<AuthProvider>(context, listen: false)
                      .setAdmobStatus = true;
                  Navigator.of(context).pop();
                } else {
                  Provider.of<AuthProvider>(context, listen: false)
                      .setAdmobStatus = true;
                  Navigator.of(context).pushReplacementNamed(
                      HomeScreen.routeName,
                      arguments: HomeScreen(true));
                }
              }),
          ListTile(
            leading: Icon(Icons.rate_review),
            title: Text(S.of(context).rate),
            onTap: () {
              rateApp(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.share),
            title: Text(S.of(context).share),
            onTap: () {
              Share.share(S.of(context).shareLink);
            },
          ),
          Consumer<ThemeNotifier>(
            builder: (ctx, themeChanger, _) {
              return ListTile(
                leading: Icon(MdiIcons.themeLightDark),
                title: (themeChanger.getTheme() != darkTheme)
                    ? Text(S.of(context).swithToDark)
                    : Text(S.of(context).swithToLight),
                onTap: () {
                  onThemeChanged(context,
                      !(themeChanger.getTheme() == darkTheme), themeChanger);
                },
              );
            },
          ),
          _buildTilesDependonLogin(context),
        ],
      ),
    );
  }

  Widget _buildTilesDependonLogin(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (ctx, auth, child) {
        return auth.loginStatus
            ? Column(
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.favorite),
                    title: Text(S.of(context).favourite),
                    onTap: () {
                      if (ModalRoute.of(context).settings.name ==
                          FavoriteScreen.routeName) {
                        Provider.of<AuthProvider>(context, listen: false)
                            .setAdmobStatus = true;

                        Navigator.of(context).pop();
                      } else {
                        Provider.of<AuthProvider>(context, listen: false)
                            .setAdmobStatus = true;
                        Navigator.of(context).pushReplacementNamed(
                            FavoriteScreen.routeName,
                            arguments: FavoriteScreen(true));
                      }
                    },
                  ),
                  ListTile(
                    leading: Icon(MdiIcons.faceProfile),
                    title: Text(S.of(context).profile),
                    onTap: () {
                      Navigator.of(context)
                          .pushReplacementNamed(ProfileScreen.routeName);
                    },
                  ),
                  ListTile(
                    leading: Icon(MdiIcons.logout),
                    title: Text(S.of(context).logOut),
                    onTap: () {
                      _showMaterialDialog(context);
                    },
                  ),
                ],
              )
            : ListTile(
                leading: Icon(MdiIcons.login),
                title: Text(S.of(context).login),
                onTap: () {
                  Provider.of<AuthProvider>(context, listen: false)
                      .setScreenIsModel = true;
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => MainAuthScreen(),
                    fullscreenDialog: true,
                  ));
                  /* Navigator.of(context).popAndPushNamed(
                    MainAuthScreen.routeName,
                    arguments: true,
                  ); */
                },
              );
      },
    );
  }

  void rateApp(BuildContext context) {
    _rateMyApp.init().then(
      (_) {
        _rateMyApp.showRateDialog(
          context,
          title: 'Rate this app',
          message:
              'If you like this app, please take a little bit of your time to review it !\nIt really helps us and it shouldn\'t take you more than one minute.',
          rateButton: 'RATE',
          noButton: 'NO THANKS',
          laterButton: 'MAYBE LATER',
          // ignoreIOS: false,
          dialogStyle: DialogStyle(),
        );
      },
    );
  }

  void _showMaterialDialog(context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure?'),
          actions: <Widget>[
            FlatButton(
              textColor: Theme.of(context).accentColor,
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            Consumer<AuthProvider>(
              builder: (c1, authProvider, child) {
                return FlatButton(
                  textColor: Theme.of(context).accentColor,
                  child: child,
                  onPressed: () {
                    authProvider.logout().then(
                      (_) {
                        Navigator.of(context).pop();
                        Scaffold.of(context).openEndDrawer();
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            HomeScreen.routeName,
                            ((Route<dynamic> route) => false));
                        Provider.of<RecipesProvider>(context).removeAllSL();

                        Scaffold.of(context).showSnackBar(
                          SnackBar(
                            duration: Duration(milliseconds: 900),
                            content: Text('Logout successfully.'),
                          ),
                        );
                      },
                    );
                  },
                );
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void onThemeChanged(
      BuildContext context, bool value, ThemeNotifier themeNotifier) async {
    value
        ? themeNotifier.setTheme(darkTheme)
        : themeNotifier.setTheme(lightTheme);
    print('dark theme $value');
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkMode', value);
    Navigator.pop(context);
  }
}
