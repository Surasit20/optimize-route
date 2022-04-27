import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

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
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: FloatingActionButton(
            onPressed: matrixDistance,
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _listMarker = [];
          });
        },
      ),
    );
  }
 //sawad d cub
  void _addMarker(LatLng pos) {
    var markerIdVal = _listMarker.length + 1;
    String mar = markerIdVal.toString();
    final MarkerId markerId = MarkerId(mar);
    final Marker marker = Marker(markerId: markerId, position: pos);
    setState(() {
      _listMarker.add(marker);
    });
  }

  Future<Map> distance(Marker start, Marker end) async {
    final data = await DirectionsRepository()
        .getDirections(origin: start.position, destination: end.position);

    var routes = data["routes"];
    routes = routes[0];
    var legs = routes["legs"];
    var distance = legs[0];
    return distance["distance"];
  }

  Future<void> matrixDistance() async {
    final _matrix = [];
    final n = _listMarker.length;

    var temp;
    for (int i = 0; i < n; i++) {
      List _tempMatrix = [];
      for (int j = 0; j < n; j++) {
        temp = await distance(_listMarker[i], _listMarker[j]);
        _tempMatrix.add(temp["value"]);
      }
      _matrix.add(_tempMatrix);
      print(_tempMatrix);
      print(_tempMatrix);
    }

    var dummy = _matrix;
    final row = _matrix;

    final tempIndex = [0];
    var _index, _min;
    int count = 0;

    for (int i = 0; i < n - 1; i++) {
      final rowmatrix = row[count];
      rowmatrix[count] = 9999999999999;
      List dummyMatrix = dummy[count];

      _min = rowmatrix.reduce((curr, next) => curr < next ? curr : next);
      _index = dummyMatrix.indexOf(_min);

      if (tempIndex.contains(_index)) {
        rowmatrix[_index] = 9999999999999;
        while (true) {
          _min = rowmatrix.reduce((curr, next) => curr < next ? curr : next);
          _index = dummyMatrix.indexOf(_min);
          if (!tempIndex.contains(_index)) {
            count = _index;
            tempIndex.add(_index);
            break;
          } else {
            rowmatrix[_index] = 9999999999999;
          }
        }
      } else {
        count = _index;
        tempIndex.add(_index);
      }
    }

    String travelling = "";
    for (int i = 0; i < n; i++) {
      travelling += "${tempIndex[i]} -> ";
    }
    travelling += " 0";
    print(travelling);
  }
}
