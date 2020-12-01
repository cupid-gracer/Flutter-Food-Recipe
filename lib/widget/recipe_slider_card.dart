import 'package:flutter/material.dart';
import 'package:recipe_flutter_provider/widget/google_admob.dart';

import '../screens/recipe_detail_screen.dart';
import '../constant/app_fonts.dart';
import '../provider/recipe.dart';
import 'custom_image.dart';

class RecipeSliderCard extends StatelessWidget {
  final RecipeItem recipe;
  final int index;
  final bool showFavorite;

  // final SelectedRecipe selectedRecipe;
  // final MainModel model;

  RecipeSliderCard({
    this.recipe,
    this.index,
    this.showFavorite = false,
    // @required this.selectedRecipe,
    // @required this.model
  });

  Widget _buildCardWithShadow(BuildContext context) {
    bool showHero = true;
    final double width = MediaQuery.of(context).size.width - 30;
    var boxDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(25.0),
      color: Theme.of(context).primaryColor,
      boxShadow: [
        BoxShadow(
          blurRadius: 3,
          spreadRadius: 3,
          color: Theme.of(context).textTheme.body1.shadows.first.color,
        ),
      ],
    );
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      padding: EdgeInsets.only(top: 7.0, right: 7.0, left: 7.0),
      width: width / 2,
      decoration: boxDecoration,
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Expanded(
                child: showHero
                    ? Hero(
                        tag: recipe.recipeId,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: CustomImage(
                            imgURL: recipe.recipesImageUrl.first,
                            width: width,
                            height: 90,
                          ),
                        ))
                    : CustomImage(
                        imgURL: recipe.recipesImageUrl.first,
                        width: width,
                        height: 90,
                      ),
              ),
              SizedBox(height: 5),
              _buildName(context, recipe.recipeName),
              SizedBox(height: 5),
              double.parse(recipe.calories) > 0
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildTime(context, recipe.recipesTime),
                        _buildCal(context, recipe.calories),
                      ],
                    )
                  : _buildTime(context, recipe.recipesTime),
              SizedBox(height: 7)
            ],
          ),
          showFavorite && recipe.isBookmark
              ? Align(
                  alignment: Alignment.topRight,
                  child: FloatingActionButton(
                    heroTag: null,
                    mini: true,
                    // elevation: 0,
                    backgroundColor: Colors.white,

                    child: Icon(
                      Icons.favorite,
                      color: Theme.of(context).accentColor,
                    ),
                    onPressed: () {},
                  ),
                )
              : Container(),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  final result = await Navigator.of(context).pushNamed(
                    RecipeDetailScreen.routeName,
                    arguments: recipe,
                  );
                  showHero = result != null ? result : true;
                  // GoogleAddmob.myBanner = null;
                },
              ),
            ),
          )
        ],
      ),
    );
  }

//Recipe Name...
  Widget _buildName(BuildContext context, String name) {
    return Text(
      name,
      style: TextStyle(
        color: Theme.of(context).textTheme.title.color,
        fontFamily: AppFonts.montserrat,
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }

//Recipe Time...
  Widget _buildTime(BuildContext context, String time) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.timer,
          size: 15.0,
        ),
        Text(
          " " + time,
          style: TextStyle(
            color: Theme.of(context).textTheme.subtitle.color,
            fontFamily: AppFonts.montserrat,
            fontSize: 11.0,
          ),
        )
      ],
    );
  }

  Widget _buildCal(BuildContext context, String cal) {
    return Row(
      children: [
        Icon(
          Icons.local_fire_department,
          size: 15.0,
        ),
        Text(
          " " + cal + " cal",
          style: TextStyle(
            color: Theme.of(context).textTheme.subtitle.color,
            fontFamily: AppFonts.montserrat,
            fontSize: 11.0,
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildCardWithShadow(context);
  }
}
