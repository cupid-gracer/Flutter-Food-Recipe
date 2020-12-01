import 'package:flutter/material.dart';
import 'package:recipe_flutter_provider/widget/google_admob.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

import '../screens/recipe_detail_screen.dart';
import '../constant/app_fonts.dart';
import '../provider/recipe.dart';
import '../constant/decoration.dart';
import 'custom_image.dart';

class ShoppingTile extends StatelessWidget {
  final RecipeItem recipe;
  final int index;

  // final SelectedRecipe selectedRecipe;
  // final MainModel model;

  ShoppingTile({
    @required this.recipe,
    this.index,
    // @required this.selectedRecipe,
    // @required this.model
  });

  List<String> ingredients = [];

  void setIngredients() {
    recipe.ingredients.forEach((element) {
      if (element.isChecked) {
        ingredients.add(element.quantity +
            " " +
            element.weight +
            "  " +
            element.ingredientName);
      }
    });
  }

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
          fontSize: 20),
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
    setIngredients();

    return Container(
      decoration: cardDecoration(context: context),
      child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildName(context, recipe.recipeName),
                  // IconButton(
                  //     icon: Icon(
                  //   Icons.more_vert,
                  //   size: 25.0,
                  // ), onPressed: (){},),
                  popupMenuButton(context)
                ],
              ),
              SizedBox(
                height: 10,
              ),
              ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: ingredients.length,
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  itemBuilder: (BuildContext context, int listIndex) {
                    return Container(
                      padding: EdgeInsets.only(top: 5, bottom: 5),
                      child: Row(
                        children: [
                          Icon(Icons.push_pin),
                          Padding(padding: EdgeInsets.only(left: 10)),
                          Expanded(child: Text(ingredients[listIndex])),
                        ],
                      ),
                    );
                  }),
            ],
          )),
    );
  }

  Widget popupMenuButton(BuildContext context) {
    return PopupMenuButton<String>(
      elevation: 50,
      padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
      icon: Icon(Icons.more_vert, size: 25),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: "view_recipe",
          child: Text("View Recipe"),
        ),
        PopupMenuItem<String>(
          value: "share",
          child: Text("Share"),
        ),
        PopupMenuItem<String>(
          value: "delete",
          child: Text("Delete"),
        )
      ],
      onSelected: (String value) {
        if(value == "view_recipe"){
           Navigator.of(context).pushNamed(
                    RecipeDetailScreen.routeName,
                    arguments: recipe,
                  );
        }else if(value == "share"){
          Share.share(recipe.shareUrl);
        }else if(value == "delete"){
          Provider.of<RecipesProvider>(context, listen: false).deleteSL(recipe);
        }
      },
    );
  }
}
