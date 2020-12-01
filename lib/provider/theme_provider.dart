import 'package:flutter/material.dart';

import '../constant/app_color.dart';
import '../constant/app_fonts.dart';

final ThemeData lightTheme = ThemeData(
  fontFamily: AppFonts.montserrat,
  brightness: Brightness.light,
  primaryColor: AppColor.lightPrimaryColor,
  accentColor: AppColor.lightAccentColor,
  buttonColor: AppColor.lightButtonColor,
  backgroundColor: Colors.white,
  textTheme: TextTheme(
    title: TextStyle(
      color: AppColor.lightTitleColor,
    ),
    subtitle: TextStyle(
      color: AppColor.lightSubtitleColor,
    ),
    body1: TextStyle(
      shadows: [
        Shadow(
          color: AppColor.lightShadowColor,
        ),
      ],
    ),
  ),
);

final ThemeData darkTheme = ThemeData(
  fontFamily: AppFonts.montserrat,
  brightness: Brightness.dark,
  primaryColor: AppColor.darkPrimaryColor,
  accentColor: AppColor.darkAccentColor,
  buttonColor: AppColor.darkButtonColor,
  textTheme: TextTheme(
    title: TextStyle(
      color: AppColor.darkTitleColor,
    ),
    subtitle: TextStyle(
      color: AppColor.darkSubtitleColor,
    ),
    body1: TextStyle(
      shadows: [
        Shadow(
          color: AppColor.darkShadowColor,
        ),
      ],
    ),
  ),
);

class ThemeNotifier with ChangeNotifier {
  ThemeData _themeData;

  ThemeNotifier(this._themeData);

  getTheme() => _themeData;

  setTheme(ThemeData themeData) async {
    _themeData = themeData;
    notifyListeners();
  }
}

class ThemeChanger with ChangeNotifier {
  ThemeData _themeData;

  ThemeChanger(this._themeData);

  getTheme() => _themeData;

  setTheme(ThemeData themeData) async {
    _themeData = themeData;
    notifyListeners();
  }
}

enum MyThemeKeys { LIGHT, DARK }

class MyTheme {
  static ThemeData getThemeFromKey(MyThemeKeys themeKey) {
    switch (themeKey) {
      case MyThemeKeys.LIGHT:
        return lightTheme;
      case MyThemeKeys.DARK:
        return darkTheme;
      default:
        return lightTheme;
    }
  }
}
