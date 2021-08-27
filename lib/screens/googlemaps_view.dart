import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pothole/models/marker_model.dart';
import 'package:pothole/service/location.dart';
import 'package:pothole/service/network.dart';

class GoogleMapsView extends StatefulWidget {
  GoogleMapsView({Key? key}) : super(key: key);
  @override
  State<GoogleMapsView> createState() => GoogleMapsViewState();
}

class GoogleMapsViewState extends State<GoogleMapsView> {
  Completer<GoogleMapController> _controller = Completer();
  List<MarkerModel> mMarkers = [];
  static LatLng? _latlong; //Initial location

  @override
  void initState() {
    super.initState();
    //set _latlong as current position
    setCurrentPos();
    //init map after creation
    Future.microtask(() => initMap());
  }

  void setCurrentPos() {
    LocationHandler.handlePermission().then((value) {
      setState(() {
        _latlong = LatLng(value.latitude, value.longitude);
      });
    });
  }

  Set<Marker> myMarkers() {
    return mMarkers
        .map<Marker>((e) => Marker(
            markerId: MarkerId(e.hashCode.toString()),
            position: LatLng(e.lat, e.long),
            zIndex: 10,
            icon: BitmapDescriptor.defaultMarkerWithHue(e.label == 1
                ? BitmapDescriptor.hueRed
                : BitmapDescriptor.hueBlue)))
        .toSet();
  }

  @override
  Widget build(BuildContext context) {
    return _latlong == null
        ? MapLoading()
        : Stack(children: [
            GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition:
                  CameraPosition(target: _latlong!, zoom: 19),
              onMapCreated: (GoogleMapController controller) {
                setState(() {
                  _controller.complete(controller);
                });
              },
              markers: myMarkers(),
            ),
            Align(
              alignment: Alignment(0.0, 0.9),
              child: FloatingActionButton(
                  onPressed: _goToCurrentPos, child: Icon(Icons.where_to_vote)),
            ),
          ]);
  }

  Future<void> _goToCurrentPos() async {
    final GoogleMapController controller = await _controller.future;
    setCurrentPos();
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: _latlong!, zoom: 19)));
  }

  Future initMap() async {
    try {
      final res = await NetworkHandler.getMarkers();
      final jsonData = json.decode(res.body)["markers"];
      var response;
      if (jsonData is List) {
        setState(() {
          mMarkers = jsonData
              .map((e) => MarkerModel.fromJson(e))
              .cast<MarkerModel>()
              .toList();
        });
      } else if (jsonData is Map) {
      } else {
        return response;
      }
    } catch (e) {
      print(e);
    }
  }
}

class MapLoading extends StatelessWidget {
  const MapLoading({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [CircularProgressIndicator(), Text("Loading map...")],
        ),
      ),
    );
  }
}
