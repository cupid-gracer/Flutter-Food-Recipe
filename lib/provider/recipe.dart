import 'dart:convert';
import 'dart:io';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

import '../constant/custom_dialog.dart';
import '../api/api_call.dart';

class RecipesProvider with ChangeNotifier {
  List<RecipeItem> _recipes = [];
  List<RecipeItem> _recipesByCategory = [];
  List<RecipeItem> _favRecipes = []; //favorite Recipes
  List<RecipeItem> _slRecipes = []; //Shopping List Recipes
  Storage favStorage = Storage("", "favor.txt"); //Favorite Storage
  Storage slStorage = Storage("", "sl.txt"); //Favorite Storage
  RecipeItem _todayRecipe;
  List<RecipeItem> get recipes {
    return List.from(_recipes);
  }

  List<RecipeItem> get recipesByCat {
    return List.from(_recipesByCategory);
  }

  List<RecipeItem> get favRecipes {
    return List.from(_favRecipes);
  }

  List<RecipeItem> get slRecipes {
    return List.from(_slRecipes);
  }

  RecipeItem get todayRecipe {
    return _todayRecipe;
  }

  Future<void> fetchAndSetRecipes(
      {@required BuildContext context, String catId}) async {

    //API Parameters...
    // if (recipes.length > 0 && catId == null) {
    //   // notifyListeners();
    //   return;
    // }

    Map<String, String> parameters = {
      "search": "",
      "offset": '0',
      "limit": '100',
      "category_id": catId != null ? catId : ''
    };

    try {
      final responseData = await ApiCall.callService(
          context: context, webApi: API.Recipe, parameter: parameters);
      List<RecipeItem> recipeItems = recipeFromJson(responseData).data;
      recipeItems.forEach((element) { 
        if(element.today_recipe){
          _todayRecipe = element;
        }
      });
      if (catId != null) {
        _recipesByCategory = recipeItems;
      } else {
        _recipes = recipeItems;
      }
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

      List<RecipeItem> recipeItems = recipeFromJson(responseData).data;
      recipeItems.asMap().forEach((key, fav) {
        fav.recipesImageUrl.asMap().forEach((key, imgurl) async {
          await downloadImg(imgurl);
        });
      });
      // getFileList();
      _favRecipes = recipeItems;
      saveFavs(recipeItems);
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

  Future<void> fetchAndSetSLRecipes({@required BuildContext context}) async {
    String strSL = await readFile(slStorage);
    log("fetchAndSetSLRecipes: $strSL");
    List<dynamic> list = json.decode(strSL);
    List<RecipeItem> slItems =
        List<RecipeItem>.from(list.map((x) => RecipeItem.fromJson(x)));

    _slRecipes = slItems;
    await syncSL();
    notifyListeners();
  }

 Future<bool> rateRecipe(
      {@required BuildContext context, String recipeId, String rating}) async {
    //API Parameters...

    Map<String, String> parameters = {
      "recipe_id": recipeId,
      "rating": rating
    };

    try {
      await ApiCall.callService(
          context: context, webApi: API.Rate, parameter: parameters);
      return true;
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
      return false;
      // throw error;
    }
  }

Future<bool> commentRecipe(
      {@required BuildContext context, String recipeId, String comment, String reply_comment_id = "0"}) async {
    //API Parameters...

    Map<String, String> parameters = {
      "recipe_id": recipeId,
      "comment": comment,
      "reply_comment_id":reply_comment_id
    };

    try {
      await ApiCall.callService(
          context: context, webApi: API.Comment, parameter: parameters);
      return true;
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
      return false;
    }
  }


  Future<void> syncSL() async {
    _slRecipes.forEach((slRecipe) {
      _recipes.asMap().forEach((key, recipe) {
        if (recipe.recipeId == slRecipe.recipeId) {
          _recipes[key] = slRecipe;
        }
      });
      _favRecipes.asMap().forEach((key, recipe) {
        if (recipe.recipeId == slRecipe.recipeId) {
          _favRecipes[key] = slRecipe;
        }
      });
    });
    if (_slRecipes.length == 0) {
      _recipes.asMap().forEach((key1, recipe) {
        recipe.ingredients.asMap().forEach((key2, ingredient) {
          _recipes[key1].ingredients[key2].isChecked = false;
        });
      });
      _favRecipes.asMap().forEach((key1, favrecipe) {
        favrecipe.ingredients.asMap().forEach((key2, ingredient) {
          _favRecipes[key1].ingredients[key2].isChecked = false;
        });
      });
    }
  }

  Future<void> addSL(RecipeItem recipe) async {
    //  check shopping list
    bool exist = false;
    // log("addSL: ${json.encode(recipe.toJson())}");
    _slRecipes.asMap().forEach((key, element) {
      if (recipe.recipeId == element.recipeId) {
        exist = true;
        _slRecipes[key] = recipe;
        return;
      }
    });
    if (!exist) {
      _slRecipes.add(recipe);
      String prevStr = await slStorage.read();
      String str = json.encode(recipe.toJson());
      await slStorage.write(prevStr + str + ",");
    } else {
      String str = "";
      _slRecipes.forEach((element) {
        str += json.encode(element.toJson()) + ',';
      });
      slStorage.write(str);
    }
    await syncSL();
    notifyListeners();
  }

  Future<void> removeSL(RecipeItem recipe) async {
    //  uncheck shopping list
    bool isCheck = false;
    recipe.ingredients.forEach((element) {
      if (element.isChecked) {
        isCheck = true;
        return;
      }
    });
    if (!isCheck) {
      _slRecipes.removeWhere((element) => element.recipeId == recipe.recipeId);
    } else {
      _slRecipes.asMap().forEach((key, element) {
        if (recipe.recipeId == element.recipeId) {
          _slRecipes[key] = recipe;
          return;
        }
      });
    }

    String str = "";
    _slRecipes.forEach((element) {
      str += json.encode(element.toJson()) + ',';
    });
    slStorage.write(str);
    await syncSL();
    notifyListeners();
  }

  Future<void> removeAllSL() async {
    //  uncheck shopping list
    _recipes.forEach((element) {
      element.ingredients.forEach((el) {
        el.isChecked = false;
      });
    });

    notifyListeners();
  }

  Future<void> deleteSL(RecipeItem recipe) async {
    _slRecipes.removeWhere((element) => element.recipeId == recipe.recipeId);
    _recipes.asMap().forEach((key1, _recipe) {
      if (_recipe.recipeId == recipe.recipeId) {
        _recipe.ingredients.asMap().forEach((key2, value) {
          _recipes[key1].ingredients[key2].isChecked = false;
        });
      }
    });
    String str = "";
    _slRecipes.forEach((element) {
      str += json.encode(element.toJson()) + ',';
    });
    slStorage.write(str);
    await syncSL();
    notifyListeners();
  }

  getMultiRecipes(RecipeItem recipe) {
    List<RecipeItem> results = [];
    bool f = false;
    if(_recipes.length < 2) return results;
    if (_recipes.length == 2) {
      _recipes.forEach((rec) {
        if (rec.recipeId == recipe.recipeId) {
          f = true;
          return;
        }
        if (f) {
          results.add(rec);
        }
        if (results.length == 0) {
          results.add(_recipes[0]);
        }
      });
      return results;
    }


    _recipes.forEach((rec) {
      if (rec.recipeId == recipe.recipeId) {
        f = true;
        return;
      }
      if (f && results.length < 2) {
        results.add(rec);
      }
    });

    if (results.length == 0) {
      results.add(_recipes[0]);
      results.add(_recipes[1]);
    } else if (results.length == 1) {
      results.add(_recipes[0]);
    }
    return results;
  }

  Future<bool> toggleFavoriteStatus({
    @required BuildContext context,
    RecipeItem recipe,
  }) async {
    // notifyListeners();

    final oldStatus = recipe.isBookmark;
    try {
      Map<String, String> parameters = {
        'bookmark': !oldStatus ? '1' : '0',
        'recipe_id': recipe.recipeId,
      };

      final responseData = await ApiCall.callService(
          context: context, webApi: API.Bookmark, parameter: parameters);
      // print('response $responseData');

      final int indexInFavRecipe = getIndex(recipe, _favRecipes);
      recipe.isBookmark = !oldStatus;
      replaceRecipeFromAllList(recipe);

      if (indexInFavRecipe != null && indexInFavRecipe >= 0 && oldStatus) {
        _favRecipes.removeAt(indexInFavRecipe);
      }
      notifyListeners();
      return true;
    } catch (error) {
      print("toggleFavoriteStatus error: $error ");
      notifyListeners();
      return false;
    }
  }

  void replaceRecipeFromAllList(RecipeItem recipe) {
    final int indexInRecipes = getIndex(recipe, _recipes);
    final int indexInCatRecipes = getIndex(recipe, _recipesByCategory);

    if (indexInRecipes != null && indexInRecipes >= 0) {
      _recipes[indexInRecipes] = recipe;
    }

    if (indexInCatRecipes != null && indexInCatRecipes >= 0) {
      _recipesByCategory[indexInCatRecipes] = recipe;
    }
  }

  int getIndex(RecipeItem recipe, List<RecipeItem> list) {
    if (list != null) {
      return list.indexWhere((value) {
        return value.recipeId == recipe.recipeId;
      });
    }
    return null;
  }

  Future<void> readAndSetFavs({@required BuildContext context}) async {
    String strFavs = await readFile(favStorage);
    List<dynamic> list = json.decode(strFavs);
    List<RecipeItem> FavItems =
        List<RecipeItem>.from(list.map((x) => RecipeItem.fromJson(x)));
    // FavItems.forEach((element) {});
    // await getFileList();

    _favRecipes = FavItems;
    notifyListeners();
  }

  Future<String> readFile(Storage st) async {
    String str = "[";
    String text = await st.read();
    // log("ReadFile: $text");
    if (text != "") str += text.substring(0, text.length - 1);
    str += "]";
    return str;
  }

  Future<void> downloadImg(String url) async {
    // print("URL: $url}");
    String localPath = (await favStorage._localPath) + '/img/';
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
    // print("Taskid: $taskId");
    // print("SaveUrl: $localPath");
  }

  void saveFavs(List<RecipeItem> favItems) async {
    String str = "";
    favItems.asMap().forEach((key, fav) async {
      fav.isBookmark = true;
      str += json.encode(fav.toJson()) + ',';
    });
    favStorage.write(str);
    // log("test: ${str}");
  }

  Future<void> addFav(RecipeItem fav) async {
    fav.isBookmark = true;
    _recipes.asMap().forEach((key, element) {
      if (fav.recipeId == element.recipeId) {
        // exist = true;
        _recipes[key].isBookmark = true;
        return;
      }
    });
    _favRecipes.add(fav);

    String str = json.encode(fav.toJson());
    String prevStr = await favStorage.read();
    await favStorage.write(prevStr + str + ",");
    fav.recipesImageUrl.forEach((url) async {
      await downloadImg(url);
    });
    notifyListeners();

    //test
    // String strFavs = await readFile(favStorage);
    // List<dynamic> list = json.decode(strFavs);
    // List<RecipeItem> favItems =
    //     List<RecipeItem>.from(list.map((x) => RecipeItem.fromJson(x)));
    // favItems.forEach((element) {
    //   print("added: ${element.recipeId}");
    //   print("isBookmarked: ${element.isBookmark}");
    // });
  }

  Future<bool> removeFav(RecipeItem fav) async {
    print("removeFav");
    _recipes.asMap().forEach((key, element) {
      if (fav.recipeId == element.recipeId) {
        // exist = true;
        _recipes[key].isBookmark = false;
        return;
      }
    });
    _favRecipes.removeWhere((element) => element.recipeId == fav.recipeId);

    String strFavs = await readFile(favStorage);
    // log("test removeFav: $strFavs");
    List<dynamic> list = json.decode(strFavs);
    // log(list);
    List<RecipeItem> favItemsTemp = [];
    List<RecipeItem> favItems =
        List<RecipeItem>.from(list.map((x) => RecipeItem.fromJson(x)));
    favItems.forEach((item) {
      if (item.recipeId != fav.recipeId) {
        print("removeFav: ${item.recipeId}");
        favItemsTemp.add(item);
      } else {
        item.recipesImageUrl.forEach((url) async {
          deleteFile(await getFilePath(url));
        });
      }
    });
    saveFavs(favItemsTemp);
    notifyListeners();
  }

  void getFileList() async {
    Directory dir = Directory((await favStorage._localPath) + '/img/');
    List<FileSystemEntity> _files;
    _files = dir.listSync(recursive: true, followLinks: false);
    for (FileSystemEntity entity in _files) {
      print("getFileList: ${entity.uri}");
    }
  }

  void deleteFile(String path) async {
    try {
      var file = File(path);

      if (await file.exists()) {
        // file exits, it is safe to call delete on it
        await file.delete();
      }
    } catch (e) {
      // error in getting access to the file
    }
  }

  Future<String> getFilePath(String url) async {
    String path = (await getApplicationDocumentsDirectory()).path + '/img/';
    List<String> strs = url.split("/");
    return path + strs.last;
  }

  String getFileName(String url) {
    List<String> strs = url.split("/");
    return strs.last;
  }
}

//Get Reciep from Json...
RecipeResponse recipeFromJson(String str) =>
    RecipeResponse.fromJson(json.decode(str));
RecipeResponse bookmarkRecipeFromJson(String str) =>
    RecipeResponse.fromJsonForBookmark(json.decode(str));

class RecipeResponse {
  bool status;
  int code;
  List<RecipeItem> data;
  RecipeItem bookMarkData;

  RecipeResponse({this.status, this.code, this.data, this.bookMarkData});

  factory RecipeResponse.fromJson(Map<String, dynamic> json) => RecipeResponse(
        status: json["status"],
        code: json["code"],
        data: List<RecipeItem>.from(
            json["data"].map((x) => RecipeItem.fromJson(x))),
      );

  factory RecipeResponse.fromJsonForBookmark(Map<String, dynamic> json) =>
      RecipeResponse(
        status: json["status"],
        code: json["code"],
        bookMarkData: RecipeItem.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "code": code,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class RecipeItem with ChangeNotifier {
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
  List<Direction> direction;
  String summary;
  String youtube;
  List<Ingredient> ingredients;
  String shareUrl;
  String rating;
  bool isBookmark;
  bool today_recipe;

  RecipeItem({
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
    this.youtube,
    this.ingredients,
    this.shareUrl,
    this.rating,
    this.isBookmark,
    this.today_recipe,
  });

  factory RecipeItem.fromJson(Map<String, dynamic> json) {
    return RecipeItem(
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
      direction: List<Direction>.from(json["direction"].map((x) => Direction.fromJson(x))),
      summary: json["summary"],
      youtube: json["youtube"],
      ingredients: List<Ingredient>.from(json["ingredients"].map((x) => Ingredient.fromJson(x))),
      shareUrl: json["share_url"],
      rating: json["rating"],
      isBookmark: json["is_bookmark"] == "1" ? true : false,
      today_recipe: json["today_recipe"] == "1" ? true : false,
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
        "direction": List<dynamic>.from(direction.map((x) => x.toJson())),
        "summary": summary,
        "youtube": youtube,
        "ingredients": List<dynamic>.from(ingredients.map((x) => x.toJson())),
        "share_url": shareUrl,
        "rating": rating,
        "is_bookmark": isBookmark ? "1" : "0",
        "today_recipe": today_recipe ? "1" : "0",
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
      isChecked: json["isChecked"] != null ? json["isChecked"] : false);

  Map<String, dynamic> toJson() => {
        "ingredient_name": ingredientName,
        "quantity": quantity,
        "weight": weight,
        "isChecked": isChecked,
      };
}

class Direction {
  String description;
  bool isCheck;
  Direction({this.description, this.isCheck});

  toJson() => description;

  factory Direction.fromJson(String str) => Direction(
      description: str,
      isCheck: false);
}
//Storage Class
class Storage {
  String _directory; //    format:   img
  String _fileName; //    format:   example.txt

  Storage(String dir, String fileName) {
    _directory = dir;
    _fileName = fileName;
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    // print("FilePath: $path/favor.txt");
    String fullPath = "";
    fullPath = _directory != ""
        ? (path + '/' + _directory + '/' + _fileName)
        : (path + '/' + _fileName);
    return File(fullPath);
  }

  Future<String> read() async {
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

  Future<File> write(String favor) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString('$favor');
  }
}
