import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stp_map/model_directios.dart';
import 'package:stp_map/directions_repository.dart';
import 'dart:math';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:label_marker/label_marker.dart';

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

  List<Directions>? _info;
  Set<Polyline> _polylines = {};
  List<Directions> _allPath = [];
  Set<Marker> _setMarker = {};
  List<Marker> _listMarker = [];
  final a = 2;
  int tempIndex = 0;
  late int total = 0;
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
          markers: Set<Marker>.of(_setMarker),
          onTap: _addMarker,
          polylines: Set<Polyline>.of(_polylines),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 0, 100),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: FloatingActionButton(
              onPressed: cratePolyline,
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
                  _polylines = {};
                  total = 0;
                  _setMarker = {};
                });
              },
              backgroundColor: Colors.red,
              child: const Icon(Icons.clear_rounded),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: 250.0,
              height: 50.0,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 5, 58, 7),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              ),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'ระยะทาง : ${total / 1000} กิโลเมตร',
                  style: const TextStyle(
                    fontSize: 17.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 75),
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: 250.0,
              height: 50.0,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 5, 58, 7),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              ),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'เส้นทางที่ควรไป : ${tempIndex} ',
                  style: const TextStyle(
                    fontSize: 17.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  void _addMarker(LatLng pos) {
    var markerIdVal = _listMarker.length + 1;
    print(markerIdVal);
    String mar = markerIdVal.toString();
    final MarkerId markerId = MarkerId(mar);
    final Marker marker = Marker(
        markerId: markerId,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        position: pos);

    setState(() {
      _listMarker.add(marker);
      _setMarker.add(marker);
    });
  }

  Future<Directions> directions(Marker start, Marker end) async {
    Directions data = await DirectionsRepository()
        .getDirections(start: start.position, end: end.position);

    return data;
  }

  Future<void> cratePolyline() async {
    dynamic data = await optimizeRoute();
    List indexSort = data["sortpathindex"];
    List listpolyline = data["allpath"];

    setState(() {
      total = data["total"];
    });
    Polyline polyline;
    Set<Polyline> tempPolylines = {};
    int prv = 0;

    for (int i = 0; i < indexSort.length - 1; i++) {
      if (i == indexSort.length - 2) {
        print("hello");
        List<PointLatLng> test = listpolyline[indexSort[i]][indexSort[i + 1]];
        polyline = Polyline(
            polylineId: PolylineId("poly $i"),
            color: Color.fromARGB(204, 147, 70, 140),
            width: 6,
            points: test.map((e) => LatLng(e.latitude, e.longitude)).toList());

        setState(() {
          _polylines.add(polyline);
          _setMarker.addLabelMarker(LabelMarker(
            label: "${i + 1}",
            markerId: MarkerId("idString $i"),
            position: LatLng(_listMarker[indexSort[i]].position.latitude,
                _listMarker[indexSort[i]].position.longitude),
            backgroundColor: Colors.green,
          ));

          _setMarker.addLabelMarker(LabelMarker(
            label: "${i + 2}",
            markerId: MarkerId("idString $i+1"),
            position: LatLng(_listMarker[indexSort[i + 1]].position.latitude,
                _listMarker[indexSort[i + 1]].position.longitude),
            backgroundColor: Colors.green,
          ));
        });

        break;
      }
      print("hello0");
      List<PointLatLng> test = listpolyline[indexSort[i]][indexSort[i + 1]];
      polyline = Polyline(
          polylineId: PolylineId("poly $i"),
          color: Color.fromARGB(204, 147, 70, 140),
          width: 6,
          points: test.map((e) => LatLng(e.latitude, e.longitude)).toList());

      setState(() {
        _polylines.add(polyline);
        _setMarker.addLabelMarker(LabelMarker(
          label: "${i + 1}",
          markerId: MarkerId("idString $i"),
          position: LatLng(_listMarker[indexSort[i]].position.latitude,
              _listMarker[indexSort[i]].position.longitude),
          backgroundColor: Colors.green,
        ));
      });
    }
  }

  Future<dynamic> optimizeRoute() async {
    var matrixDistance = [];
    var dummyDistance = [];
    var tempAllPath = [];
    final n = _listMarker.length;
    Directions temp;
    List<PointLatLng> sd;

    //create matrix distance
    for (int i = 0; i < n; i++) {
      List tempMatrix_ = [];
      List tempAllPath_ = [];
      for (int j = 0; j < n; j++) {
        temp = await directions(_listMarker[i], _listMarker[j]);
        tempMatrix_.add(temp.valDistance);
        tempAllPath_.add(temp.polylinePoints);
      }
      matrixDistance.add(tempMatrix_);
      dummyDistance.add(tempMatrix_.toList());
      tempAllPath.add(tempAllPath_);
    }
    var tempIndex = [0];
    int index, min;
    var total = 0;
    var count = 0;

    for (int i = 0; i < n - 1; i++) {
      dummyDistance[count].sort();
      min = dummyDistance[count][1];
      index = matrixDistance[count].indexOf(min);
      if (tempIndex.contains(index)) {
        int sortIndex = 2;
        while (true) {
          min = dummyDistance[count][sortIndex];
          index = matrixDistance[count].indexOf(min);
          if (!tempIndex.contains(index)) {
            count = index;
            tempIndex.add(index);
            total = total + min;
            break;
          } else {
            sortIndex += 1;
          }
        }
      } else {
        count = index;
        tempIndex.add(index);
        total = total + min;
      }
    }
    setState(() {
      tempIndex = tempIndex;
    });

    String travelling = "";
    for (int i = 0; i < n; i++) {
      travelling += "${tempIndex[i]} -> ";
    }
    travelling += " 0";
    print(travelling);
    print(total / 1000);

    dynamic databestpath = {
      "total": total,
      "sortpathindex": tempIndex,
      "allpath": tempAllPath,
      "tempIndex": tempIndex,
    };
    return databestpath;
  }
}
