import 'dart:convert';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../provider/user.dart';
import '../constant/shared_preferences_helper.dart';
import '../provider/auth.dart';

//API List...
enum API {
  Recipe,
  Category,
  Bookmark,
  SingleSignOn,
  RegularLogin,
  SignUp,
  ForgotPassword,
  UpdateUserDetail,
  DeleteAccount,
  GetSettings,
  Rate,
  Comment,
}

//Request Type...
enum HTTPRequestType {
  POST,
  GET,
  DELETE,
  PUT,
  PATCH,
}

class ApiCall {
  //Set True to Use Live URL For Testing...

  //Base URL...
  // static String _liveBaseURL = 'https://recipesx.app/';
  static String _liveBaseURL = 'http://10.10.10.133/';
  // static String _liveBaseURL = 'https://portakalagaci.greytomato.net/';

  //URL Last Component...
  static List<String> _webAPIList = [
    'recipe',
    'get-category',
    'bookmark',
    'single-sign-on',
    'sign-in',
    'sign-up',
    'password-forgot',
    'update-user-detail',
    'delete-account',
    'get-setting',
    'rate',
    'comment',
  ];

  //Get Final URL
  static String getURL({@required API name}) {
    String url = _webAPIList[name.index];

    //Check if App is in Debug or Live Mode...
    String baseURL = _liveBaseURL;
    return baseURL + url;
  }

  //Call API...
  static Future<dynamic> callService({
    @required BuildContext context,
    HTTPRequestType requestType = HTTPRequestType.POST,
    @required API webApi,
    Map<String, String> parameter,
  }) async {
    final connection = await checkConnectivity();
    if (!connection) {
      print("NO No No!!");
      throw NoInternetException(
          'Please check internet connection, and try again.');
    }
    //Get Params and URL...
    String url = ApiCall.getURL(name: webApi);
    final Map<String, String> header = await ApiHelper.getHeader();

    print('Methods:- $requestType');
    print('URL:- $url');
    print('Parameters:- $parameter');
    print('Header:- $header');

    http.Response response;
    var apiResponse;

    try {
      //Check request Type
      if (requestType == HTTPRequestType.GET) {
        response = await http.get(url, headers: header);
      } else if (requestType == HTTPRequestType.POST) {
        response =
            await http.post(url, body: json.encode(parameter), headers: header);
      } else if (requestType == HTTPRequestType.DELETE) {
        response = await http.delete(url, headers: header);
      }
      apiResponse = _returnResponse(response);
    } catch(e) {
      print("Exception $e");
      throw FetchDataException("No Internet connection");
    }

    return apiResponse;
  }

  static Future<String> upload({
    @required BuildContext context,
    @required String token,
    @required File imageFile,
    @required UserItem userInfo,
    @required bool isSingleSignOn,
  }) async {
    final connection = await checkConnectivity();
    if (!connection) {
      print("NO No No!!");

      throw NoInternetException(
          'Please check internet connection, and try again.');
    }
    String url = ApiCall.getURL(name: API.UpdateUserDetail);
    var apiResponse;

    Uri uri = Uri.parse(url);
    http.MultipartRequest request = new http.MultipartRequest('POST', uri);
    request.fields['name'] = userInfo.firstname;
    request.fields['lastname'] = userInfo.lastname;
    request.fields['phone'] = userInfo.phone;
    request.headers[isSingleSignOn ? 'x-auth-token' : 'x-user-token'] = token;

    try {
      if (imageFile != null) {
        request.files.add(
            await http.MultipartFile.fromPath('profile_image', imageFile.path));
      }

      http.Response response =
          await http.Response.fromStream(await request.send());

      apiResponse = _returnResponse(response);
    } on SocketException {
      throw FetchDataException("No Internet connection");
    }

    return apiResponse;
  }

  static Future<bool> checkConnectivity() async {
    var connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      return false;
    }
    return true;
  }

  static Future<bool> checkCon() async {
    Map<String, String> parameter = {
      "search": "",
      "bookmark": '1',
      "offset": '0',
      "limit": '1000',
    };

    //Get Params and URL...
    String url = ApiCall.getURL(name: API.Recipe);
    final Map<String, String> header = await ApiHelper.getHeader();

    http.Response response;
    var apiResponse;

    try {
      //Check request Type
        response = 
            await http.post(url, body: json.encode(parameter), headers: header);
      apiResponse = _returnResponse(response);
      return true;
      print("NetWork OKAY ");
    } catch(e) {
      return false;
      print("NetWork Failed");
      // throw FetchDataException("No Internet connection");
    }
  }

  static Future<String> getFilePath() async {
    String filePath = (await getApplicationDocumentsDirectory()).path + "/img/";
    return filePath;
  }
}

dynamic _returnResponse(http.Response response) {
  //TODO: String message = (json.decode(response.body))['message']; need to add message
  switch (response.statusCode) {
    case 200:
      var responseJson = response.body.toString(); //json.decode();
      // print(responseJson);
      return responseJson;
      break;
    case 400:
      throw BadRequestException(json.decode(response.body)['message']);
      break;
    case 401:
    case 403:
      throw UnauthorisedException(json.decode(response.body)['message']);
      break;
    case 500:
    default:
      throw FetchDataException(
          'Error occured while Communication with Server with StatusCode : ${response.statusCode}');
  }
}

class ApiHelper {
  static String token = '';
  static String _singleSignOntoken = '';
  static String _authtoken = '';
  static Map<String, String> _header;
  static const String _key = "6JPN3cFCkCcSajuQUze5kwK0muEnoq";

  static Future<Map<String, String>> getHeader() async {
    String info = await SharedPreferencesHelper.getAuthInfo();
    AuthResponse authInfo =
        info.isEmpty ? AuthResponse() : authInfoFromJson(info);

    if (authInfo.signOnType != 'regular' && authInfo.signOnType != "") {
      token = await ApiHelper.getCurrentUserToken();
    }

    _singleSignOntoken = authInfo.signOnType == 'regular' ? "" : token;
    _authtoken = authInfo.signOnType == 'regular' ? authInfo.authToken : "";

    _header = {
      'Content-Type': 'application/json',
      'X-Api-Key': _key,
      'X-Auth-Token': _singleSignOntoken,
      'X-User-Token': _authtoken
    };

    return _header;
  }

  static Future<String> getCurrentUserToken() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if (user != null) {
      //Get ID Token...p
      IdTokenResult idToken = await user.getIdToken(refresh: true);
      return idToken.token;
    } else {
      return "";
    }
  }
}

class AppException implements Exception {
  final _message;
  final _prefix;

  AppException([this._message, this._prefix]);

  String toString() {
    return "$_prefix$_message";
  }
}

class NoInternetException extends AppException {
  NoInternetException([String message]) : super(message, "");
}

class FetchDataException extends AppException {
  FetchDataException([String message])
      : super(message, "Error During Communication!");
}

class BadRequestException extends AppException {
  BadRequestException([String message]) : super(message, "");
}

class UnauthorisedException extends AppException {
  UnauthorisedException([String message]) : super(message, "");
}

class InvalidInputException extends AppException {
  InvalidInputException([String message]) : super(message, "");
}
