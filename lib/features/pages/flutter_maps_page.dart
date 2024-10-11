import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_map_mbtiles/flutter_map_mbtiles.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:mvvm_playground/const/enums.dart';
import 'package:mvvm_playground/const/theme.dart';
import 'package:mvvm_playground/features/cubit/maps_cubit.dart';
import 'package:mvvm_playground/features/cubit/maps_cubit_data.dart';
import 'package:mvvm_playground/features/response/djikstra.dart';
import 'package:mvvm_playground/features/state/base_state.dart';
import 'package:mvvm_playground/functions/geolocation.dart';
import 'package:mvvm_playground/widgets/bottom_bar.dart';
import 'package:mvvm_playground/widgets/buttons.dart';
import 'package:mvvm_playground/widgets/map_components.dart';
import 'package:mvvm_playground/widgets/modal_sheets.dart';
import 'package:mvvm_playground/widgets/navigation_bar.dart';
import 'package:mvvm_playground/widgets/states.dart';
import 'package:mvvm_playground/widgets/typography.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map_geojson/flutter_map_geojson.dart';
import 'package:path/path.dart' as path;
import 'package:rxdart/rxdart.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../models/tree_model.dart';

late Map<String, dynamic> geoJson;
late Graph graph;

class FlutterMapPage extends StatefulWidget {
  final bool isHistory;
  final String title;
  const FlutterMapPage(
      {super.key, required this.isHistory, required this.title});

  @override
  State<StatefulWidget> createState() {
    return _HomeViewPageState();
  }
}

class _HomeViewPageState extends State<FlutterMapPage> {
  bool showhistory = false;
  late MapController mapController = MapController();
  late Stream<latLng.LatLng> locationStream;
  bool isDebug = false;
  double speedMaps = 0.0;
  bool loadingData = false;
  bool isMapReady = false;
  Timer? _timer;
  String? mbtilesFilePath;
  List<latLng.LatLng> polylinePoints = [];
  List<latLng.LatLng> polylinePointsRoutes = [];
  final List<Polyline> generatedPolylines = [];
  final List<Polyline> generatedPolylinesRoute = [];
  final GeoJsonParser geoJsonParser = GeoJsonParser(
    defaultMarkerColor: Colors.red,
    defaultPolylineColor: Colors.red,
    defaultPolygonBorderColor: Colors.red,
    defaultPolygonFillColor: Colors.red.withOpacity(0.1),
    defaultCircleMarkerColor: Colors.red.withOpacity(0.25),
  );

  final _combinedStream = Rx.combineLatest2(
    Sensors().magnetometerEventStream(),
    Sensors().accelerometerEventStream(),
    (MagnetometerEvent mag, AccelerometerEvent acc) {
      return _calculateHeading(mag, acc);
    },
  );
  double _heading = 0.0;

  @override
  void initState() {
    super.initState();
    locationStream = getLocationStream();
    _loadMbtilesFile();
    getGeoJson();
    context.read<MapsCubit>().initMarker();

    _combinedStream.listen((heading) {
      if (mounted) {
        setState(() {
          _heading = heading;
        });
      }
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        getSpeed();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      processPathData();
    });
  }

  static double _calculateHeading(
      MagnetometerEvent magnetometer, AccelerometerEvent accelerometer) {
    final ax = accelerometer.x;
    final ay = accelerometer.y;
    final az = accelerometer.z;

    final mx = magnetometer.x;
    final my = magnetometer.y;
    final mz = magnetometer.z;

    final pitch = atan2(-ax, sqrt(ay * ay + az * az));
    final roll = atan2(ay, az);

    final mx1 = mx * cos(pitch) + mz * sin(pitch);
    final my1 = mx * sin(roll) * sin(pitch) +
        my * cos(roll) -
        mz * sin(roll) * cos(pitch);

    final heading = atan2(-my1, mx1) * (180 / pi);
    return (heading + 360) % 360;
  }

  Future<void> getGeoJson() async {
    String geoJsonString = await rootBundle.loadString('assets/jalur.geojson');
    geoJsonParser.parseGeoJsonAsString(geoJsonString);
    setState(() {
      geoJson = json.decode(geoJsonString);
      graph = buildGraphFromGeoJson(geoJson);

      generatedPolylines.clear();
      for (var feature in geoJson['features']) {
        if (feature['geometry']['type'] == 'LineString') {
          List<latLng.LatLng> polylinePoints = [];
          for (var coord in feature['geometry']['coordinates']) {
            polylinePoints.add(latLng.LatLng(coord[1], coord[0]));
          }
          generatedPolylines.add(Polyline(
              points: polylinePoints, color: Colors.blue, strokeWidth: 3.0));
        } else if (feature['geometry']['type'] == 'MultiLineString') {
          for (var line in feature['geometry']['coordinates']) {
            List<latLng.LatLng> polylinePoints = [];
            for (var coord in line) {
              polylinePoints.add(latLng.LatLng(coord[1], coord[0]));
            }
            generatedPolylines.add(Polyline(
              points: polylinePoints,
              color: Colors.blue,
              strokeWidth: 3.0,
            ));
          }
        }
      }
    });
  }

  Future<void> _loadMbtilesFile() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final mbtilesFile = File(path.join(documentsDir.path, 'map.mbtiles'));

    if (await mbtilesFile.exists()) {
      setState(() {
        mbtilesFilePath = mbtilesFile.path;
        loadingData = false;
      });
    } else {
      setState(() {
        mbtilesFilePath = null;
        loadingData = false;
      });
    }
  }

  List<Marker> getVisibleMarkers(List<Marker> allMarkers) {
    if (!isMapReady) {
      return [];
    }

    LatLngBounds? bounds = mapController.camera.visibleBounds;
    if (bounds == false) {
      return [];
    }

    return allMarkers.where((marker) {
      return bounds.contains(marker.point);
    }).toList();
  }

  Stream<latLng.LatLng> getLocationStream() async* {
    Future.delayed(const Duration(seconds: 5));
    while (true) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);
      yield latLng.LatLng(position.latitude, position.longitude);
    }
  }

  Future<void> getSpeed() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        speedMaps = 0.0;
      });
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        setState(() {
          speedMaps = 0.0;
        });
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    double speed = position.speed;
    setState(() {
      speedMaps = speed;
    });
  }

  Future<void> processPathData() async {
    // Get the current position of the device
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);

    final startLatLng = latLng.LatLng(position.latitude, position.longitude);
    final endLatLng = latLng.LatLng(-6.23057988673238, 106.82135814751845);

    final path = await dijkstra(geoJson, graph, startLatLng, endLatLng);

    polylinePoints.clear();
    polylinePointsRoutes.clear();
    polylinePointsRoutes.add(startLatLng);

    double totalDistance = 0;

    for (var i = 1; i < path.length; i++) {
      totalDistance += _calculateDistance(path[i], path[i - 1]);

      if (i == 1) {
        polylinePointsRoutes
            .add(latLng.LatLng(path[i].latitude, path[i].longitude));
      }
      polylinePoints.add(latLng.LatLng(path[i].latitude, path[i].longitude));
    }

    await getSpeed();
    _updatePolylines();
  }

  double _calculateDistance(latLng.LatLng point1, latLng.LatLng point2) {
    return kmDistance(
      latLng.LatLng(point1.latitude, point1.longitude),
      latLng.LatLng(point2.latitude, point2.longitude),
    );
  }

  void _updatePolylines() {
    setState(() {
      generatedPolylines.add(Polyline(
        points: polylinePoints,
        color: Colors.green,
        strokeWidth: 10.0,
      ));

      generatedPolylinesRoute.add(Polyline(
        points: polylinePointsRoutes,
        color: Colors.green,
        isDotted: true,
        strokeWidth: 5.0,
      ));
    });
  }

  double metersToPixels(double meters, double latitude, double zoom) {
    final metersPerPixel =
        (156543.03392 * math.cos(latitude * math.pi / 180) / math.pow(2, zoom));
    return meters / metersPerPixel;
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: appBar(title: widget.title, context: context),
      body: _buildInputDataBody(context),
    );
  }

  Widget _buildInputDataBody(BuildContext context) {
    return Container(
      color: secondaryColor,
      child: BlocBuilder<MapsCubit, MapsData>(
        builder: (context, state) {
          if (state.listTree is SuccessState<List<Tree>> &&
              state.listRoute is SuccessState<List<Tree>> &&
              state.listHistory is SuccessState<List<Tree>>) {
            final trees = (state.listTree as SuccessState<List<Tree>>).data;
            final histories =
                (state.listHistory as SuccessState<List<Tree>>).data;

            List<Marker> allMarkers = trees.map((tree) {
              return treeMarker(context, tree: tree);
            }).toList();

            List<Marker> visibleMarkers = getVisibleMarkers(allMarkers);

            return StreamBuilder<latLng.LatLng>(
              stream: locationStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var userLocation = Provider.of<GeoLocation>(context);
                  var userLocationCurrent = snapshot.data!;

                  return SafeArea(
                    child: Column(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Visibility(
                            visible: mbtilesFilePath != null,
                            child: FlutterMap(
                              mapController: mapController,
                              options: MapOptions(
                                initialCenter: latLng.LatLng(
                                    userLocationCurrent.latitude,
                                    userLocationCurrent.longitude),
                                initialZoom: 20,
                                onMapReady: () {
                                  setState(() {
                                    isMapReady = true;
                                  });
                                },
                                onPositionChanged: (mapPosition, hasGesture) {
                                  setState(() {});
                                },
                              ),
                              children: [
                                TileLayer(
                                  tileProvider: MbTilesTileProvider.fromPath(
                                      path: mbtilesFilePath!),
                                  errorTileCallback:
                                      (context, exception, stackTrace) {
                                    Container(
                                      color: Colors.red,
                                      child: Center(
                                        child: Text('Error loading map'),
                                      ),
                                    );
                                  },
                                ),
                                PolylineLayer(polylines: generatedPolylines),
                                PolylineLayer(
                                    polylines: generatedPolylinesRoute),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                        point: latLng.LatLng(
                                          userLocationCurrent.latitude,
                                          userLocationCurrent.longitude,
                                        ),
                                        child:
                                            _buildCompass(_heading.toDouble())),
                                  ],
                                ),
                                MarkerClusterLayerWidget(
                                  options: MarkerClusterLayerOptions(
                                    maxClusterRadius: 100,
                                    size: const Size(40, 40),
                                    markers: visibleMarkers,
                                    builder: (context, markers) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: primaryColor,
                                        ),
                                        child: Center(
                                          child: displayText(
                                              markers.length.toString(),
                                              style: Styles.BodyAlt),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            debugBar(
                                geolocation: userLocation,
                                pos: userLocationCurrent,
                                visible: isDebug),
                            Container(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Visibility(
                                    visible: !widget.isHistory,
                                    child: Flexible(
                                      flex: 5,
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
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    displayText('Palm near',
                                                        style: Styles.Captions),
                                                    displayText(
                                                        userLocation.currentTree
                                                                .isEmpty
                                                            ? '-'
                                                            : '${userLocation.currentTree}',
                                                        style: Styles.Body),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 8,
                                              ),
                                              Flexible(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    displayText('No. reg',
                                                        style: Styles.Captions),
                                                    displayText(
                                                      userLocation.currentTree
                                                              .isEmpty
                                                          ? '-'
                                                          : '${userLocation.currentidTree}',
                                                      style: Styles.Body,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 8,
                                              ),
                                              Flexible(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    displayText('Speed',
                                                        style: Styles.Captions),
                                                    displayText(
                                                      (speedMaps * 3.6)
                                                              .toStringAsFixed(
                                                                  2) +
                                                          ' km/Jam',
                                                      style: Styles.Body,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    flex: 2,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Visibility(
                                          visible: !widget.isHistory,
                                          child: boxButton(
                                              context: context,
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
                                                                .currentidTree,
                                                        name: userLocation.currentTree.isEmpty
                                                            ? 'No Tree found'
                                                            : userLocation
                                                                .currentTree,
                                                        position: latLng.LatLng(
                                                            userLocation
                                                                    .centerlocation
                                                                    .latitude ??
                                                                0,
                                                            userLocation
                                                                    .centerlocation
                                                                    .longitude ??
                                                                0)));
                                              },
                                              title: 'Collect',
                                              icon: Icons.add_circle_outline),
                                        ),
                                        Visibility(
                                          visible: widget.isHistory,
                                          child: boxButton(
                                              context: context,
                                              onTap: () {
                                                showModalHistory(context,
                                                    history: histories.isEmpty
                                                        ? []
                                                        : histories.reversed
                                                            .toList());
                                              },
                                              title: 'History',
                                              icon: Icons.history),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        boxButton(
                                            context: context,
                                            onTap: () {
                                              showModalSchedule(context,
                                                  tree: trees.isEmpty
                                                      ? []
                                                      : trees.reversed
                                                          .toList());
                                            },
                                            title: 'RKH',
                                            icon: Icons.calendar_month),
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
                  return errorAlert(text: snapshot.error.toString());
                } else {
                  return circularLoading(text: 'Loading Stream...');
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

Widget _buildCompass(double direction) {
  return Container(
    decoration: const ShapeDecoration(
        shape: CircleBorder(),
        shadows: [
          BoxShadow(
            color: Colors.black12,
            spreadRadius: 3,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
        color: Colors.white),
    child: Transform.rotate(
      angle: (direction * (3.14 / 130) * -1),
      child: const Icon(
        Icons.arrow_circle_up_outlined,
        color: Colors.green,
        size: 30,
      ),
    ),
  );
}
