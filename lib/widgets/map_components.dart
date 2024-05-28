import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mvvm_playground/const/enums.dart';
import 'package:mvvm_playground/const/strings.dart';
import 'package:mvvm_playground/const/theme.dart';
import 'package:mvvm_playground/features/models/tree_model.dart';
import 'package:mvvm_playground/functions/functions.dart';
import 'package:mvvm_playground/widgets/typography.dart';

Widget mapTiles(BuildContext context) {
  return TileLayer(
    urlTemplate: mapUrl,
    errorTileCallback: (context, exception, stackTrace) {
      Container(
        color: dangerColor,
        child: Center(
          child: displayText(
            'Tile Load Error',
            style: Styles.BodyAlt,
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
      color: Colors.blue,
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
          color: Colors.blue,
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

Marker treeMarker(BuildContext context, {required Tree tree}) {
  return Marker(
    width: sizeByScreenWidth(context: context, sizePercent: 0.25),
    height: sizeByScreenWidth(context: context, sizePercent: 0.21),
    point: tree.position,
    child: Stack(
      children: [
        Center(
          child: Container(
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
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
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
            child: displayText(tree.name,
                overflow: TextOverflow.ellipsis, style: Styles.SubtitleAlt),
          ),
        )
      ],
    ),
  );
}

Marker InputMarkers(BuildContext context,
    {required Tree tree, String no = ''}) {
  return Marker(
    width: 100,
    height: 100,
    point: tree.position,
    child: Stack(
      alignment: Alignment.center,
      fit: StackFit.loose,
      children: [
        Positioned(
          top: 16,
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(6),
            decoration:
                ShapeDecoration(shape: CircleBorder(), color: dangerColor),
            child: displayText(no, style: Styles.BodyAlt),
          ),
        ),
      ],
    ),
  );
}
