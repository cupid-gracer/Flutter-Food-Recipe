import 'package:flutter/material.dart';
import 'package:recipe_flutter_provider/locale/app_localization.dart';

import '../constant/app_images.dart';
import '../constant/static_string.dart';
import '../constant/app_fonts.dart';

class NoRecipes extends StatelessWidget {
  final String title;
  NoRecipes({this.title = "No Recipe!"});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            AppImages.noRecipe,
            width: screenSize.width / 5,
            fit: BoxFit.cover,
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            title,
            style: TextStyle(
              fontFamily: AppFonts.montserrat,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
