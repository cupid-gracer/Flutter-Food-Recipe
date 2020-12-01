import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_flutter_provider/constant/static_string.dart';
import 'package:recipe_flutter_provider/provider/auth.dart';
import 'package:recipe_flutter_provider/provider/theme_provider.dart';
import 'package:recipe_flutter_provider/widget/google_admob.dart';
import 'package:recipe_flutter_provider/locale/app_localization.dart';

import 'search_screen.dart';
import '../provider/recipe.dart';
import '../widget/recipes_grid.dart';
import '../widget/no_recipes.dart';
import '../widget/shopping_tile.dart';

class ShoppingListScreen extends StatefulWidget {
  static const routeName = '/shopping-list-detail-Screen';

  @override
  _ShoppingListScreenState createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  bool _isLoading = false;
  bool _isInit = true;

  String catId;
  String catName;
  @override
  void initState() {
    super.initState();
    // GoogleAddmob.loadAd();
    // GoogleAdmob(adState: 1,);
  }

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });

      // final Map<String, String> map = ModalRoute.of(context).settings.arguments;
      // catId = map['catId'];
      // catName = map['catName'];
      // await Provider.of<RecipesProvider>(context, listen: false)
      //     .fetchAndSetRecipes(catId: catId, context: context);

      setState(() {
        _isLoading = false;
      });

      _isInit = false;

      super.didChangeDependencies();
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeNotifier themeNotifier = Provider.of<ThemeNotifier>(context);
    List<RecipeItem> slRecipes =
        Provider.of<RecipesProvider>(context, listen: false).slRecipes;
    return Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).shoppingList),
          // actions: <Widget>[
          //   IconButton(
          //     icon: Icon(Icons.search),
          //     onPressed: () {
          //       showSearch(
          //         context: context,
          //         delegate: SearchScreen(SearchType.values[3]),
          //       );
          //     },
          //   )
          // ],
        ),
        body: Provider.of<AuthProvider>(context, listen: false)
                        .loginStatus
                    ? _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : slRecipes.length > 0
                            ? Padding(
                                padding: EdgeInsets.all(15),                               
                                child:
                                SingleChildScrollView(child:
                                 Consumer<RecipesProvider>(
                                    builder: (ctx, recipeProvider, child) {
                                  return ListView.builder(
                                      scrollDirection: Axis.vertical,
                                      itemCount:
                                          recipeProvider.slRecipes.length,
                                      shrinkWrap: true,
                                      physics: ScrollPhysics(),
                                      itemBuilder: (BuildContext context,
                                          int listIndex) {
                                        return Padding(
                                            padding:
                                                EdgeInsets.only(bottom: 10),
                                            child: ShoppingTile(
                                              recipe: recipeProvider
                                                  .slRecipes[listIndex],
                                              index: listIndex,
                                            ));
                                      });
                                })))
                            : Align(
                                alignment: Alignment.center,
                                child: NoRecipes(
                                    title: S.of(context).noShoppingList))
                    // mounted?GoogleAdmob(adState: 1,):null,
                    : Align(
                        alignment: Alignment.center,
                        child:
                            NoRecipes(title: S.of(context).noShoppingList)));
  }
}
