import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_flutter_provider/api/api_call.dart';
import 'package:recipe_flutter_provider/constant/app_images.dart';
import 'package:recipe_flutter_provider/constant/decoration.dart';
import 'package:recipe_flutter_provider/constant/material_color.dart';
import 'package:recipe_flutter_provider/constant/static_string.dart';
import 'package:recipe_flutter_provider/provider/auth.dart';
import 'package:recipe_flutter_provider/provider/theme_provider.dart';
import 'package:recipe_flutter_provider/widget/google_admob.dart';
import 'package:recipe_flutter_provider/locale/app_localization.dart';

import 'no_recipes.dart';
import '../constant/app_fonts.dart';
import '../provider/recipe.dart';
import '../provider/category.dart';
import './custom_image.dart';
import '../screens/search_screen.dart';
import '../screens/categories_screen.dart';
import '../screens/recipe_detail_screen.dart';
import 'recipe_card.dart';
import './category_card.dart';
import '../widget/recipes_slider.dart';
import '../widget/category_list.dart';
import '../screens/recipes_screen.dart';

class MainHome extends StatefulWidget {
  final List<RecipeItem> recipes;
  final bool showFavorite;

  MainHome(this.recipes, {this.showFavorite = true});

  @override
  _MainHomeState createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {
  GlobalKey<ScaffoldState> scaffoldState = GlobalKey();

  bool _isInit = true;
  bool _isLoading = false;
  RecipeItem srtRecipe;
  bool _netStat = false;

  @override
  void initState() {
    super.initState();
    // GoogleAddmob.loadAd();
  }

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      _isLoading = true;
        // await ApiCall.checkCon();
        // setState(() {
          
        // });
        print("_netStat   $_netStat");
      try {
        // await Provider.of<CategoryProvider>(context)
        //     .fetchAndSetCategories(context: context);
        // await Provider.of<RecipesProvider>(context, listen: false)
        //     .fetchAndSetRecipes(context: context);
        // await Provider.of<RecipesProvider>(context, listen: false)
        //     .fetchAndSetFavRecipes(context: context);
        // await Provider.of<RecipesProvider>(context, listen: false)
        //     .readAndSetFavs(context: context);
        if (mounted)
          setState(() {
            _isLoading = false;
          });
      } catch (error) {
        if (mounted)
          setState(() {
            _isLoading = false;
          });
      }
    }

    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<CategoryItem> categories =
        Provider.of<CategoryProvider>(context, listen: false).categories;
    List<RecipeItem> recipes =
        Provider.of<RecipesProvider>(context, listen: false).recipes;
    srtRecipe = Provider.of<RecipesProvider>(context, listen: false).todayRecipe;
    if(srtRecipe == null){
      srtRecipe = recipes.first;
    }
    return Container(
            child: Expanded(child: _buildStack(context)),
          );
  }

  Widget _buildStack(BuildContext context) =>  Stack(
        children: [
          Image(
            image: AssetImage(AppImages.loginBg),
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
          ),
          Container(
            // decoration: BoxDecoration(
            //     // color: Colors.black45,
            //     ),
            padding: EdgeInsets.only(top: 30.0, left: 10, right: 10),
            child: Column(
              children: [
                Expanded(
                    flex: 6,
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            S.of(context).appTitle,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: white),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        _buildSearchBar(context),
                        SizedBox(height: 40),
                        Expanded(
                          child: _buildSpecialRecipeToday(context, srtRecipe),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    )),
                Expanded(
                    flex: 7,
                    child: SingleChildScrollView(
                        child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            S.of(context).categories,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: white),
                          ),
                        ),
                        Container(
                          height: 200,
                          child: _buildCategories(context),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              S.of(context).suggest,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: white),
                            ),
                            InkWell(
                              onTap: () {
                                // final tabIndex = DefaultTabController.of(context).index;
                                // showSearch(
                                //   context: context,
                                //   delegate: SearchScreen(SearchType.values[tabIndex]),
                                // );
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => RecipesScreen(true),
                                  fullscreenDialog: true,
                                ));
                              },
                              child: Text(
                                S.of(context).seeAll,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: white),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          height: 200,
                          child: _buildSuggest(context),
                        ),
                      ],
                    ))),
              ],
            ),
          ),
        ],
      );
      // : Expanded(child: NoRecipes(title: "No Internet"));

  Widget _buildSearchBar(BuildContext context) => InkWell(
        onTap: () {
          final tabIndex = DefaultTabController.of(context).index;
          showSearch(
            context: context,
            delegate: SearchScreen(SearchType.Recipe),
          );
        },
        child: Container(
          padding: EdgeInsets.only(left: 20, top: 10, right: 20, bottom: 10),
          decoration: cardDecoration(context: context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                Icons.search,
                color: Theme.of(context).accentColor,
              ),
              Padding(
                padding: EdgeInsets.only(left: 1),
                child: Text(
                  S.of(context).findRecipe,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.title.color,
                    fontFamily: AppFonts.montserrat,
                  ),
                ),
              ),
              Align(
                alignment: Alignment(1, -0.5),
                child: Icon(
                  Icons.more_horiz,
                  color: Theme.of(context).accentColor,
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildSpecialRecipeToday(BuildContext context, RecipeItem recipe) =>
      InkWell(
        onTap: () async {
          await Navigator.of(context).pushNamed(
            RecipeDetailScreen.routeName,
            arguments: recipe,
          );
        },
        child: Container(
          decoration: srtDecoration(context: context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  children: [
                    // SizedBox(
                    //   height: MediaQuery.of(context).size.height /50,
                    // ),
                    Expanded(flex: 3, child: Container()),
                    Expanded(
                      flex: 4,
                      child: Text(
                        S.of(context).specialRecipeToday,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.title.color,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                        child: Text(
                      recipe.recipeName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.title.color,
                      ),
                    )),
                  
                  ],
                ),
              ),
              Expanded(
                child: Container(
                    child: Padding(
                  padding: EdgeInsets.all(10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: CustomImage(
                      imgURL: recipe.recipesImageUrl.first,
                      width: (MediaQuery.of(context).size.width - 30) / 2,
                      height: (MediaQuery.of(context).size.height - 30) / 5,
                    ),
                  ),
                )),
              )
            ],
          ),
        ),
      );

  Widget _buildCategories(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : Consumer<CategoryProvider>(builder: (ctx, categoryProvider, _) {
          return CategoryList(categoryProvider.categories);
        });
  }

  Widget _buildSuggest(BuildContext context) {
    List<RecipeItem> recipes =
        Provider.of<RecipesProvider>(context, listen: false).recipes;

    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : Consumer<RecipesProvider>(builder: (ctx, recipeProvider, _) {
            return RecipesSlider(
              recipeProvider.recipes,
            );
          });
  }
}
