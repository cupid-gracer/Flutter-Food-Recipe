import 'dart:convert';
import 'dart:developer';
import 'dart:ui' as ui;
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:recipe_flutter_provider/provider/auth.dart';
import 'package:recipe_flutter_provider/provider/theme_provider.dart';
import 'package:recipe_flutter_provider/locale/app_localization.dart';
import '../widget/fav_custom_image.dart';
import 'package:share/share.dart';

import '../constant/app_bar.dart';
import '../constant/app_fonts.dart';
import '../constant/app_images.dart';
import '../constant/static_string.dart';
import '../provider/recipe.dart';
import '../constant/decoration.dart';
import '../widget/safearea_with_banner.dart';
import '../api/api_call.dart';
import 'main_auth_screen.dart';

class FavRecipeDetailScreen extends StatefulWidget {
  static const routeName = '/fav-recipe-details-screen';

  _FavRecipeDetailScreenState createState() => _FavRecipeDetailScreenState();
}

class _FavRecipeDetailScreenState extends State<FavRecipeDetailScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var top = 0.0;
  bool _isInit = true;
  bool _isImgLoading = false;
  bool _isLoading = false;
  String filePath = "";

  bool get isShrink {
    return top < (84);
  }

  AnimationController animationController;
  Animation<double> animation;

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
    print("there");
    animationController.forward();
  }

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      setState(() {
        _isImgLoading = true;
      });
    }
    filePath = await ApiCall.getFilePath();
    setState(() {
      _isImgLoading = false;
    });
    _isInit = false;
    super.didChangeDependencies();
  }

  String getFileName(String url) {
    List<String> strs = url.split("/");
    return strs.last;
  }

  @override
  Widget build(BuildContext context) {
    final RecipeItem recipe = ModalRoute.of(context).settings.arguments;
    ThemeNotifier themeNotifier = Provider.of<ThemeNotifier>(context);
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
                          child:
                              SingleChildScrollView(child: _buildBody(recipe))),
                      AnimatedContainer(
                        duration: Duration(milliseconds: 250),
                        height:
                            Provider.of<AuthProvider>(context).getAdmobStatus
                                ? 50.0
                                : 0.0,
                        width: double.infinity,
                        color: themeNotifier.getTheme() == lightTheme
                            ? Colors.white
                            : Colors.black,
                      )
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
                
                print("here : $oldSatatus");
                setState(() {
                  _isLoading = false;
                });
                if (isMarkedAsFav) {
                  if (!oldSatatus)
                    recipeProvider.addFav(recipe);
                  else
                    recipeProvider.removeFav(recipe);
                }
                final String content = isMarkedAsFav
                    ? oldSatatus
                        ? 'Successfully removed from Favorite!!!'
                        : 'Successfully marked as Favorite!!'
                    : 'Please retry when enable Internet.';
                _scaffoldKey.currentState.showSnackBar(
                  SnackBar(
                    duration: Duration(milliseconds: 900),
                    content: Text(content),
                    action:  null,
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
              _isImgLoading
                  ? Center(child: CircularProgressIndicator())
                  : !isShrink
                      ? Hero(
                          tag: recipe.recipeId,
                          child: _buildImage(recipe.recipesImageUrl.last),
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
    return CustomImage(
      imgURL: filePath + getFileName(imageUrl),
      height: 200,
      width: 200,
    );
    // return Image.file(
    //   // image: NetworkImage(imageUrl),
    //   File(filePath + getFileName(imageUrl)),
    //   // placeholder: AssetImage(AppImages.transparent),
    //   fit: BoxFit.cover,
    // );
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

  Widget _buildBody(RecipeItem recipe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _buildRecipeImageGrid(recipe.recipesImageUrl),
        _buildIntro(recipe), // Intro...
        _buildIngredient(recipe), //Ingridients...
        _buildInstruction(recipe),
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

  Widget _buildRecipeImageGrid(List<String> urls) {
    final imageWidth = (MediaQuery.of(context).size.width - 40) / 3;
    PageController controller;
    print("here");
    urls.forEach((element) {
      print("_buildRecipeImageGrid: $element");
    });
    return Container(
      height: imageWidth + 10,
      decoration: cardDecoration(context: context),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      margin: EdgeInsets.all(10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: urls.length,
        itemBuilder: (BuildContext context, int listIndex) {
          String url = urls[listIndex];
          return GestureDetector(
            onTap: () {
              controller = PageController(
                  viewportFraction: 1, keepPage: true, initialPage: listIndex);
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
                                imageProvider: FileImage(File(
                                    filePath + getFileName(urls[pageIndex]))),
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
                  imgURL: filePath + getFileName(urls[listIndex]),
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
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: CustomText(
              align: TextAlign.start,
              txtTitle: recipe.summary,
              txtColor:
                  Theme.of(context).textTheme.title.color, // Colors.black87,
              txtFontName: AppFonts.montserrat,
              txtFontStyle: FontWeight.w500,
              txtSize: 15,
            ),
          ),
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
                _buildIntroButton(
                  icon: Icons.people,
                  title: recipe.servingPerson,
                ),
                _buildIntroButton(
                  icon: MdiIcons.fire,
                  title: '${recipe.calories} kcal',
                ),
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
    print('ingredient ${recipe.ingredients}');
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: cardDecoration(context: context),
      child: Column(
        children: <Widget>[
          _buildSectionTitle(S.of(context).ingridient),
          _buildDivider(),
          ListView.builder(
            padding: EdgeInsets.all(0),
            physics: ClampingScrollPhysics(),
            shrinkWrap: true,
            itemCount: recipe.ingredients.length,
            itemBuilder: (BuildContext context, int index) {
              return CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: Colors.green,
                value: recipe.ingredients[index].isChecked,
                title: Text(
                    '${recipe.ingredients[index].quantity} ${recipe.ingredients[index].weight} ${recipe.ingredients[index].ingredientName}'),
                onChanged: (value) {
                  setState(() {
                    recipe.ingredients[index].isChecked = value;
                  });
                },
              );
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
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: _buildDirectionTile(recipe.direction[index].description),
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
}
