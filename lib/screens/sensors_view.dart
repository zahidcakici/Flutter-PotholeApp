import 'dart:async';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:motion_sensors/motion_sensors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pothole/constants.dart';
import 'package:pothole/service/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

class Sensors extends StatefulWidget {
  const Sensors({Key? key}) : super(key: key);

  @override
  _SensorsState createState() => _SensorsState();
}

class _SensorsState extends State<Sensors> {
  bool isRecoding = false;
  Vector3 _accelerometer = Vector3.zero();
  Vector3 _gyroscope = Vector3.zero();
  Vector3 _magnetometer = Vector3.zero();
  Vector3 _userAccelerometer = Vector3.zero();
  Vector3 _vertical = Vector3.zero();
  List<double>? _latlong;
  List<int> _time = [0, 0];
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];
  List<List<dynamic>> recordingList = [];
  StopWatchTimer? _stopWatchTimer;

  @override
  void initState() {
    super.initState();
    //Set headers
    recordingList.add(Constant.headers);
    //Update sensors interval as 5hz
    updateInterval(Constant.interval);
    //Get user permission if hasn't got before and assign _latlong as current position
    LocationHandler.handlePermission()
        .then((value) => _latlong = <double>[value.latitude, value.longitude]);

    //Create sensors streams
    _createSubscriptions();

    //Init stopwatch to count up
    _initStopWatch();
  }

  @override
  void dispose() {
    super.dispose();
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  StopWatchTimer _initStopWatch() {
    return _stopWatchTimer = StopWatchTimer(
      mode: StopWatchMode.countUp,
      onChangeRawSecond: (value) {
        setState(() {
          _time[1] = value;
        });
      },
      onChangeRawMinute: (value) {
        setState(() {
          _time[0] = value;
        });
      },
    );
  }

  void _createSubscriptions() {
    _streamSubscriptions
        .add(Geolocator.getPositionStream().listen((Position event) {
      setState(() {
        _latlong = <double>[event.latitude, event.longitude];
      });
    }));
    _streamSubscriptions
        .add(motionSensors.gyroscope.listen((GyroscopeEvent event) {
      setState(() {
        _gyroscope.setValues(event.x, event.y, event.z);
      });
    }));
    _streamSubscriptions.add(motionSensors.magnetometer.listen((event) {
      setState(() {
        _magnetometer.setValues(event.x, event.y, event.z);
      });
    }));
    _streamSubscriptions.add(motionSensors.userAccelerometer.listen((event) {
      setState(() {
        _userAccelerometer.setValues(event.x, event.y, event.z);
      });
    }));
    _streamSubscriptions
        .add(motionSensors.accelerometer.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometer.setValues(event.x, event.y, event.z);
      });
      var matrix = motionSensors.getRotationMatrix(
          _accelerometer - _userAccelerometer, _magnetometer);
      _vertical = matrix * _userAccelerometer;
      if (isRecoding) {
        recordingList.add(<dynamic>[
          DateTime.now(),
          _gyroscope[0],
          _gyroscope[1],
          _gyroscope[2],
          event.x,
          event.y,
          event.z,
          _latlong![0],
          _latlong![1],
          _vertical[2]
        ]);
      }
    }));
    setState(() {
      updateInterval(Constant.interval);
      pauseSubscriptions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Constant.nearlyWhite,
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
              child: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Colors.tealAccent, Colors.teal],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter)),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(50.0),
                      child: Text(
                        buildTime,
                        style: TextStyle(
                          fontSize: 50,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            buildActionButton(),
            buildProgress()
          ],
        )),
      ),
    );
  }

  buildProgress() {
    return isRecoding ? CircularProgressIndicator() : Icon(Icons.check);
  }

  FloatingActionButton buildActionButton() {
    return isRecoding
        ? FloatingActionButton.extended(
            onPressed: saveData,
            label: Text("Stop"),
            icon: Icon(Icons.stop),
          )
        : FloatingActionButton.extended(
            onPressed: saveData,
            label: Text("Start"),
            icon: Icon(Icons.sensors),
          );
  }

  String get buildTime {
    String sec = _time[1] < 10 ? "0${_time[1]}" : "${_time[1]}";
    String min = _time[0] < 10 ? "0${_time[0]}" : "${_time[0]}";
    return min + "." + sec;
  }

  Future<void> saveData() async {
    setState(() {
      isRecoding = !isRecoding;
    });
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("recording", isRecoding);
    if (isRecoding) {
      _stopWatchTimer!.onExecute.add(StopWatchExecute.start);
      resumeSubscriptions();
    } else {
      _stopWatchTimer!.onExecute.add(StopWatchExecute.reset);
      pauseSubscriptions();
      saveFile();
    }
  }

  void pauseSubscriptions() {
    for (final subscription in _streamSubscriptions) {
      subscription.pause();
    }
  }

  void resumeSubscriptions() {
    for (final subscription in _streamSubscriptions) {
      subscription.resume();
    }
  }

  void updateInterval(int interval) {
    motionSensors.accelerometerUpdateInterval = interval;
    motionSensors.userAccelerometerUpdateInterval = interval;
    motionSensors.gyroscopeUpdateInterval = interval;
    motionSensors.magnetometerUpdateInterval = interval;
  }

  Future<void> saveFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = dir.path + "/records";

    final filename = DateTime.now()
            .toString()
            .replaceAll(" ", "-")
            .replaceAll(":", "-")
            .split(".")[0] +
        ".csv";
    String csv = const ListToCsvConverter().convert(recordingList);
    File myFile = await new File("$path/$filename").create(recursive: true);
    await myFile.writeAsString(csv);
  }
}
