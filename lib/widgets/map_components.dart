import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mvvm_playground/const/strings.dart';
import 'package:mvvm_playground/const/theme.dart';
import 'package:mvvm_playground/features/models/tree_model.dart';

Widget mapTiles(BuildContext context) {
  return TileLayer(
    urlTemplate: mapUrl,
    errorTileCallback: (context, exception, stackTrace) {
      print('Error loading tile: $exception');
      Container(
        color: Colors.red,
        child: const Center(
          child: Text(
            'Tile Load Error',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    },
  );
}

List<Polyline> mapPolyline({required List<dynamic> routes}) {
  return [
    Polyline(
      points: routes.map((route) => route.position as LatLng).toList(),
      color: Colors.green,
      strokeWidth: 3,
      isDotted: false,
      useStrokeWidthInMeter: true,
    )
  ];
}

Marker userMarker({required LatLng position}) {
  return Marker(
      point: position,
      child: Container(
        decoration: const ShapeDecoration(
            shape: CircleBorder(),
            shadows: [
              BoxShadow(
                color: Colors.black12,
                spreadRadius: 3,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
            color: Colors.white),
        child: const Icon(
          Icons.circle,
          color: secondaryColor,
        ),
      ));
}

CircleMarker circleMarkerOverlays(
    {required LatLng position, required double radius, Color? color}) {
  return CircleMarker(
      point: position,
      color: color ?? Colors.blue.withOpacity(0.3),
      radius: radius,
      useRadiusInMeter: true);
}

Marker treeMarker({required Tree tree}) {
  return Marker(
    width: 300.0,
    height: 300.0,
    point: tree.position,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          child: Container(
            padding: const EdgeInsets.all(1),
            decoration: const ShapeDecoration(
                shape: CircleBorder(),
                shadows: [
                  BoxShadow(
                    color: Colors.black12,
                    spreadRadius: 3,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
                color: Colors.white),
            child:
                Image.asset('assets/icons/go-harvest-assets.png', height: 30),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  spreadRadius: 3,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
              color: primaryColor),
          child: Text(
            tree.name,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white),
          ),
        )
      ],
    ),
  );
}
