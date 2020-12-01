import 'package:flutter/material.dart';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:intl/intl.dart';
import 'package:recipe_flutter_provider/locale/app_localization.dart';

import './static_string.dart';

enum CustomDialogType {
  Error,
  Success,
  NoInternet,
}

class SubscriptionDialog extends StatelessWidget {
  final String titleM,
      titleY,
      currency,
      priceM,
      priceY,
      priceOffM,
      priceOffY,
      descriptionM,
      descriptionY,
      buttonText;
  final CustomDialogType alertType;
  final Function onTapM;
  final Function onTapY;

  SubscriptionDialog({
    @required this.titleM,
    @required this.priceM,
    this.priceOffM = "",
    @required this.descriptionM,
    this.onTapM,
    @required this.titleY,
    @required this.priceY,
    this.priceOffY = "",
    @required this.descriptionY,
    this.onTapY,
    this.alertType = CustomDialogType.Success,
    @required this.currency,
    @required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Consts.padding),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        //...buttom card part
        Container(
          padding: EdgeInsetsDirectional.only(
            top: Consts.avatarRadius + Consts.padding,
            bottom: Consts.padding,
            start: Consts.padding,
            end: Consts.padding,
          ),
          margin: EdgeInsets.only(top: Consts.avatarRadius),
          decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(Consts.padding),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildTitle(titleM),
              SizedBox(height: 15.0),
              _buildPrice(context, currency, priceM, priceOffM),
              SizedBox(height: 15.0),
              _buildContent(descriptionM),
              Align(
                alignment: Alignment.center,
                child: FlatButton(
                  child: Text(buttonText),
                  color: Colors.greenAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    onTapM();
                  },
                ),
              ),
              SizedBox(height: 15.0),
              Divider(
                height: 5,
                color:
                    Theme.of(context).textTheme.subtitle.color.withOpacity(0.8),
              ),
              SizedBox(height: 15.0),
              _buildTitle(titleY),
              SizedBox(height: 15.0),
              _buildPrice(context, currency, priceY, priceOffY),
              SizedBox(height: 15.0),
              _buildContent(descriptionY),
              Align(
                alignment: Alignment.center,
                child: FlatButton(
                  child: Text(buttonText),
                  color: Colors.greenAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    onTapY();
                  },
                ),
              ),
              SizedBox(height: 15.0),
              
            ],
          ),
        ),
        Positioned(
          left: Consts.padding,
          right: Consts.padding,
          child: CircleAvatar(
            backgroundColor: alertType == CustomDialogType.Error
                ? Colors.redAccent
                : Colors.blueAccent,
            radius: Consts.avatarRadius,
            child: Icon(
              alertType == CustomDialogType.Error
                  ? MdiIcons.alert
                  : alertType == CustomDialogType.NoInternet
                      ? MdiIcons.wifiStrength1Alert
                      : MdiIcons.cash,
              color: Colors.white,
              size: 40,
            ),
            // backgroundImage: image,
          ),
        ),
      ],
    );
  }
}

_buildTitle(String title) {
  return Text(title,
      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700),
      textAlign: TextAlign.center);
}

_buildPrice(BuildContext context, String currency, String price, String off) {
  var oCcy = new NumberFormat("#,##0.00", "en_US");
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
          "${S.of(context).price}: $currency ${oCcy.format(double.parse(price))}",
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center),
      off == ""
          ? Container()
          : Text("(-$off%)",
              style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w700,
                  color: Colors.greenAccent)),
    ],
  );
}

_buildContent(String content) {
  return Text(content,
      style: TextStyle(
        fontSize: 15.0,
        fontWeight: FontWeight.w300,
      ),
      textAlign: TextAlign.center);
}

class Consts {
  Consts._();

  static const double padding = 10.0;
  static const double avatarRadius = 45.0;
}
