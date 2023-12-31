// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mausam/weatherPage.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyApp();
}

class _MyApp extends State {
  var y = -4.0;
  @override
  void initState() {
    super.initState();
    Timer(
      Duration(seconds: 3),
      () {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => WeatherPage(),
            ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Color.fromRGBO(135, 206, 235, 1),
      child: Center(
          child: Column(
        children: [
          SizedBox(height: 120),
          Image.asset(
            "assets/icons/appIcon.png",
            scale: 3,
          ),
          Text(
            "Mausam",
            style: TextStyle(
                color: Color.fromRGBO(0, 26, 255, 1),
                fontSize: 90,
                fontFamily: "EBGaramontEb"),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Developed by",
                style: TextStyle(fontSize: 20, fontFamily: "EBGaramontRg"),
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                "PRAMOD PANDIT",
                style: TextStyle(fontSize: 23, fontFamily: "EBGaramontEb"),
              ),
            ],
          )
        ],
      )),
    );
  }
}
