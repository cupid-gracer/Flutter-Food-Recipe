import 'package:flutter/material.dart';
import 'package:recipe_flutter_provider/widget/google_admob.dart';

import '../constant/app_fonts.dart';
import '../screens/category_detail_screen.dart';
import '../widget/custom_image.dart';
import '../provider/category.dart';

class CategoryCard extends StatelessWidget {
  final CategoryItem category;

  CategoryCard(this.category);

  @override
  Widget build(BuildContext context) {
    final double targetWidth = MediaQuery.of(context).size.width - 10;
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(7),
      width: (MediaQuery.of(context).size.width - 10) / 3,
      height: 150.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Theme.of(context).primaryColor,
        boxShadow: [
          BoxShadow(
            blurRadius: 3,
            spreadRadius: 3,
            color: Theme.of(context).textTheme.body1.shadows.first.color,
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: CustomImage(
                    height: 42,
                    width: targetWidth,
                    imgURL: category.categoryImageUrl,
                    // placeholderImg: CustomImages.transparent,
                  ),
                ),
              ),
              SizedBox(height: 6),
              Text(
                category.categoryName,
                style: TextStyle(
                  color: Theme.of(context).textTheme.title.color,
                  fontFamily: AppFonts.montserrat,
                  fontSize: 15,
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  await Navigator.of(context).pushNamed(
                    CategoryDetailScreen.routeName,
                    arguments: {
                      'catId': category.cid,
                      'catName': category.categoryName,
                    },
                  );
                  // GoogleAddmob.myBanner = null;
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
