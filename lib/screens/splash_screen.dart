import 'package:flutter/material.dart';
import 'package:pothole/constants.dart';

import 'main.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    //After 2 sec go to HomePage
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            alignment: Alignment.topCenter,
            margin: EdgeInsets.only(top: 130),
            child: Text(
              Constant.splashText,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
            ),
          ),
          Center(
            child: Image.asset(
              Constant.splashAsset,
              color: Colors.teal,
            ),
          ),
        ],
      ),
    );
  }
}
