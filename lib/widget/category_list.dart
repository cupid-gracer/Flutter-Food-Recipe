import 'package:flutter/material.dart';
import 'package:recipe_flutter_provider/widget/google_admob.dart';
import 'package:recipe_flutter_provider/locale/app_localization.dart';

import './category_card.dart';
import '../provider/category.dart';
import './no_recipes.dart';
import '../constant/static_string.dart';

class CategoryList extends StatelessWidget {
  final List<CategoryItem> categories;

  CategoryList(this.categories);

  @override
  Widget build(BuildContext context) {
    return categories.length > 0
        ? ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: categories.length,
            itemBuilder: (BuildContext context, int index) {
              return CategoryCard(categories[index]);
            },
          )
        : NoRecipes(title: S.of(context).noCategory);
  }
}
