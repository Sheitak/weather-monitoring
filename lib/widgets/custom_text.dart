import 'package:flutter/material.dart';

class CustomText extends Text {
  CustomText(String data,
      {color: Colors.white,
      fontSize: 18.0,
      fontStyle: FontStyle.italic,
      textAlign: TextAlign.center})
      : super(data,
            textAlign: textAlign,
            style: new TextStyle(
                color: color, fontStyle: fontStyle, fontSize: fontSize));
}
