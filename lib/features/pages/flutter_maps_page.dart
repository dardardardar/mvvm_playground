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
      setState(() {
        _heading = heading;
      });
    });

    // _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
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
    final mz1 = mx * cos(roll) * sin(pitch) -
        my * sin(roll) -
        mz * cos(pitch) * cos(roll);

    final heading = atan2(-my1, mx1) * (180 / pi);
    return (heading + 360) % 360; // Normalize to 0-360 degrees
  }

  Future<void> getGeoJson() async {
    String geoJsonString = await rootBundle.loadString('assets/jaksel.geojson');
    geoJsonParser.parseGeoJsonAsString(geoJsonString);
    setState(() {
      geoJson = json.decode(geoJsonString);
      graph = buildGraphFromGeoJson(geoJson);
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

  //https://chatgpt.com/c/7e11a25f-4c99-44a4-9215-12bed4efccd7
  List<Marker> getVisibleMarkers(List<Marker> allMarkers) {
    if (!isMapReady) {
      return [];
    }

    LatLngBounds? bounds = mapController.camera.visibleBounds;
    if (bounds == null) {
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
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);

    final startLatLng = latLng.LatLng(position.latitude, position.longitude);
    final endLatLng = latLng.LatLng(-6.23057988673238, 106.82135814751845);
    final path = await dijkstra(geoJson, graph, startLatLng, endLatLng);

    double countDistance = 0;
    polylinePoints.clear();
    polylinePointsRoutes.clear();
    polylinePointsRoutes
        .add(latLng.LatLng(position.latitude, position.longitude));
    for (var i = 1; i < path.length; i++) {
      countDistance += kmDistance(
          latLng.LatLng(path[i].latitude, path[i].longitude),
          latLng.LatLng(path[i - 1].latitude, path[i - 1].longitude));
      if (i == 1) {
        polylinePointsRoutes
            .add(latLng.LatLng(path[i].latitude, path[i].longitude));
      }
      polylinePoints.add(latLng.LatLng(path[i].latitude, path[i].longitude));
    }

    await getSpeed();
    print('Jarak: $countDistance Meter');
    print('$speedMaps m/s');
    print('Waktu: ${countDistance / speedMaps} Detik');

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
            final routes = (state.listRoute as SuccessState<List<Tree>>).data;
            final histories =
                (state.listHistory as SuccessState<List<Tree>>).data;

            // Convert trees to markers
            List<Marker> allMarkers = trees.map((tree) {
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
                        decoration: ShapeDecoration(
                            shape: CircleBorder(), color: dangerColor),
                        child: displayText(tree.name, style: Styles.BodyAlt),
                      ),
                    ),
                  ],
                ),
              );
            }).toList();

            // Get only visible markers based on current map bounds
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
                                    -1.48429254132818, 112.764188841751),
                                initialZoom: 20,
                                onMapReady: () {
                                  setState(() {
                                    isMapReady = true;
                                  });
                                },
                                onPositionChanged: (mapPosition, hasGesture) {
                                  setState(() {
                                    // Update the markers based on new map position
                                  });
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
                        // The rest of your widget tree remains unchanged
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
