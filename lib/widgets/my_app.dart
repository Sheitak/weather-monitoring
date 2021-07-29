import 'package:flutter/material.dart';
import 'package:weather_monitoring/widgets/home.dart';

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather Monitoring',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new Home(title: 'Weather Monitoring'),
      debugShowCheckedModeBanner: false,
    );
  }
}