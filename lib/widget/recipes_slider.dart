import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_flutter_provider/provider/theme_provider.dart';
import 'package:recipe_flutter_provider/widget/google_admob.dart';
import 'no_recipes.dart';

import '../provider/recipe.dart';
import 'recipe_slider_card.dart';

class RecipesSlider extends StatefulWidget {
  final List<RecipeItem> recipes;
  final bool showFavorite;
  RecipesSlider(this.recipes, {this.showFavorite = true});

  @override
  _RecipesSliderState createState() => _RecipesSliderState();
}

class _RecipesSliderState extends State<RecipesSlider> {
  GlobalKey<ScaffoldState> scaffoldState = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.recipes.length > 0
        ? ListView.builder(
            padding: EdgeInsets.all(10.0),
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: widget.recipes.length,
            itemBuilder: (BuildContext ctx, int index) {
              return ChangeNotifierProvider.value(
                value: widget.recipes[index],
                child: RecipeSliderCard(
                  recipe: widget.recipes[index],
                  index: index,
                  showFavorite: widget.showFavorite,
                ),
              );
            },
          )
        : NoRecipes();
  }
}
