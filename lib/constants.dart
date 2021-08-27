import 'package:flutter/material.dart';

class Constant {
  //Splash
  static const splashText = "Pothole Detection";
  static const splashAsset = 'assets/pothole.png';
  //Main
  static const appBarText = "ANKA GEO";
  static const mainColor = Colors.teal;
  //Sensors
  static const interval = Duration.microsecondsPerSecond ~/ 1;
  static const List<dynamic> headers = [
    "Timestamp",
    "Gx",
    "Gy",
    "Gz",
    "Ax",
    "Ay",
    "Az",
    "Lat",
    "Long",
    "Vertical"
  ];
  //NetworkService
  static const baseUrlEmulator = "http://10.0.2.2:5000/";
  static const baseUrlLocal = "http://localhost:5000/";

  //Colors
  static const Color notWhite = Color(0xFFEDF0F2);
  static const Color nearlyWhite = Color(0xFFFEFEFE);
  static const Color card = Color(0xFFFEFEFE);
}
