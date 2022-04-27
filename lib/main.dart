import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:stp_map/model_directios.dart';
import 'package:stp_map/directions_repository.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(title: 'Flutter Demo GPS saleman'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _initalCareraPosition = CameraPosition(
      target: LatLng(13.875119978758672, 100.5693624445351), zoom: 15);

  late GoogleMapController _googleMapController;

  List<Marker> _listMarker = [];

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Stack(children: [
        GoogleMap(
          initialCameraPosition: _initalCareraPosition,
          myLocationEnabled: true,
          zoomControlsEnabled: true,
          onMapCreated: (controller) => _googleMapController = controller,
          markers: Set<Marker>.of(_listMarker),
          onTap: _addMarker,
          /*polylines: {
              if (distance != null)
                Polyline(
                  polylineId: const PolylineId('overview_polyline'),
                  color: Colors.red,
                  width: 5,
                  points:  distance.polylinePoints.map((e) => LatLng(e.latitude, e.longitude))
                      
                      .toList(),
                ),
                
            },*/
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 0, 100),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: FloatingActionButton(
              onPressed: optimizeRoute,
              backgroundColor: Colors.blueAccent,
              child: const Icon(Icons.navigation),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 0, 30),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  _listMarker = [];
                });
              },
              backgroundColor: Colors.red,
              child: const Icon(Icons.clear_rounded),
            ),
          ),
        ),
      ]),
    );
  }

  void _addMarker(LatLng pos) {
    var markerIdVal = _listMarker.length + 1;
    String mar = markerIdVal.toString();
    final MarkerId markerId = MarkerId(mar);
    final Marker marker = Marker(
        markerId: markerId,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        position: pos);

    setState(() {
      _listMarker.add(marker);
    });
  }

  Future<Directions> directions(Marker start, Marker end) async {
    var data = await DirectionsRepository()
        .getDirections(start: start.position, end: end.position);

    return data;
  }

  Future<void> optimizeRoute() async {
    var matrixDistance = [];
    final n = _listMarker.length;
    var temp;

    //create matrix distance
    for (int i = 0; i < n; i++) {
      List _tempMatrix = [];
      for (int j = 0; j < n; j++) {
        temp = await directions(_listMarker[i], _listMarker[j]);
        _tempMatrix.add(temp!.valDistance);
      }
      matrixDistance.add(_tempMatrix);
      print(_tempMatrix);
    }

    var minMatrix = matrixDistance;
    var tempIndex = [0];
    int index, min;
    var total = 0;
    var count = 0;
    final travelled = pow(10, 10);
    for (int i = 0; i < n - 1; i++) {
      minMatrix[count][count] = travelled;
      min = minMatrix[count].reduce((curr, next) => curr < next ? curr : next);

      index = matrixDistance[count].indexOf(min);

      if (tempIndex.contains(index)) {
        minMatrix[count][index] = travelled;
        while (true) {
          min = minMatrix[count]
              .reduce((curr, next) => curr < next ? curr : next);
          index = matrixDistance[count].indexOf(min);
          if (!tempIndex.contains(index)) {
            count = index;
            tempIndex.add(index);
            total = total + min;
            break;
          } else {
            minMatrix[count][index] = travelled;
          }
        }
      } else {
        count = index;
        tempIndex.add(index);
        total = total + min;
      }
    }

    String travelling = "";
    for (int i = 0; i < n; i++) {
      travelling += "${tempIndex[i]} -> ";
    }
    travelling += " 0";
    print(travelling);
    print(total);
  }
}
