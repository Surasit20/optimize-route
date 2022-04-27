import 'package:flutter/foundation.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Directions {
  final LatLngBounds bounds;
  final List<PointLatLng> polylinePoints;
  final String textDistance;
  final String textDuration;
  final int valDistance;
  final int valDuration;

  const Directions(
      {required this.bounds,
      required this.polylinePoints,
      required this.textDistance,
      required this.textDuration,
      required this.valDistance,
      required this.valDuration});

  factory Directions.fromMap(Map<String, dynamic> map) {
    // Check if route is not available
    if ((map['routes'] as List).isEmpty) {
      return throw ArgumentError('Data is null');
    }

    // Get route information
    final data = Map<String, dynamic>.from(map['routes'][0]);

    // Bounds
    final northeast = data['bounds']['northeast'];
    final southwest = data['bounds']['southwest'];
    final bounds = LatLngBounds(
      northeast: LatLng(northeast['lat'], northeast['lng']),
      southwest: LatLng(southwest['lat'], southwest['lng']),
    );

    // Distance & Duration
    String text_Distance = '';
    String text_Duration = '';
    int val_Distance = 0;
    int val_Duration = 0;
    if ((data['legs'] as List).isNotEmpty) {
      final leg = data['legs'][0];
      text_Distance = leg['distance']['text'];
      text_Duration = leg['duration']['text'];
      val_Distance = leg['distance']['value'];
      val_Duration = leg['duration']['value'];
    }

    return Directions(
        bounds: bounds,
        polylinePoints: PolylinePoints()
            .decodePolyline(data['overview_polyline']['points']),
        textDistance: text_Distance,
        textDuration: text_Duration,
        valDistance: val_Distance,
        valDuration: val_Duration);
  }
}
