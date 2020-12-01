import 'package:flutter/material.dart';
import 'package:recipe_flutter_provider/widget/google_admob.dart';

import '../screens/recipe_detail_screen.dart';
import '../constant/app_fonts.dart';
import '../provider/recipe.dart';
import './custom_image.dart';

class RecipeCard extends StatelessWidget {
  final RecipeItem recipe;
  final int index;
  final bool showFavorite;
  final bool netState;

  // final SelectedRecipe selectedRecipe;
  // final MainModel model;

  RecipeCard({
    this.recipe,
    this.index,
    this.showFavorite = false,
    this.netState = true,
    // @required this.selectedRecipe,
    // @required this.model
  });

  Widget _buildCardWithShadow(BuildContext context) {
    bool showHero = true;
    final double width = MediaQuery.of(context).size.width - 30;
    var boxDecoration = BoxDecoration(
      color: Theme.of(context).primaryColor,
      boxShadow: [
        BoxShadow(
          blurRadius: 3.0,
          spreadRadius: 3.0,
          color: Theme.of(context).textTheme.body1.shadows.first.color,
        )
      ],
    );

    recipe.recipesImageUrl.forEach((element) {
      // print("ImgURL: $element");
    });
    return Container(
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
                        child: CustomImage(
                          imgURL: recipe.recipesImageUrl.first,
                          width: width,
                          height: 90,
                        ),
                      )
                    : CustomImage(
                        imgURL: recipe.recipesImageUrl.first,
                        width: width,
                        height: 90,
                        connectivity: this.netState,
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
                        _buildCal(context, recipe.calories)
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
                  // print("test test test ${recipe.youtube}");
                  // final result = await Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => new RecipeDetailScreen(
                  //         youtube_link: recipe.youtube,
                  //       ),
                  //     ));
                  // showHero = result != null ? result : true;
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
