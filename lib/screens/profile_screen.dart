import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import '../constant/app_images.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:recipe_flutter_provider/locale/app_localization.dart';

import '../constant/shared_preferences_helper.dart';
import '../constant/app_bar.dart';
import '../constant/app_fonts.dart';
import '../constant/custom_text_form_field.dart';
import '../provider/user.dart';
import '../provider/theme_provider.dart';
import '../provider/auth.dart';
import '../provider/recipe.dart';
import '../screens/main_auth_screen.dart';
import '../screens/home_screen.dart';
import '../constant/static_string.dart';
import '../widget/app_drawer.dart';
import '../widget/no_recipes.dart';
import '../widget/safearea_with_banner.dart';
import '../widget/process_indicator_view.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile-screen';

  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _editingEnabled = false;

  final Map<String, String> _formData = {
    'firstname': '',
    'lastname': '',
    'phone': '',
  };

  UserItem _user;
  File imageFile;
  bool _isInit = true;
  bool _isLoading = false;
  bool _isUpdating = false;
  bool _isLogin = false;
  bool isEnglish = true;

  Future<File> imagePickerFile;

  FocusNode _firstNameFocusNode = FocusNode();
  FocusNode _lastNameFocusNode = FocusNode();
  FocusNode _mobileFocusNode = FocusNode();

  final List<String> userDetailKeyList = [
    StaticString.firstName,
    StaticString.lastName,
    StaticString.mobile,
    StaticString.email,
  ];

  @override
  void initState() {
    if (_isInit) {
      _isLoading = true;
      Provider.of<UserProvider>(context, listen: false)
          .fetchUserInfo()
          .then((_) {
        setState(() {
          _isLoading = false;
        });
      });
      SharedPreferencesHelper.getLangStatus().then((value) {
        print("init:::: $value");
        setState(() {
          if (value == "en")
            isEnglish = true;
          else
            isEnglish = false;
        });
      });
      _isLogin = Provider.of<AuthProvider>(context, listen: false).loginStatus;
    }

    super.initState();
  }

  @override
  void dispose() {
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _mobileFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    _user = Provider.of<UserProvider>(context, listen: false).getUserInfo;
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).profile),
          actions: <Widget>[
            !_isLogin
                ? FlatButton(
                    onPressed: () => Navigator.of(context)
                        .pushNamed(MainAuthScreen.routeName, arguments: true),
                    child: Text(
                      S.of(context).login,
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ))
                : Container(),
            !_isLoading
                ? _getEditIcon(
                    icon: _editingEnabled ? Icons.done : Icons.edit,
                    color: _editingEnabled
                        ? Colors.green
                        : Theme.of(context).accentColor)
                : Container(),
            !_isLoading
                ? _editingEnabled
                    ? _getEditIcon(icon: Icons.close, color: Colors.red)
                    : Container()
                : Container()
          ],
        ),
        // drawer: AppDrawer(),
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              SafeareaWithBanner(
                child: _isLogin
                    ? _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : Container(
                            height: screenSize.height,
                            width: screenSize.width,
                            child: SingleChildScrollView(
                              child: Container(
                                child: Column(
                                  children: <Widget>[
                                    // Stack(
                                    //   alignment: Alignment.topCenter,
                                    //   children: <Widget>[
                                    //     //Todo: show profile pic with update functionality
                                    //     _buildProfilePic(),
                                    //   ],
                                    // ),
                                    _buildForm(),
                                    SizedBox(height: 15),
                                    Text("Theme Change",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w900)),
                                    SizedBox(height: 15),
                                    Consumer<ThemeNotifier>(
                                      builder: (ctx, themeChanger, _) {
                                        return ListTile(
                                          leading:
                                              Icon(MdiIcons.themeLightDark),
                                          title: (themeChanger.getTheme() !=
                                                  darkTheme)
                                              ? Text(S.of(context).swithToDark)
                                              : Text(S.of(context).swithToLight),
                                          onTap: () {
                                            onThemeChanged(
                                                context,
                                                !(themeChanger.getTheme() ==
                                                    darkTheme),
                                                themeChanger);
                                          },
                                        );
                                      },
                                    ),
                                    Consumer<AuthProvider>(
                                        builder: (ctx, auth, child) {
                                      return auth.loginStatus
                                          ? ListTile(
                                              leading: Icon(MdiIcons.logout),
                                              title: Text(S.of(context).logOut),
                                              onTap: () {
                                                _showMaterialDialog(context);
                                              },
                                            )
                                          : Container();
                                    }),

                                    SizedBox(height: 15),
                                    Text("Language Change",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w900)),
                                    SizedBox(height: 15),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 15),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20)),
                                            boxShadow: [
                                              BoxShadow(
                                                  blurRadius: 10,
                                                  spreadRadius: 5,
                                                  color: isEnglish
                                                      ? Colors.black26
                                                      : Colors.black12)
                                            ]),
                                        child: ListTile(
                                          title: new Row(
                                            children: <Widget>[
                                              Image.asset(AppImages.fg_en,
                                                  height: 24),
                                              SizedBox(
                                                width: 15.0,
                                              ),
                                              Text(
                                                'English',
                                                style: TextStyle(
                                                    color: Colors.blue),
                                              ),
                                            ],
                                          ),
                                          trailing: Icon(
                                            Icons.check,
                                            color: isEnglish
                                                ? Colors.blue
                                                : Colors.white,
                                          ),
                                          onTap: () {
                                            S.load(Locale('en', 'US'));
                                            Provider.of<UserProvider>(context,
                                                    listen: false)
                                                .updateTabName("en");
                                            setState(() {
                                              isEnglish = true;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20)),
                                            boxShadow: [
                                              BoxShadow(
                                                  blurRadius: 10,
                                                  spreadRadius: 5,
                                                  color: isEnglish
                                                      ? Colors.black12
                                                      : Colors.black26)
                                            ]),
                                        child: ListTile(
                                          title: new Row(
                                            children: <Widget>[
                                              Image.asset(AppImages.fg_sp,
                                                  height: 24),
                                              SizedBox(
                                                width: 15.0,
                                              ),
                                              Text(
                                                'Spanish',
                                                style: TextStyle(
                                                    color: Colors.blue),
                                              ),
                                            ],
                                          ),
                                          trailing: Icon(Icons.check,
                                              color: isEnglish
                                                  ? Colors.white
                                                  : Colors.blue),
                                          onTap: () {
                                            Provider.of<UserProvider>(context,
                                                    listen: false)
                                                .updateTabName("es");
                                            setState(() {
                                              S.load(Locale('es', 'ES'));
                                              isEnglish = false;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 50),
                                  ],
                                ),
                              ),
                            ),
                          )
                    : NoRecipes(title: "Please login!"),
              ),
              _isUpdating ? ProcessIndicatorView() : Container(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getEditIcon({@required IconData icon, @required Color color}) {
    return Consumer<UserProvider>(
      builder: (ctx, userProvider, child) {
        return GestureDetector(
          child: child,
          onTap: () async {
            if (icon == Icons.done) {
              if (!_formKey.currentState.validate()) {
                return;
              }

              setState(() {
                _isUpdating = true;
              });

              _formKey.currentState.save();

              UserItem userInfo = UserItem.fromJson(_formData);

              bool isUpdated = await userProvider.updateUserDetails(
                  context: context, userInfo: userInfo, imageFile: imageFile);

              setState(() {
                _isUpdating = false;
              });

              // check if is updated successfully show alert
            }

            setState(() {
              _editingEnabled = !_editingEnabled;
            });
          },
        );
      },
      child: Padding(
        padding: EdgeInsets.only(right: 20.0),
        child: CircleAvatar(
          backgroundColor: color,
          radius: 16.0,
          child: Icon(
            icon,
            color: Colors.white,
            size: 16.0,
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePic() {
    return GestureDetector(
      onTap: () {
        if (_editingEnabled) {
          showCupertinoModalPopup(
            context: context,
            builder: (ctx) {
              return Container();
//              return _showActionSheet();
            },
          );
        }
      },
      child: Container(
        margin: EdgeInsets.only(top: 30),
        height: 130,
        width: 130,
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: Colors.grey.withOpacity(0.4), width: 2),
          borderRadius: BorderRadius.circular(65),
        ),
        child: ClipRect(
          child: FutureBuilder<File>(
            future: imagePickerFile,
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Image.asset(
                  AppImages.noProfileImg,
                  fit: BoxFit.cover,
                );
              }
              return Image.asset(
                AppImages.noProfileImg,
                fit: BoxFit.cover,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          _buildSectionHeading(S.of(context).profile.toUpperCase()),
          _buildFirstNameField(),
          _buildLastName(),
          _buildMobileTextField(),
          _buildEmailTextField(),
          _buildDeleteAccount(),
        ],
      ),
    );
  }

  Widget _buildSectionHeading(String title) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      alignment: Alignment.bottomLeft,
      height: 48,
      child: CustomText(
        txtColor: Color(0xFF5c5760),
        txtFontName: AppFonts.montserrat,
        txtFontStyle: FontWeight.w100,
        txtSize: 14,
        txtTitle: title,
        letterSpacing: 1.25,
      ),
    );
  }

  Widget _buildFirstNameField() {
    return _buildProfileCard(
      leftTitle: S.of(context).firstName,
      rightChild: CustomTextFormField(
        hideborder: true,
        enabled: _editingEnabled,
        initialText: _user != null
            ? _user.firstname == null
                ? 'N/A'
                : _user.firstname
            : 'N/A',
        focusNode: _firstNameFocusNode,
        placeHolderText: S.of(context).firstName,
        onSaved: (value) {
          _formData['firstname'] = value;
        },
        onFieldSubmitted: (_) {
          FocusScope.of(context).requestFocus(_lastNameFocusNode);
        },
        textFieldType: TextFieldType.Normal,
        textInputAction: TextInputAction.next,
      ),
    );
  }

  Widget _buildLastName() {
    return _buildProfileCard(
      leftTitle: S.of(context).lastName,
      rightChild: CustomTextFormField(
        hideborder: true,
        enabled: _editingEnabled,
        initialText: _user == null
            ? 'N/A'
            : _user.lastname == null
                ? 'N/A'
                : _user.lastname,
        focusNode: _lastNameFocusNode,
        placeHolderText: S.of(context).lastName,
        onSaved: (value) {
          _formData['lastname'] = value;
        },
        onFieldSubmitted: (_) {
          FocusScope.of(context).requestFocus(_mobileFocusNode);
        },
        textFieldType: TextFieldType.Normal,
        textInputAction: TextInputAction.next,
      ),
    );
  }

  Widget _buildMobileTextField() {
    return _buildProfileCard(
      leftTitle: S.of(context).mobile,
      rightChild: CustomTextFormField(
        hideborder: true,
        enabled: _editingEnabled,
        initialText: _user == null
            ? 'N/A'
            : _user.phone == null
                ? 'N/A'
                : _user.phone,
        focusNode: _mobileFocusNode,
        placeHolderText: S.of(context).mobile,
        onSaved: (value) {
          _formData['phone'] = value;
        },
        textFieldType: TextFieldType.Normal,
        textInputAction: TextInputAction.done,
      ),
    );
  }

  //Email TextField...
  Widget _buildEmailTextField() {
    return _buildProfileCard(
      leftTitle: S.of(context).email,
      rightChild: TextFormField(
        enabled: false,
        initialValue: _user == null
            ? 'N/A'
            : _user.email == null
                ? 'N/A'
                : _user.email,
        maxLines: null,
        decoration: customTxtInputDecoration(
            text: S.of(context).email, hideBorder: true),
      ),
    );
  }

  Widget _buildDeleteAccount() {
    return Consumer<UserProvider>(
      builder: (ctx, userProvider, child) {
        return GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (ctx) {
                return AlertDialog(
                  title: Text('Delete Account'),
                  content: Text('Do you really want to delete this account?'),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('No'),
                      onPressed: () async {
                        bool isDeleted =
                            await userProvider.deleteAccount(context: context);
                        if (isDeleted) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                    FlatButton(
                      child: Text('Yes'),
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (ctx) => MainAuthScreen(),
                              fullscreenDialog: true),
                        );
                      },
                    ),
                  ],
                );
              },
            );
          },
          child: Container(
            padding: EdgeInsets.only(top: 32),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.centerLeft,
              color: Colors.white,
              height: 57.0,
              child: CustomText(
                txtColor: Theme.of(context).errorColor,
                txtFontName: AppFonts.montserrat,
                txtFontStyle: FontWeight.normal,
                txtTitle: S.of(context).deleteAccount,
                txtSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }

  //Commonly used widgets

  Widget _buildProfileCard({
    @required String leftTitle,
    @required Widget rightChild,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: CustomText(
                    align: TextAlign.start,
                    txtColor: Colors.black,
                    txtFontName: AppFonts.montserrat,
                    txtFontStyle: FontWeight.w500,
                    txtSize: 14,
                    txtTitle: leftTitle,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: rightChild,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void onThemeChanged(
      BuildContext context, bool value, ThemeNotifier themeNotifier) async {
    value
        ? themeNotifier.setTheme(darkTheme)
        : themeNotifier.setTheme(lightTheme);
    print('dark theme $value');
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkMode', value);
  }

  void _showMaterialDialog(context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure?'),
          actions: <Widget>[
            FlatButton(
              textColor: Theme.of(context).accentColor,
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            Consumer<AuthProvider>(
              builder: (c1, authProvider, child) {
                return FlatButton(
                  textColor: Theme.of(context).accentColor,
                  child: child,
                  onPressed: () {
                    authProvider.logout().then(
                      (_) {
                        Navigator.of(context).pop();
                        Scaffold.of(context).openEndDrawer();
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            HomeScreen.routeName,
                            ((Route<dynamic> route) => false));
                        Provider.of<RecipesProvider>(context).removeAllSL();

                        Scaffold.of(context).showSnackBar(
                          SnackBar(
                            duration: Duration(milliseconds: 900),
                            content: Text('Logout successfully.'),
                          ),
                        );
                      },
                    );
                  },
                );
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

//  Widget _showActionSheet() {
//    return CupertinoActionSheet(
//      // title: Text(''),
//      actions: <Widget>[
//        CupertinoActionSheetAction(
//          child: Text('Take Photo'),
//          onPressed: () {
//            Navigator.of(context).pop();
//            pickImage(ImageSource.camera);
//          },
//        ),
//        CupertinoActionSheetAction(
//          child: Text('Choose Photo'),
//          onPressed: () {
//            Navigator.of(context).pop();
//            pickImage(ImageSource.gallery);
//          },
//        ),
//      ],
//      cancelButton: CupertinoActionSheetAction(
//        child: Text('Cancel'),
//        onPressed: () {
//          Navigator.of(context).pop();
//        },
//      ),
//    );
//  }
//
//  pickImage(ImageSource source) async {
//    // var image = await ImagePicker.pickImage(source: source);
//    setState(() {
//      imagePickerFile = ImagePicker.pickImage(source: source);
//    });
//  }
}
