import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_flutter_provider/widget/google_admob.dart';
import 'package:recipe_flutter_provider/locale/app_localization.dart';

import '../provider/recipe.dart';
import '../widget/recipes_grid.dart';
import '../constant/static_string.dart';

class RecipesScreen extends StatefulWidget {
  static const routeName = '/recipe-screen';
  final bool isFromDrawer;

  const RecipesScreen(this.isFromDrawer);

  // const RecipesScreen({Key key,}) : super(key: key);
  // @override
  _RecipesScreenState createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  bool _isLoading = false;
  bool _isInit = true;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      _isLoading = true;

      try {
        await Provider.of<RecipesProvider>(context, listen: false)
            .fetchAndSetRecipes(context: context);
      } catch (e) {
        print('no internet in catch ${e.toString()}');
      }

      setState(() {
        _isLoading = false;
      });

      _isInit = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<RecipeItem> recipes =
        Provider.of<RecipesProvider>(context, listen: false).recipes;
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : Scaffold(
            appBar: AppBar(
              title: Text(S.of(context).recipe),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
              // actions: [Icon(Icons.add),],
            ),
            // drawer: AppDrawer(),
            body: SafeArea(
              child: Stack(
                children: <Widget>[
                  RecipesGrid(
                    recipes,
                  )
                ],
              ),
            ),
          );
  }
}
