import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'package:recipe_flutter_provider/provider/theme_provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:shared_preferences/shared_preferences.dart';
import './locale/app_localization.dart';

import './screens/home_screen.dart';
import './screens/main_auth_screen.dart';
import './screens/login_screen.dart';
import './screens/recipe_detail_screen.dart';
import './screens/fav_recipe_detail_screen.dart';
import './screens/recipes_screen.dart';
import './screens/category_detail_screen.dart';
import './screens/favorite_screen.dart';
import './screens/profile_screen.dart';
import './screens/forgot_password_screen.dart';

import './provider/auth.dart';
import './provider/category.dart';
import './provider/recipe.dart';
import './provider/user.dart';

import './services/one_signal.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(
      debug: true // optional: set false to disable printing logs to console
      );
  
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize without device test ids.
  Admob.initialize();

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIOverlays(
      [SystemUiOverlay.bottom, SystemUiOverlay.top]).then((_) {
    SharedPreferences.getInstance().then((prefs) {
      var darkModeOn = prefs.getBool('darkMode') ?? true;
      runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(
              value: AuthProvider(),
            ),
            ChangeNotifierProvider.value(
              value: RecipesProvider(),
            ),
            ChangeNotifierProvider.value(
              value: CategoryProvider(),
            ),
            ChangeNotifierProvider.value(
              value: UserProvider(),
            ),
            ChangeNotifierProvider.value(
              value: ThemeNotifier(darkModeOn ? darkTheme : lightTheme),
            ),
          ],
          child: MyApp(),
        ),
      );
    });
  });

  OneSignalService.initOneSignal(); // One Signal call
}

class MyApp extends StatelessWidget {
  AppLocalizationDelegate _localeOverrideDelegate = 
  AppLocalizationDelegate(Locale('en','US'));


  @override
  Widget build(BuildContext context) {
    FirebaseAdMob.instance.initialize(
      appId:
          FirebaseAdMob.testAppId, // "ca-app-pub-3940256099942544~1458002511",
    );

    print('Theme notifier');
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      localizationsDelegates: [
        // ... app-specific localization delegate[s] here
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        _localeOverrideDelegate,
      ],
      supportedLocales: [
        const Locale('en', 'US'), // English, no country code
        const Locale('es', 'ES'), // Spanish, no country code
        // const Locale.fromSubtags(languageCode: 'zh'), // Chinese *See Advanced Locales below*
        // ... other locales the app supports
      ],
      
      debugShowCheckedModeBanner: true,
      theme: themeNotifier.getTheme(),
      home: MainAuthScreen(),
      routes: {
        MainAuthScreen.routeName: (ctx) => MainAuthScreen(),
        LoginScreen.routeName: (ctx) => LoginScreen(),
        HomeScreen.routeName: (ctx) => HomeScreen(false),
        RecipesScreen.routeName: (ctx) => RecipesScreen(false),
        RecipeDetailScreen.routeName: (ctx) => RecipeDetailScreen(),
        FavRecipeDetailScreen.routeName: (ctx) => FavRecipeDetailScreen(),
        CategoryDetailScreen.routeName: (ctx) => CategoryDetailScreen(),
        FavoriteScreen.routeName: (ctx) => FavoriteScreen(false),
        ProfileScreen.routeName: (ctx) => ProfileScreen(),
        ForgotPasswordScreen.routeName: (ctx) => ForgotPasswordScreen(),
      },
    );

    // Ads.initializeFirebaseAdMob();
  }
}
