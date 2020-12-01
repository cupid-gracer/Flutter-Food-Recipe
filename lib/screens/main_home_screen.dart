import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_flutter_provider/widget/google_admob.dart';
import 'package:recipe_flutter_provider/widget/no_recipes.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../provider/recipe.dart';
import '../provider/category.dart';
import '../widget/recipes_grid.dart';
import '../widget/main_home.dart';

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({
    Key key,
  }) : super(key: key);
  @override
  _MainHomeScreenState createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  bool _isLoading = false;
  bool _isInit = true;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(Duration(milliseconds: 2000));
    await Provider.of<RecipesProvider>(context, listen: false)
        .fetchAndSetRecipes(context: context);
    await Provider.of<CategoryProvider>(context, listen: false)
        .fetchAndSetCategories(context: context);
    print("_onRefresh ");
    if (mounted)
      setState(() {
        _isLoading = false;
      });
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    print("_onLoading ");
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    // items.add((items.length+1).toString());
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

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
        await Provider.of<CategoryProvider>(context, listen: false)
            .fetchAndSetCategories(context: context);
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
        : recipes.length > 0
            ? SmartRefresher(
                enablePullDown: true,
                header: WaterDropHeader(),
                controller: _refreshController,
                onRefresh: _onRefresh,
                onLoading: _onLoading,
                child: MainHome(
                  recipes,
                ))
            : NoRecipes(title: "No Connection or Recipes!");
  }
}
