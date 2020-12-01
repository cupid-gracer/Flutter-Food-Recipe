import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:recipe_flutter_provider/provider/auth.dart';
import 'package:recipe_flutter_provider/provider/theme_provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:recipe_flutter_provider/locale/app_localization.dart';
import 'package:share/share.dart';
import 'package:recipe_flutter_provider/locale/app_localization.dart';

import '../widget/custom_image.dart';
import '../constant/app_bar.dart';
import '../constant/app_fonts.dart';
import '../constant/app_images.dart';
import '../constant/static_string.dart';
import '../provider/recipe.dart';
import '../constant/decoration.dart';
import '../widget/safearea_with_banner.dart';
import '../constant/custom_dialog.dart';
import '../constant/subscription_dialog.dart';
import 'main_auth_screen.dart';
import '../constant/custom_buttons.dart';
import '../widget/youtube_player.dart';

class SubscriptionScreen extends StatefulWidget {
  static const routeName = '/subscription-screen';
  // final String youtube_link;
  // RecipeDetailScreen({this.youtube_link});

  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var top = 0.0;
  bool _isLoading = false;
  bool _isSubscribe = false;

  bool get isShrink {
    return top < (84);
  }

  AnimationController animationController;
  Animation<double> animation;
  String videoId;
  bool f;
  // YoutubePlayerController _controller;
  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    animation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    );

    animationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isSubscribe = Provider.of<AuthProvider>(context).subscribeStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: NestedScrollView(
            headerSliverBuilder: (ctx, scrolled) {
              return <Widget>[
                SliverAppBar(
                  iconTheme: IconThemeData(
                      color: scrolled
                          ? Theme.of(context).textTheme.title.color
                          : Colors.white),
                  expandedHeight: 200,
                  floating: true,
                  pinned: true,
                  flexibleSpace: _buildFlexibleTitleBar(),
                )
              ];
            },
            body: AnimatedBuilder(
              animation: animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: animation,
                  child: Column(
                    children: <Widget>[
                      Expanded(
                          child: SingleChildScrollView(child: _buildBody())),
                    ],
                  ),
                );
              },
            )),
      ),
    );
  }

  Widget _buildFlexibleTitleBar() {
    return LayoutBuilder(
      builder: (ctx, constraint) {
        top = constraint.maxHeight;
        return FlexibleSpaceBar(
          centerTitle: true,
          title: _buildTitle(title: S.of(context).subscription),
          background: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              // !isShrink
              //     ? Hero(
              //         tag: recipe.recipeId,
              //         child: _buildImage(recipe.recipesImageUrl.first),
              //       ):
              Image.asset(
                AppImages.subscription,
                fit: BoxFit.cover,
              ),
              // _buildImage(recipe.recipesImageUrl.first),
              Positioned.fill(
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(
                    sigmaX: 0.1,
                    sigmaY: 0.1,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildTitle({@required String title}) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 300),
      opacity: 1.0,
      child: Padding(
        padding: EdgeInsets.only(left: 60.0, right: isShrink ? 95 : 60),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16.0,
            fontFamily: AppFonts.montserrat,
            fontWeight: FontWeight.bold,
            color: isShrink
                ? Theme.of(context).textTheme.title.color
                : Colors.white,
          ),
          maxLines: isShrink ? 1 : 3,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _buildPurchase(), // Intro...
        _buildManSubscription(), //Ingridients...
      ],
    );
  }

  Widget _buildPurchase() {
    return Container(
      decoration: cardDecoration(context: context),
      padding: EdgeInsets.symmetric(vertical: 10),
      margin: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          _buildSectionTitle("Purchase Add Free Premium"), //Intro
          _buildDivider(),
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: CustomText(
              align: TextAlign.start,
              txtTitle: "* Enjoy Ad Free version of app.",
              txtColor:
                  Theme.of(context).textTheme.title.color, // Colors.black87,
              txtFontName: AppFonts.montserrat,
              txtFontStyle: FontWeight.w500,
              txtSize: 15,
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: CustomText(
              align: TextAlign.start,
              txtTitle: "* Unlimited access to all features.",
              txtColor:
                  Theme.of(context).textTheme.title.color, // Colors.black87,
              txtFontName: AppFonts.montserrat,
              txtFontStyle: FontWeight.w500,
              txtSize: 15,
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: CustomText(
              align: TextAlign.start,
              txtTitle: "* Experience the app with lightning speed.",
              txtColor:
                  Theme.of(context).textTheme.title.color, // Colors.black87,
              txtFontName: AppFonts.montserrat,
              txtFontStyle: FontWeight.w500,
              txtSize: 15,
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.70,
            padding: EdgeInsets.only(right: 15.0, left: 15, bottom: 20),
            child: CustomeButtons.rectangleButton(
                title: "See Subscription Offers",
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return SubscriptionDialog(
                          titleM:
                              "Monthly subscription (All free Recipes: World Cuisines)",
                          titleY:
                              "Yearly subscription (All free Recipes: World Cuisines)",
                          buttonText: 'SUBSCRIBE',
                          descriptionM:
                              "Enjoy the premium for 1 Month. It will be auto-renewed and charged every month.",
                          descriptionY:
                              "Enjoy the premium for 1 Year. It will be auto-renewed and charged every year.",
                          priceM: "42000",
                          priceY: "21000",
                          priceOffM: "",
                          priceOffY: "50",
                          currency: "IDR",
                          onTapM: () {
                            print("clicked");
                          },
                          onTapY: () {
                            print("clicked");
                          },
                        );
                      });
                },
                textColor: Colors.white,
                borderColor: Colors.transparent,
                buttonColor: Theme.of(context).buttonColor),
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: CustomText(
              align: TextAlign.start,
              txtTitle:
                  "Please note, the subscriptions will be automatically renewed and charged periodically. You can cancel subscription at any time on Google Play subscriptions page. Subscription cancellation goes into effect only after the current billing period has passed.",
              txtColor:
                  Theme.of(context).textTheme.title.color, // Colors.black87,
              txtFontName: AppFonts.montserrat,
              txtFontStyle: FontWeight.w500,
              txtSize: 12,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildManSubscription() {
    return Container(
      decoration: cardDecoration(context: context),
      padding: EdgeInsets.symmetric(vertical: 10),
      margin: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          _buildSectionTitle("Manage Subscriptions"), //Intro
          _buildDivider(),
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: CustomText(
              align: TextAlign.start,
              txtTitle:
                  "Aleady Subscribed? Check if there is a problem with your subscription. Go to the Google Play Subscriptions page to fix your payment method.",
              txtColor:
                  Theme.of(context).textTheme.title.color, // Colors.black87,
              txtFontName: AppFonts.montserrat,
              txtFontStyle: FontWeight.w500,
              txtSize: 15,
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.70,
            padding: EdgeInsets.only(right: 15.0, left: 15, bottom: 20),
            child: CustomeButtons.rectangleButton(
                title: "Mange Subscriptions",
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return SubscriptionDialog(
                          titleM:
                              "Monthly subscription (All free Recipes: World Cuisines)",
                          titleY:
                              "Yearly subscription (All free Recipes: World Cuisines)",
                          buttonText: 'SUBSCRIBE',
                          descriptionM:
                              "Enjoy the premium for 1 Month. It will be auto-renewed and charged every month.",
                          descriptionY:
                              "Enjoy the premium for 1 Year. It will be auto-renewed and charged every year.",
                          priceM: "42000",
                          priceY: "21000",
                          priceOffM: "",
                          priceOffY: "50",
                          currency: "IDR",
                          onTapM: () {
                            print("clicked");
                          },
                          onTapY: () {
                            print("clicked");
                          },
                        );
                      });
                },
                textColor: Colors.white,
                borderColor: Colors.transparent,
                buttonColor: Theme.of(context).buttonColor),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroButton({
    @required String title,
    @required IconData icon,
    Function onTap,
  }) {
    if (title == "") return Container();
    return InkWell(
      onTap: onTap,
      child: Column(
        children: <Widget>[
          Icon(
            icon,
            color: Theme.of(context).textTheme.subtitle.color,
          ),
          SizedBox(height: 5),
          CustomText(
            txtTitle: title,
            txtColor: Theme.of(context).textTheme.title.color,
            txtFontName: AppFonts.montserrat,
            txtFontStyle: FontWeight.w500,
            txtSize: 15,
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      height: 50,
      padding: EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.centerLeft,
      child: CustomText(
        align: TextAlign.start,
        txtTitle: title,
        txtColor: Theme.of(context).textTheme.title.color, // Colors.black,
        txtFontName: AppFonts.montserrat,
        txtFontStyle: FontWeight.w500,
        txtSize: 22,
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Theme.of(context).textTheme.subtitle.color.withOpacity(0.8),
    );
  }
}
