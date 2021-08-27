import 'package:flutter/material.dart';
import 'package:pothole/constants.dart';
import 'package:pothole/screens/splash_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Constant.mainColor),
      //First goes to splash screen for 2 sec
      home: Splash(),
    );
  }
}
