import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:mvvm_playground/functions/geolocation.dart';
import 'package:mvvm_playground/widgets/typography.dart';

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
          displayText('Lat : ${pos.latitude}'),
          const SizedBox(
            width: 8,
          ),
          displayText('Long : ${pos.longitude}'),
          const SizedBox(
            width: 8,
          ),
          displayText('isInRange : ${geolocation.status.contains(true)}'),
        ],
      ),
    ),
  );
}
