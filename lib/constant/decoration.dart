import 'package:flutter/material.dart';

LinearGradient setGradiantColor(
    {Color topColor, Color bottomColor, List<double> stops}) {
  return LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.09, 0.99],
    colors: [topColor, bottomColor],
  );
}

//Set Card Shadow...
BoxDecoration cardDecoration({@required BuildContext context, double radius = 3}) {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(5.0),
    color: Theme.of(context).primaryColor,
    boxShadow: [
      BoxShadow(
        blurRadius: radius,
        spreadRadius: 3,
        color: Theme.of(context).textTheme.body1.shadows.first.color, //Colors.grey.withOpacity(0.2),
      )
    ],
  );
}

InputDecoration contactUsTextDecoration({@required BuildContext context, String text, String font}) {
  return InputDecoration(
    hintStyle: TextStyle(
        color: Theme.of(context).textTheme.subtitle.color,
        fontWeight: FontWeight.w100,
        fontFamily: font,
        fontSize: 17),
    hintText: text,
    enabledBorder:
        UnderlineInputBorder(borderSide: BorderSide(style: BorderStyle.none)),
    focusedBorder:
        UnderlineInputBorder(borderSide: BorderSide(style: BorderStyle.none)),
  );
}


//Set Special Recipe Today Decoration...
BoxDecoration srtDecoration({@required BuildContext context, double radius = 3}) {
  return BoxDecoration(
    // borderRadius: BorderRadius.circular(5.0),
    color: Theme.of(context).primaryColor,
    border: Border(
      left: BorderSide(color: Theme.of(context).accentColor, width: 5),
      right: BorderSide(color: Theme.of(context).accentColor, width: 5),
    ),
    boxShadow: [
      BoxShadow(
        blurRadius: radius,
        spreadRadius: 3,
        color: Theme.of(context).textTheme.body1.shadows.first.color, //Colors.grey.withOpacity(0.2),
      )
    ],
  );
}