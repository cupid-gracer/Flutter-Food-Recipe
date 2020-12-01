import 'dart:ui' as ui;
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:recipe_flutter_provider/provider/auth.dart';
import 'package:recipe_flutter_provider/provider/theme_provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:recipe_flutter_provider/widget/google_admob.dart';
import 'package:admob_flutter/admob_flutter.dart';
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
import '../screens/main_auth_screen.dart';
import '../widget/youtube_player.dart';

class RecipeDetailScreen extends StatefulWidget {
  static const routeName = '/recipe-details-screen';
  // RecipeDetailScreen({Key key}) : super(key: key);

  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var top = 0.0;
  bool _isLoading = false;
  bool _isSubscribe = false;
  bool _isLogin = false;
  bool get isShrink {
    return top < (84);
  }

  AnimationController animationController;
  Animation<double> animation;
  String videoId;
  String youtube_link;
  bool f;
  String comment;
  YoutubePlayerController _controller;
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
    // print("youtubelink: ${widget.recipe.youtube}");
    // youtube_link = widget.recipe.youtube;

    // print("widget.youtube_link: ${youtube_link}");
    // if (youtube_link != null && youtube_link != "") {
    //   videoId = YoutubePlayer.convertUrlToId(youtube_link);
    // } else {
    //   videoId = "_WoCV4c6XOE";
    // }

    // _controller = YoutubePlayerController(
    //   initialVideoId: videoId,
    //   flags: YoutubePlayerFlags(
    //     autoPlay: true,
    //     mute: false,
    //   ),
    // );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isSubscribe = Provider.of<AuthProvider>(context).subscribeStatus;
    _isLogin = Provider.of<AuthProvider>(context).loginStatus;
  }

  @override
  Widget build(BuildContext context) {
    final RecipeItem recipe = ModalRoute.of(context).settings.arguments;
    List<RecipeItem> recipe_others =
        Provider.of<RecipesProvider>(context).getMultiRecipes(recipe);

    youtube_link = recipe.youtube;

    print("widget.youtube_link: ${youtube_link}");
    if (youtube_link != null && youtube_link != "") {
      videoId = YoutubePlayer.convertUrlToId(youtube_link);
    } else {
      videoId = "_WoCV4c6XOE";
    }
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );

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
                  actions: <Widget>[
                    _buildShareButton(recipe.shareUrl),
                    _buildFavButton(recipe),
                  ],
                  expandedHeight: 200,
                  floating: true,
                  pinned: true,
                  flexibleSpace: _buildFlexibleTitleBar(recipe),
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
                          child: SingleChildScrollView(
                              child: _buildBody(recipe, recipe_others))),

                      // AnimatedContainer(
                      //   duration: Duration(milliseconds: 250),
                      //   height:
                      //       Provider.of<AuthProvider>(context).getAdmobStatus
                      //           ? 50.0
                      //           : 0.0,
                      //   width: double.infinity,
                      //   color: themeNotifier.getTheme() == lightTheme
                      //       ? Colors.white
                      //       : Colors.black,
                      // )
                    ],
                  ),
                );
              },
            )),
      ),
    );
  }

  Widget _buildShareButton(String shareUrl) {
    return Padding(
      padding: EdgeInsets.only(right: 5, left: 5),
      child: FloatingActionButton(
        heroTag: null,
        mini: true,
        elevation: 0,
        backgroundColor: Colors.white,
        onPressed: () => Share.share(shareUrl),
        child: Icon(
          Icons.share,
          color: Theme.of(context).accentColor,
          size: 22.0,
        ),
      ),
    );
  }

  Widget _buildFavButton(RecipeItem recipe) {
    return Padding(
      padding: EdgeInsets.only(right: 10),
      child: Consumer<RecipesProvider>(
        builder: (ctx, recipeProvider, _) {
          return FloatingActionButton(
            heroTag: null,
            mini: true,
            elevation: 0.0,
            onPressed: () async {
              if (!_isLoading) {
                bool isMarkedAsFav = false;
                final bool oldSatatus = recipe.isBookmark;
                setState(() {
                  _isLoading = true;
                });
                isMarkedAsFav = await recipeProvider.toggleFavoriteStatus(
                  recipe: recipe,
                  context: context,
                );
                if (isMarkedAsFav) {
                  if (!oldSatatus)
                    recipeProvider.addFav(recipe);
                  else
                    recipeProvider.removeFav(recipe);
                }
                print("here : $oldSatatus");
                setState(() {
                  _isLoading = false;
                });
                final String content = isMarkedAsFav
                    ? oldSatatus
                        ? 'Successfully removed from Favorite!!!'
                        : 'Successfully marked as Favorite!!'
                    : 'Please login to mark this recipe as fav.';
                _scaffoldKey.currentState.showSnackBar(
                  SnackBar(
                    duration: Duration(milliseconds: 2000),
                    content: Text(content),
                    action: !isMarkedAsFav
                        ? SnackBarAction(
                            label: 'Login',
                            onPressed: () async {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => MainAuthScreen(),
                                fullscreenDialog: true,
                              ));
                            },
                          )
                        : null,
                  ),
                );
              }
            },
            child: _isLoading
                ? CircularProgressIndicator()
                : Icon(
                    recipe.isBookmark ? Icons.favorite : Icons.favorite_border,
                    color: Theme.of(context).accentColor,
                    size: 22,
                  ),
            backgroundColor: Colors.white,
          );
        },
      ),
    );
  }

  Widget _buildFlexibleTitleBar(RecipeItem recipe) {
    return LayoutBuilder(
      builder: (ctx, constraint) {
        top = constraint.maxHeight;
        return FlexibleSpaceBar(
          centerTitle: true,
          title: _buildTitle(title: recipe.recipeName),
          background: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              !isShrink
                  ? Hero(
                      tag: recipe.recipeId,
                      child: _buildImage(recipe.recipesImageUrl.first),
                    )
                  : _buildImage(recipe.recipesImageUrl.first),
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

  Widget _buildImage(String imageUrl) {
    return FadeInImage(
      image: NetworkImage(imageUrl),
      placeholder: AssetImage(AppImages.transparent),
      fit: BoxFit.cover,
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

  Widget _buildBody(RecipeItem recipe, List<RecipeItem> recipe_others) {
    int len = recipe_others.length;
    return len == 2
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _buildRecipeImageGrid(recipe.youtube, recipe.recipesImageUrl),
              _buildIntro(recipe), // Intro...
              _buildMrecBanner(),
              _buildIngredient(recipe), //Ingridients...
              _buildInstruction(recipe),
              _isLogin ? _buildRatingComment(recipe) : Container(),
              _buildIntro(recipe_others[0]),
              _buildIngredient(recipe_others[0]), //Ingridients...
              _buildInstruction(recipe_others[0]),
              _buildIntro(recipe_others[1]),
              _buildIngredient(recipe_others[1]), //Ingridients...
              _buildInstruction(recipe_others[1]),
            ],
          )
        : len == 1
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _buildRecipeImageGrid(recipe.youtube, recipe.recipesImageUrl),
                  _buildIntro(recipe), // Intro...
                  _buildMrecBanner(),
                  _buildIngredient(recipe), //Ingridients...
                  _buildInstruction(recipe),
                  _isLogin ? _buildRatingComment(recipe) : Container(),
                  _buildIntro(recipe_others[0]),
                  _buildIngredient(recipe_others[0]), //Ingridients...
                  _buildInstruction(recipe_others[0]),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _buildRecipeImageGrid(recipe.youtube, recipe.recipesImageUrl),
                  _buildIntro(recipe), // Intro...
                  _buildMrecBanner(),
                  _buildIngredient(recipe), //Ingridients...
                  _buildInstruction(recipe),
                  _isLogin ? _buildRatingComment(recipe) : Container(),
                ],
              );
    // return recipe.recipesImageUrl.length > 1
    //     ? Column(
    //         crossAxisAlignment: CrossAxisAlignment.center,
    //         children: <Widget>[
    //           _buildRecipeImageGrid(recipe.recipesImageUrl),
    //           _buildIntro(recipe), // Intro...
    //           _buildIngredient(recipe), //Ingridients...
    //           _buildInstruction(recipe),
    //         ],
    //       )
    //     : Container();
  }

  Widget _buildRecipeImageGrid(String youtube, List<String> urls) {
    final imageWidth = (MediaQuery.of(context).size.width - 40) / 3;
    print("youtube: $youtube");

    PageController controller;
    return Container(
      height: imageWidth + 10,
      decoration: cardDecoration(context: context),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      margin: EdgeInsets.all(10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: youtube != "" ? urls.length + 1 : urls.length,
        itemBuilder: (BuildContext context, int listIndex) {
          if (youtube != "" && listIndex == 0) {
            String youtubeID = YoutubePlayer.convertUrlToId(youtube);
            return InkWell(
                onTap: () async {
                  // _modalBottomSheetMenu(context);
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => new YoutubePlayerScreen(
                          youtubeLink: youtube,
                        ),
                      ));
                },
                child: Container(
                  height: imageWidth,
                  width: imageWidth,
                  child: Stack(fit: StackFit.expand, children: <Widget>[
                    CustomImage(
                      imgURL: "https://i1.ytimg.com/vi/$youtubeID/default.jpg",
                      height: imageWidth,
                      width: imageWidth,
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: Image.asset(
                        AppImages.youtube,
                        height: 30.0,
                        width: 30.0,
                      ),
                    )
                  ]),
                )
                // Center(child: Text("someText")),
                // Text("eee")

                );
          }
          String url = youtube != "" ? urls[listIndex - 1] : urls[listIndex];
          print("listIndex: $listIndex");
          return GestureDetector(
            onTap: () {
              controller = PageController(
                  viewportFraction: 1,
                  keepPage: true,
                  initialPage: youtube != "" ? listIndex - 1 : listIndex);
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: PageView.builder(
                        controller: controller,
                        itemCount: urls.length,
                        itemBuilder: (context, pageIndex) {
                          return Dialog(
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              child: PhotoView(
                                tightMode: true,
                                imageProvider: NetworkImage(urls[pageIndex]),
                                heroAttributes:
                                    PhotoViewHeroAttributes(tag: url),
                              ),
                            ),
                          );
                        }),
                  );
                },
              );
            },
            child: Hero(
              tag: url,
              child: Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(5.0)),
                margin: EdgeInsets.all(5),
                width: imageWidth,
                height: imageWidth,
                child: CustomImage(
                  imgURL: youtube != "" ? urls[listIndex - 1] : urls[listIndex],
                  height: imageWidth,
                  width: imageWidth,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIntro(RecipeItem recipe) {
    return Container(
      decoration: cardDecoration(context: context),
      padding: EdgeInsets.symmetric(vertical: 10),
      margin: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          _buildSectionTitle(S.of(context).intro), //Intro
          _buildDivider(),
          recipe.summary.length > 0
              ? Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: CustomText(
                    align: TextAlign.start,
                    txtTitle: recipe.summary,
                    txtColor: Theme.of(context)
                        .textTheme
                        .title
                        .color, // Colors.black87,
                    txtFontName: AppFonts.montserrat,
                    txtFontStyle: FontWeight.w500,
                    txtSize: 15,
                  ),
                )
              : Container(),
          _buildDivider(),
          Container(
            padding: EdgeInsets.only(top: 10),
            alignment: Alignment.center,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _buildIntroButton(
                  icon: Icons.timer,
                  title: recipe.recipesTime,
                ),
                double.parse(recipe.servingPerson) > 0
                    ? _buildIntroButton(
                        icon: Icons.people,
                        title: recipe.servingPerson,
                      )
                    : Container(),
                double.parse(recipe.calories) > 0
                    ? _buildIntroButton(
                        icon: MdiIcons.fire,
                        title: '${recipe.calories} kcal',
                      )
                    : Container(),
              ],
            ),
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

  Widget _buildIngredient(RecipeItem recipe) {
    // print('ingredient ${recipe.ingredients}');
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: cardDecoration(context: context),
      child: Column(
        children: <Widget>[
          _buildSectionTitle(S.of(context).ingridient),
          _buildDivider(),
          ListView.builder(
            padding: EdgeInsets.all(20),
            physics: ClampingScrollPhysics(),
            shrinkWrap: true,
            itemCount: recipe.ingredients.length,
            itemBuilder: (BuildContext context, int index) {
              String quantity = recipe.ingredients[index].quantity;
              String ingredient = "";
              ingredient =
                  '${recipe.ingredients[index].quantity}  ${recipe.ingredients[index].weight}  ${recipe.ingredients[index].ingredientName}';
              try {
                if (double.parse(quantity) is double) {
                  if (double.parse(quantity) > 0)
                    ingredient =
                        '${recipe.ingredients[index].quantity}  ${recipe.ingredients[index].weight}  ${recipe.ingredients[index].ingredientName}';
                  else
                    ingredient = '${recipe.ingredients[index].ingredientName}';
                } else if (quantity == "") {
                  ingredient = '${recipe.ingredients[index].ingredientName}';
                }
              } catch (ee) {
                if (quantity == "") {
                  ingredient = '${recipe.ingredients[index].ingredientName}';
                }
              }
              return InkWell(
                onTap: () {
                  if (_isSubscribe) {
                    setState(() {
                      recipe.ingredients[index].isChecked =
                          !recipe.ingredients[index].isChecked;
                      print("change: ${recipe.ingredients[index].isChecked}");
                    });
                    if (recipe.ingredients[index].isChecked) {
                      Provider.of<RecipesProvider>(context, listen: false)
                          .addSL(recipe);
                      _scaffoldKey.currentState.showSnackBar(
                        SnackBar(
                          duration: Duration(milliseconds: 1000),
                          content:
                              Text(ingredient + ' added to shopping list!'),
                        ),
                      );
                    } else {
                      Provider.of<RecipesProvider>(context, listen: false)
                          .removeSL(recipe);
                      _scaffoldKey.currentState.showSnackBar(
                        SnackBar(
                          duration: Duration(milliseconds: 1000),
                          content:
                              Text(ingredient + 'removed from shopping list!'),
                        ),
                      );
                    }
                  } else {
                    return _scaffoldKey.currentState.showSnackBar(
                      SnackBar(
                        duration: Duration(milliseconds: 2000),
                        content: Text("Please login to add shopping list."),
                        action: SnackBarAction(
                          label: 'Login',
                          onPressed: () async {
                            Navigator.of(context).pushNamed(
                                MainAuthScreen.routeName,
                                arguments: true);
                          },
                        ),
                      ),
                    );
                  }
                },
                child: Padding(
                    padding: EdgeInsets.only(bottom: 25),
                    child: Row(
                      children: [
                        recipe.ingredients[index].isChecked
                            ? Icon(Icons.check_circle,
                                color: Colors.green, size: 25)
                            : Icon(Icons.add_circle_sharp,
                                color: Colors.grey, size: 25),
                        Padding(
                          padding: EdgeInsets.only(left: 20, bottom: 10),
                        ),
                        Expanded(
                          child: Text(ingredient),
                        )
                      ],
                    )),
              );
              // return CheckboxListTile(
              //   controlAffinity: ListTileControlAffinity.leading,
              //   activeColor: Colors.green,
              //   value: recipe.ingredients[index].isChecked,
              //   title: Text(
              //       '${recipe.ingredients[index].quantity} ${recipe.ingredients[index].weight} ${recipe.ingredients[index].ingredientName}'),
              //   onChanged: (value) {
              //     setState(() {
              //       recipe.ingredients[index].isChecked = value;
              //     });
              //   },
              // );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInstruction(RecipeItem recipe) {
    return Container(
      decoration: cardDecoration(context: context),
      margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildSectionTitle(S.of(context).insructions),
          _buildDivider(),
          Container(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 15),
              physics: ClampingScrollPhysics(),
              shrinkWrap: true,
              itemCount: recipe.direction.length,
              itemBuilder: (BuildContext context, int index) {
                // return Padding(
                //   padding:
                //       const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                //   child: _buildDirectionTile(recipe.direction[index]),
                // );
                return CheckboxListTile(
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: Colors.green,
                  value: recipe.direction[index].isCheck,
                  title: Text(recipe.direction[index].description),
                  onChanged: (value) {
                    setState(() {
                      recipe.direction[index].isCheck =
                          !recipe.direction[index].isCheck;
                    });
                  },
                );
              },
            ),
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

  Widget _buildDirectionTile(String title) {
    return Stack(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 5.0),
          child: Image.asset(
            AppImages.checkmark,
            height: 15.0,
            width: 15.0,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 25),
          child: CustomText(
            align: TextAlign.start,
            txtTitle: title,
            txtColor: Theme.of(context).textTheme.title.color,
            txtFontName: AppFonts.montserrat,
            txtFontStyle: FontWeight.w500,
            txtSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Theme.of(context).textTheme.subtitle.color.withOpacity(0.8),
    );
  }

  Widget _buildRatingComment(RecipeItem recipe) {
    return Container(
        decoration: cardDecoration(context: context),
        margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          _buildSectionTitle("Comment"),
          _buildDivider(),
          SizedBox(height: 10),
          RatingBar.builder(
            initialRating: double.parse(recipe.rating),
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (context, _) => Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) async {
              bool f =
                  await Provider.of<RecipesProvider>(context, listen: false)
                      .rateRecipe(
                          context: context,
                          rating: rating.toString(),
                          recipeId: recipe.recipeId);
              if (f) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return CustomDialog(
                      title: "Success",
                      buttonText: 'Okay',
                      description: "Thanks! You rated this $rating stars.",
                      alertType: CustomDialogType.Success,
                    );
                  },
                );
              }
              print(rating);
            },
          ),
          Stack(
            children: [
              Padding(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    onChanged: (text) {
                      comment = text;
                    },
                    keyboardType: TextInputType.multiline,
                    maxLength: null,
                    maxLines: null,
                  )),
              Align(
                  alignment: Alignment.bottomRight,
                  // padding: EdgeInsets.only(right: 5, left: 5),
                  child: FloatingActionButton(
                    heroTag: null,
                    mini: true,
                    elevation: 10,
                    // backgroundColor: Colors.white,
                    onPressed: () async {
                      print("comment: $comment");
                      bool f = await Provider.of<RecipesProvider>(context,
                              listen: false)
                          .commentRecipe(
                              context: context,
                              recipeId: recipe.recipeId,
                              comment: comment);
                      if (f) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return CustomDialog(
                              title: "Success",
                              buttonText: 'Okay',
                              description:
                                  "Thanks! You Commented Successfully!",
                              alertType: CustomDialogType.Success,
                            );
                          },
                        );
                      }
                    },
                    child: Icon(
                      Icons.send,
                      // color: Theme.of(context).accentColor,
                      size: 22.0,
                    ),
                  ))
            ],
          ),
        ]));
  }

  Widget _buildMrecBanner() {
    return Provider.of<AuthProvider>(context).getAdmobStatus
        ? Padding(
            padding: EdgeInsets.all(10),
            child: AdmobBanner(
              adUnitId: Platform.isAndroid
                  ? StaticString.addMobAndroidBannerUnitId
                  : StaticString.addMobiOSBannerUnitId,
              adSize: AdmobBannerSize.MEDIUM_RECTANGLE,
              onBannerCreated: (AdmobBannerController controller) {
                // Dispose is called automatically for you when Flutter removes the banner from the widget tree.
                // Normally you don't need to worry about disposing this yourself, it's handled.
                // If you need direct access to dispose, this is your guy!
                // controller.dispose();
              },
            ))
        : Container();
  }

  void _modalBottomSheetMenu(BuildContext context) async {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          // return Text("ddd");
          return new Container(
            height: 500.0,
            color: Colors.transparent, //could change this to Color(0xFF737373),
            //so you don't have to change MaterialApp canvasColor
            child: YoutubePlayer(
              controller: _controller,
              liveUIColor: Colors.amber,
            ),
          );
        });
  }
}
