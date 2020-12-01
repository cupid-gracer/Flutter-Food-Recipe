import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/lang_all.dart';

class S {
  
  static Future<S> load(Locale locale) {
    final String name = locale.countryCode.isEmpty ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      return S();
    });
  }

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }
  
  
  String get aaa { return Intl.message( 'aaa', name: 'aaa', desc: '', );}

  String get firstName{ return Intl.message( "First Name", name: "firstName", desc: '', );}
  String get lastName{ return Intl.message( "Last Name", name: "lastName", desc: '', );}
  String get mobile{ return Intl.message( "Mobile", name: "mobile", desc: '', );}
  String get email{ return Intl.message( "Email", name: "email", desc: '', );}
  String get settings{ return Intl.message( "Settings", name: "settings", desc: '', );}
  String get loginTitle{ return Intl.message( 'Log In', name: "loginTitle", desc: '', );}
  String get goodToSeeAgain{ return Intl.message( 'Good to see you again', name: "goodToSeeAgain", desc: '', );}
  String get forgotPassword{ return Intl.message( 'Forgot your password?', name: "forgotPassword", desc: '', );}
  String get dontHaveAccount{ return Intl.message( 'Don’t have an account?', name: "dontHaveAccount", desc: '', );}
  String get alreadyHaveAccount{ return Intl.message( 'Already have an account?', name: "alreadyHaveAccount"   , desc: '', );}
  String get login{ return Intl.message( 'Login', name: "login", desc: '', );}
  String get signUP{ return Intl.message( 'Sign up', name: "signUP", desc: '', );}
  String get logOut{ return Intl.message( 'Logout', name: "logOut", desc: '', );}
  String get createAccount{ return Intl.message( 'Create account', name: "createAccount", desc: '', );}
  String get youremail{ return Intl.message( 'Your Email', name: "youremail", desc: '', );}
  String get password{ return Intl.message( 'Passoword', name: "password", desc: '', );}
  String get confirmPassowrd{ return Intl.message( 'Confirm Password', name: "confirmPassowrd", desc: '', );}
  String get niceToMetYou{ return Intl.message( 'Nice to meet you', name: "niceToMetYou", desc: '', );}
  String get forgotPasswordHead{ return Intl.message( 'Forgot password?', name: "forgotPasswordHead", desc: '', );}
  String get submit{ return Intl.message( 'Submit', name: "submit", desc: '', );}
  String get yourName{ return Intl.message( 'Your Name', name: "yourName", desc: '', );}
  String get name{ return Intl.message( "Name", name: "name", desc: '', );}
  String get search{ return Intl.message( 'Search', name: "search", desc: '', );}
  String get socialLogin{ return Intl.message( 'Social Login', name: "socialLogin", desc: '', );}
  String get forgotPassowrdSubHead{ return Intl.message( 'Enter your email below to receive your password reset instruction', name: "forgotPassowrdSubHead", desc: '', );}


  String get appTitle { return Intl.message( 'Food Recipes', name: "appTitle", desc: '', );}
  String get recentRecipes { return Intl.message( "Recent Recipes", name: "recentRecipes", desc: '', );}
  String get noRecipe { return Intl.message( "No Recipe Found!", name: "noRecipe", desc: '', );}
  String get categories { return Intl.message( "Categories", name: "categories", desc: '', );}
  String get noCategory { return Intl.message( "No Category Found!", name: "noCategory", desc: '', );}
  String get favourite { return Intl.message( "Favorite", name: "favourite", desc: '', );}
  String get noFavourite { return Intl.message( "No Favorite Recipe Found!", name: "noFavourite", desc: '', );}
  String get appReview { return Intl.message( "App Review", name: "appReview", desc: '', );}
  String get appID { return Intl.message( "App ID", name: "appID", desc: '', );}
  String get viewStore { return Intl.message( "View Store Page", name: "viewStore", desc: '', );}
  String get requestReview { return Intl.message( "Request Review", name: "requestReview", desc: '', );}
  String get writeReview { return Intl.message( "Write a New Review", name: "writeReview", desc: '', );}
  String get fbBtnTitle { return Intl.message( "Sign in with Facebook", name: "fbBtnTitle", desc: '', );}
  String get googleBtnTitle { return Intl.message( "Sign in with Google", name: "googleBtnTitle", desc: '', );}
  String get recipe { return Intl.message( "Recipes", name: "recipe", desc: '', );}
  String get rate { return Intl.message( "Rate", name: "rate", desc: '', );}
  String get more { return Intl.message( "More", name: "more", desc: '', );}
  String get share { return Intl.message( "Share", name: "share", desc: '', );}
  String get about { return Intl.message( "About", name: "about", desc: '', );}
  String get profile { return Intl.message( "Profile", name: "profile", desc: '', );}
  String get swithToLight { return Intl.message( "Light Theme", name: "swithToLight", desc: '', );}
  String get swithToDark { return Intl.message( "Dark Theme", name: "swithToDark", desc: '', );}
  String get profileInfo { return Intl.message( "Profile Information", name: "profileInfo", desc: '', );}
  String get deleteAccount { return Intl.message( "Delete Account", name: "deleteAccount", desc: '', );}

  String get shareLink { return Intl.message( "I would like to share the Your Recipe App with you. Here you can dowonload this application from play store. https://appstonelab.com", name: "shareLink", desc: '', );}
  String get intro { return Intl.message( "Intro", name: "intro", desc: '', );}
  String get introDesc { return Intl.message( "This is a type of chicken curry in a thick gravy with a nice spicy flavor, but is not too hot. You may adjust the heat by adding more serrano peppers. Serve over rice, or with chapatti or roti.", name: "introDesc", desc: '', );}
  String get ingridient { return Intl.message( "Ingridient", name: "ingridient", desc: '', );}
  String get insructions { return Intl.message( "Instructions", name: "insructions", desc: '', );}
  String get noInternet { return Intl.message( "No Internet", name: "noInternet", desc: '', );}
  String get noInternetMessage { return Intl.message( "Please check your internet connection", name: "noInternetMessage", desc: '', );}
  String get findRecipe { return Intl.message( "Find a food recipes", name: "findRecipe", desc: '', );}
  String get suggest { return Intl.message( "Suggest", name: "suggest", desc: '', );}
  String get seeAll { return Intl.message( "See All", name: "seeAll", desc: '', );}
  String get home { return Intl.message( "Home", name: "home", desc: '', );}
  String get shoppingList { return Intl.message( "Shopping List", name: "shoppingList", desc: '', );}
  String get noShoppingList { return Intl.message( "No Shopping List Found!", name: "noShoppingList", desc: '', );}
  String get specialRecipeToday { return Intl.message( "SCPECIAL RECIPE TODAY", name: "specialRecipeToday", desc: '', );}
  String get subscription { return Intl.message( "Subscription", name: "subscription", desc: '', );}
  String get price { return Intl.message( "Price", name: "price", desc: '', );}
  String get validEmail { return Intl.message( "Please enter a valid email", name: "validEmail", desc: '', );}
  String get validPassword { return Intl.message( "Please enter atleast 8 characters", name: "validPassword", desc: '', );}
  String get confirmPassword { return Intl.message( "Passwords do not match", name: "confirmPassword", desc: '', );}
  String get nameRequire { return Intl.message( "Please enter your name", name: "nameRequire", desc: '', );}
  String get messageRequire { return Intl.message( "Please enter some message", name: "messageRequire", desc: '', );}

}

class AppLocalizationDelegate extends LocalizationsDelegate<S>{
  final Locale overriddenLocale;

  const AppLocalizationDelegate(this.overriddenLocale);

  @override
  bool isSupported(Locale locale) => ['en', 'es'].contains(locale.languageCode);

  @override
  Future<S> load(Locale locale) => S.load(locale);

  @override
  bool shouldReload(LocalizationsDelegate<S> old) => false; 
}