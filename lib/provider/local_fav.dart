import 'dart:ffi';
import 'dart:io';

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

import '../constant/custom_dialog.dart';
import '../api/api_call.dart';

class LocalFavProvider with ChangeNotifier {
  List<FavItem> _favRecipes = [];
  FavStorage storage = FavStorage();

  List<FavItem> get favRecipes {
    return List.from(_favRecipes);
  }

  Future<void> fetchAndSetFavRecipes({@required BuildContext context}) async {
    //API Parameters...

    Map<String, String> parameters = {
      "search": "",
      "bookmark": '1',
      "offset": '0',
      "limit": '1000',
    };

    try {
      final responseData = await ApiCall.callService(
          context: context, webApi: API.Recipe, parameter: parameters);
      // log(responseData);
      List<FavItem> favItems = recipeFromJson(responseData).data;
      // print(responseData);
      favItems.asMap().forEach((key, fav) {
        fav.recipesImageUrl.asMap().forEach((key, imgurl) async {
          // print("url1: ${imgurl}");
          // await downloadImg(imgurl);
        });
      });
      saveFavs(favItems);
      print("Saved Favs");
      // print("${await readFile()}");
      // log(await readFile());
      _favRecipes = favItems;
    } catch (error) {
      showDialog(
        context: context,
        builder: (context) {
          return CustomDialog(
            title: error is NoInternetException ? 'No Internet!!!' : 'Error!!!',
            buttonText: 'Okay',
            description: error.toString(),
            alertType: error is NoInternetException
                ? CustomDialogType.NoInternet
                : CustomDialogType.Error,
          );
        },
      );
      throw error;
    }

    notifyListeners();
  }

  Future<void> readAndSetFavs({@required BuildContext context}) async {
    String strFavs = await readFile();
    // log("test readAndSetFavs: $strFavs");
    List<dynamic> list = json.decode(strFavs);
    // log(list);
    List<FavItem> FavItems =
        List<FavItem>.from(list.map((x) => FavItem.fromJson(x)));
    FavItems.forEach((element) {
      print("test: ${element.recipeId}");
    });

    _favRecipes = FavItems;
    // notifyListeners();
  }

  int getIndex(FavItem recipe, List<FavItem> list) {
    if (list != null) {
      return list.indexWhere((value) {
        return value.recipeId == recipe.recipeId;
      });
    }
    return null;
  }

  Future<String> readFile() async {
    String str = "[";
    str += await storage.readFavor();
    str = str.substring(0,str.length-1);
    str += "]";
    return str;
  }

  Future<void> downloadImg(String url) async {
    print("URL: $url}");
    String localPath = (await storage._localPath) + '/img/';
    final savedDir = Directory(localPath);
    bool hasExisted = await savedDir.exists();

    if (!hasExisted) {
      savedDir.create();
    }

    final taskId = await FlutterDownloader.enqueue(
      url: url,
      savedDir: localPath,
      showNotification:
          false, // show download progress in status bar (for Android)
      openFileFromNotification:
          false, // click on notification to open downloaded file (for Android)
    );
    print("Taskid: $taskId");
    print("SaveUrl: $localPath");
  }

  void saveFavs(List<FavItem> favItems) {
    String str = "";
    favItems.asMap().forEach((key, fav) async {
      str += json.encode(fav.toJson()) + ',';
      // await addFav(fav);
    });
    // log("saveFavs: $str");
    storage.writeFavor(str);
  }

  Future<void> addFav(FavItem fav) async {
    String str = fav.toJson().toString();
    String prevStr = await readFile();
    await storage.writeFavor(prevStr + "," + str);
  }

  Future<bool> removeFav(FavItem fav) async {
    List<FavItem> FavItems;
    _favRecipes.forEach((item) { 
      if(item.recipeId != fav.recipeId){
        FavItems.add(item);
      }
    });
    saveFavs(FavItems);
  }





}

//Storage Class
class FavStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    print("FilePath: $path/favor.txt");
    return File('$path/favor.txt');
  }

  Future<String> readFavor() async {
    try {
      final file = await _localFile;

      // Read the file
      String contents = await file.readAsString();

      return contents;
    } catch (e) {
      // If encountering an error, return 0
      return "";
    }
  }

  Future<File> writeFavor(String favor) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString('$favor');
  }
}

//Get Reciep from Json...
FavResponse recipeFromJson(String str) =>
    FavResponse.fromJson(json.decode(str));
FavResponse bookmarkRecipeFromJson(String str) =>
    FavResponse.fromJsonForBookmark(json.decode(str));

class FavResponse {
  bool status;
  int code;
  List<FavItem> data;
  FavItem bookMarkData;

  FavResponse({this.status, this.code, this.data, this.bookMarkData});

  factory FavResponse.fromJson(Map<String, dynamic> json) => FavResponse(
        status: json["status"],
        code: json["code"],
        data: List<FavItem>.from(json["data"].map((x) => FavItem.fromJson(x))),
      );

  factory FavResponse.fromJsonForBookmark(Map<String, dynamic> json) =>
      FavResponse(
        status: json["status"],
        code: json["code"],
        bookMarkData: FavItem.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "code": code,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class FavItem with ChangeNotifier {
  String recipeId;
  String recipeName;
  String catId;
  String categoryName;
  String createdBy;
  String creatorImageUrl;
  String calories;
  String servingPerson;
  String recipesTime;
  List<String> recipesImageUrl;
  List<String> direction;
  String summary;
  List<Ingredient> ingredients;
  String shareUrl;
  String rating;
  bool isBookmark;

  FavItem({
    this.recipeId,
    this.recipeName,
    this.catId,
    this.categoryName,
    this.createdBy,
    this.creatorImageUrl,
    this.calories,
    this.servingPerson,
    this.recipesTime,
    this.recipesImageUrl,
    this.direction,
    this.summary,
    this.ingredients,
    this.shareUrl,
    this.rating,
    this.isBookmark,
  });

  factory FavItem.fromJson(Map<String, dynamic> json) {
    // print('recipe detail ${json["ingredients"]}');
    return FavItem(
      recipeId: json["recipe_id"],
      recipeName: json["recipe_name"],
      catId: json["cat_id"],
      categoryName: json["category_name"],
      createdBy: json["created_by"],
      creatorImageUrl: json["creator_image_url"],
      calories: json["calories"],
      servingPerson: json["serving_person"],
      recipesTime: json["recipes_time"],
      recipesImageUrl:
          List<String>.from(json["recipes_image_url"].map((x) => x)),
      direction: List<String>.from(json["direction"].map((x) => x)),
      summary: json["summary"],
      ingredients: List<Ingredient>.from(
          json["ingredients"].map((x) => Ingredient.fromJson(x))),
      shareUrl: json["share_url"],
      rating: json["rating"],
      isBookmark: json["is_bookmark"] == "1" ? true : false,
    );
  }

  Map<String, dynamic> toJson() => {
        "recipe_id": recipeId,
        "recipe_name": recipeName,
        "cat_id": catId,
        "category_name": categoryName,
        "created_by": createdBy,
        "creator_image_url": creatorImageUrl,
        "calories": calories,
        "serving_person": servingPerson,
        "recipes_time": recipesTime,
        "recipes_image_url": List<dynamic>.from(recipesImageUrl.map((x) => x)),
        "direction": List<dynamic>.from(direction.map((x) => x)),
        "summary": summary,
        "ingredients": List<dynamic>.from(ingredients.map((x) => x.toJson())),
        "share_url": shareUrl,
        "rating": rating,
        "is_bookmark": isBookmark,
      };
}

class Ingredient {
  String ingredientName;
  String quantity;
  String weight;
  bool isChecked;

  Ingredient(
      {this.ingredientName,
      this.quantity,
      this.weight,
      this.isChecked = false});

  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
      ingredientName: json["ingredient_name"],
      quantity: json["quantity"],
      weight: json["weight"],
      isChecked: false);

  Map<String, dynamic> toJson() => {
        "ingredient_name": ingredientName,
        "quantity": quantity,
        "weight": weight,
      };
}
