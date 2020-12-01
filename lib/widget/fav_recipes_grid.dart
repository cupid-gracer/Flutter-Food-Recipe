import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_flutter_provider/constant/static_string.dart';
import 'package:recipe_flutter_provider/provider/theme_provider.dart';
import 'package:recipe_flutter_provider/widget/google_admob.dart';
import 'package:path_provider/path_provider.dart';
import 'no_recipes.dart';
import 'package:recipe_flutter_provider/locale/app_localization.dart';

import '../provider/recipe.dart';
import '../api/api_call.dart';
import 'fav_recipe_card.dart';

class FavRecipesGrid extends StatefulWidget {
  final List<RecipeItem> recipes;
  final bool showFavorite;
  final bool netConnectivity;
  final String filePath;
  FavRecipesGrid(this.recipes, {this.showFavorite = true, this.netConnectivity = true, this.filePath});

  @override
  _FavRecipesGridState createState() => _FavRecipesGridState();
}

class _FavRecipesGridState extends State<FavRecipesGrid> {
  GlobalKey<ScaffoldState> scaffoldState = GlobalKey();
  String filePath = "";
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() async{
    filePath = (await getApplicationDocumentsDirectory()).path + "/img/";
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.recipes.length > 0
        ? GridView.builder(
            padding: EdgeInsets.all(10.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            itemCount: widget.recipes.length,
            itemBuilder: (BuildContext ctx, int index) {
              return ChangeNotifierProvider.value(
                value: widget.recipes[index],
                child: RecipeCard(
                  recipe: widget.recipes[index],
                  index: index,
                  showFavorite: widget.showFavorite,
                  netState: widget.netConnectivity,
                  filePath:widget.filePath,
                ),
              );
            },
          )
        : NoRecipes(title: S.of(context).noFavourite,);
  }
}
