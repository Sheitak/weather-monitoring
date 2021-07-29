import 'package:flutter/material.dart';
import 'package:weather_monitoring/widgets/custom_text.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Center(
        child: new CustomText(
          "Loading...",
          color: Colors.blue,
          fontStyle: FontStyle.italic,
          fontSize: 30.0,
        )
    );
  }
}