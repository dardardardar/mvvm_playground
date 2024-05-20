import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:mvvm_playground/const/theme.dart';
import 'package:mvvm_playground/features/cubit/maps_cubit.dart';
import 'package:mvvm_playground/features/cubit/maps_cubit_data.dart';
import 'package:mvvm_playground/features/state/base_state.dart';
import 'package:mvvm_playground/functions/geolocation.dart';
import 'package:mvvm_playground/widgets/modal_sheets.dart';
import 'package:mvvm_playground/widgets/navigation_bar.dart';
import 'package:mvvm_playground/widgets/states.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/tree_model.dart';

class FlutterMapPage extends StatefulWidget {
  const FlutterMapPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomeViewPageState();
  }
}

class _HomeViewPageState extends State<FlutterMapPage> {
  late MapController mapController = MapController();
  late Stream<latLng.LatLng> locationStream;

  @override
  void initState() {
    super.initState();
    locationStream = getLocationStream();
    context.read<MapsCubit>().initMarker();
  }

  Stream<latLng.LatLng> getLocationStream() async* {
    Future.delayed(const Duration(seconds: 3));
    while (true) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);

      yield latLng.LatLng(position.latitude, position.longitude);
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  double metersToPixels(double meters, double latitude, double zoom) {
    final metersPerPixel =
        (156543.03392 * math.cos(latitude * math.pi / 180) / math.pow(2, zoom));
    return meters / metersPerPixel;
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: appBar(
        title: 'Go Harvest',
      ),
      body: _buildInputDataBody(context),
    );
  }

  Widget _buildInputDataBody(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: BlocBuilder<MapsCubit, MapsData>(
        builder: (context, state) {
          if (state.listTree is SuccessState<List<Tree>> &&
              state.listRoute is SuccessState<List<Routes>>) {
            final trees = (state.listTree as SuccessState<List<Tree>>).data;
            final routes = (state.listRoute as SuccessState<List<Routes>>).data;
            return StreamBuilder<latLng.LatLng>(
              stream: locationStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var userLocation = Provider.of<GeoLocation>(context);
                  userLocation.radiuscentermeters = 10;
                  for (var i = 0; i < trees.length; i++) {
                    userLocation.setPointCenter(trees[i]);
                  }
                  var userLocationCurrent = snapshot.data!;
                  return SafeArea(
                    child: Column(
                      children: [
                        Expanded(
                          flex: 5,
                          child: FlutterMap(
                            mapController: mapController,
                            options: MapOptions(
                                onTap: (p, l) {
                                  print('${l.latitude}, ${l.longitude}');
                                },
                                initialZoom: 19.5,
                                initialCenter: latLng.LatLng(
                                    userLocationCurrent.latitude,
                                    userLocationCurrent.longitude)),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://services.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
                                userAgentPackageName: 'com.example.app',
                                errorTileCallback:
                                    (context, exception, stackTrace) {
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
                              ),
                              Visibility(
                                visible: false,
                                child: PolylineLayer(
                                  polylines: [
                                    Polyline(
                                      points: routes
                                          .map((route) => route.position)
                                          .toList(),
                                      color: Colors.green,
                                      strokeWidth: 3,
                                      isDotted: false,
                                      useStrokeWidthInMeter: true,
                                    )
                                  ],
                                  polylineCulling: true,
                                ),
                              ),
                              CircleLayer(
                                circles: [
                                  CircleMarker(
                                      point: latLng.LatLng(
                                          userLocationCurrent.latitude,
                                          userLocationCurrent.longitude),
                                      color: Colors.blue.withOpacity(0.3),
                                      radius: metersToPixels(10,
                                          userLocationCurrent.latitude, 15.0)),
                                ],
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                      point: latLng.LatLng(
                                          userLocationCurrent.latitude,
                                          userLocationCurrent.longitude),
                                      child: Container(
                                        decoration: const ShapeDecoration(
                                            shape: CircleBorder(),
                                            shadows: [
                                              BoxShadow(
                                                color: Colors.black12,
                                                spreadRadius: 3,
                                                blurRadius: 7,
                                                offset: Offset(0,
                                                    3), // changes position of shadow
                                              ),
                                            ],
                                            color: Colors.white),
                                        child: const Icon(
                                          Icons.circle,
                                          color: secondaryColor,
                                        ),
                                      )),
                                  for (var i = 0; i < trees.length; i++)
                                    Marker(
                                      width: 300.0,
                                      height: 300.0,
                                      point: trees[i].position,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
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
                                                      offset: Offset(0,
                                                          3), // changes position of shadow
                                                    ),
                                                  ],
                                                  color: Colors.white),
                                              child: Image.asset(
                                                  'assets/icons/go-harvest-assets.png',
                                                  height: 30),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Colors.black12,
                                                    spreadRadius: 3,
                                                    blurRadius: 7,
                                                    offset: Offset(0,
                                                        3), // changes position of shadow
                                                  ),
                                                ],
                                                color: primaryColor),
                                            child: Text(
                                              trees[i].name,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Visibility(
                              visible: false,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Wrap(
                                  children: [
                                    Text(
                                        'Lat : ${userLocationCurrent.latitude}'),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Text(
                                        'Long : ${userLocationCurrent.longitude}'),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Text(
                                        'isInRange : ${userLocation.status.contains(true)}'),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    flex: 4,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Flexible(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Text(
                                                    'Palm near',
                                                    style: subtitle3,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    userLocation
                                                            .currentTree.isEmpty
                                                        ? '-'
                                                        : '${userLocation.currentTree.first}',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 24,
                                            ),
                                            Flexible(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    'No. reg',
                                                    style: subtitle3,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    userLocation
                                                            .currentTree.isEmpty
                                                        ? '-'
                                                        : '${userLocation.currentidTree.first}',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        Text(
                                          'Detail information',
                                          style: textButton,
                                        )
                                      ],
                                    ),
                                  ),
                                  const Expanded(
                                    flex: 1,
                                    child: Center(),
                                  ),
                                  Flexible(
                                    flex: 1,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            showModalInputQty(context,
                                                isNear: userLocation.status
                                                    .contains(true),
                                                current: latLng.LatLng(
                                                    userLocationCurrent
                                                        .latitude,
                                                    userLocationCurrent
                                                        .longitude),
                                                data: Tree(
                                                    idTree: userLocation
                                                            .currentidTree
                                                            .isEmpty
                                                        ? ''
                                                        : userLocation
                                                            .currentidTree
                                                            .first,
                                                    name:
                                                        userLocation.currentTree.isEmpty
                                                            ? 'No Tree found'
                                                            : userLocation
                                                                .currentTree
                                                                .first,
                                                    position: latLng.LatLng(
                                                        userLocation
                                                                .centerlocation
                                                                .latitude ??
                                                            0,
                                                        userLocation.centerlocation.longitude ?? 0)));
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                                color: primaryColor,
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .add_circle_outline_outlined,
                                                    color: Colors.white,
                                                  ),
                                                  SizedBox(
                                                    height: 2,
                                                  ),
                                                  Text(
                                                    'Collect',
                                                    style: subtitle3,
                                                  )
                                                ]),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return circularLoading(
                      text:
                          'Loading Stream...'); // Loading indicator while waiting for data
                }
              },
            );
          }
          return circularLoading(text: 'Loading States...');
        },
      ),
    );
  }
}
