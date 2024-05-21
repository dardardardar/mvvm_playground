import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:mvvm_playground/functions/geolocation.dart';

Widget debugBar(
    {required GeoLocation geolocation,
    required LatLng pos,
    required bool visible}) {
  return Visibility(
    visible: visible,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        children: [
          Text('Lat : ${pos.latitude}'),
          const SizedBox(
            width: 8,
          ),
          Text('Long : ${pos.longitude}'),
          const SizedBox(
            width: 8,
          ),
          Text('isInRange : ${geolocation.status.contains(true)}'),
        ],
      ),
    ),
  );
}
