import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pothole/constants.dart';
import 'package:pothole/screens/files_view.dart';
import 'package:pothole/screens/googlemaps_view.dart';
import 'package:pothole/screens/sensors_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _current = 1;
  bool? recording;

  @override
  initState() {
    super.initState();
    setRecording();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: _appBar(),
        bottomNavigationBar: _buttomNavBar(),
        body: buildBody,
      ),
    );
  }

  get buildBody {
    //While recording we shouldn't be able to change page because it causes some errors
    setRecording();
    if (recording == true) {
      _current = 1;
      return Sensors();
    } else {
      if (_current == 0) return GoogleMapsView();
      if (_current == 1) return Sensors();
      if (_current == 2) return FilesView();
    }
  }

  BottomNavigationBar _buttomNavBar() {
    return BottomNavigationBar(
      currentIndex: _current,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.map), label: "map"),
        BottomNavigationBarItem(icon: Icon(Icons.sensors), label: "record"),
        BottomNavigationBarItem(icon: Icon(Icons.folder), label: "files")
      ],
      elevation: 15,
      selectedIconTheme: IconThemeData(size: 25, opacity: 0.8),
      iconSize: 25,
      unselectedIconTheme: IconThemeData(size: 20, opacity: 0.5),
      onTap: (index) {
        setState(() {
          _current = index;
        });
      },
    );
  }

  AppBar _appBar() {
    return AppBar(
      elevation: 20,
      systemOverlayStyle:
          SystemUiOverlayStyle(statusBarColor: Colors.transparent),
      centerTitle: true,
      title: Text(
        Constant.appBarText,
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.teal, Colors.blueGrey])),
      ),
    );
  }

  Future<void> setRecording() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      recording = prefs.getBool("recording");
    });
  }
}
