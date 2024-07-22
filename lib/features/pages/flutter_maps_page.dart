import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
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
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map_geojson/flutter_map_geojson.dart';
import 'package:path/path.dart' as path;
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
  String? mbtilesFilePath;
  List<latLng.LatLng> polylinePoints = [];
  final List<Polyline> generatedPolylines = [];
  final GeoJsonParser geoJsonParser = GeoJsonParser(
    defaultMarkerColor: Colors.red,
    defaultPolylineColor: Colors.red,
    defaultPolygonBorderColor: Colors.red,
    defaultPolygonFillColor: Colors.red.withOpacity(0.1),
    defaultCircleMarkerColor: Colors.red.withOpacity(0.25),
  );

  @override
  void initState() {
    super.initState();
    locationStream = getLocationStream();
    _loadMbtilesFile();
    getGeoJson();
    context.read<MapsCubit>().initMarker();
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
    final endLatLng = latLng.LatLng(-6.225127062360678, 106.85693674283463);
    final path = await dijkstra(geoJson, graph, startLatLng, endLatLng);

    double countDistance = 0;
    for (var i = 1; i < path.length; i++) {
      countDistance += kmDistance(
          latLng.LatLng(path[i].latitude, path[i].longitude),
          latLng.LatLng(path[i - 1].latitude, path[i - 1].longitude));
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

            return StreamBuilder<latLng.LatLng>(
              stream: locationStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var userLocation = Provider.of<GeoLocation>(context);
                  userLocation.radiuscentermeters = 4;
                  for (var i = 0; i < trees.length; i++) {
                    userLocation.setPointCenter(trees[i]);
                  }
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
                              // options: MapOptions(
                              //     onTap: (p, l) {
                              //       print('${l.latitude}, ${l.longitude}');
                              //     },
                              //     initialZoom: 20,
                              //     initialCenter: latLng.LatLng(
                              //         userLocationCurrent.latitude,
                              //         userLocationCurrent.longitude)),
                              options: MapOptions(
                                initialCenter:
                                    latLng.LatLng(-6.2278322, 106.8333253),
                                initialZoom: 16,
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
                                Visibility(
                                  visible: false,
                                  child: PolylineLayer(
                                    polylines: routes.isEmpty
                                        ? []
                                        : mapPolyline(routes: routes),
                                    polylineCulling: true,
                                  ),
                                ),
                                PolylineLayer(polylines: generatedPolylines),
                                Visibility(
                                  visible: (widget.isHistory),
                                  child: PolylineLayer(
                                    polylines: histories.isEmpty
                                        ? []
                                        : mapPolylineHistories(
                                            routes: histories),
                                    polylineCulling: true,
                                  ),
                                ),
                                MarkerClusterLayerWidget(
                                  options: MarkerClusterLayerOptions(
                                    maxClusterRadius: 100,
                                    size: const Size(40, 40),
                                    markers: [
                                      for (var i = 0; i < trees.length; i++)
                                        treeMarker(context, tree: trees[i])
                                    ],
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
                                MarkerLayer(
                                  markers: [
                                    userMarker(
                                        position: latLng.LatLng(
                                            userLocationCurrent.latitude,
                                            userLocationCurrent.longitude)),
                                  ],
                                ),
                                Visibility(
                                  visible: widget.isHistory,
                                  child: MarkerLayer(markers: [
                                    for (var i = 0; i < histories.length; i++)
                                      InputMarkers(context,
                                          tree: histories[i],
                                          no: (i + 1).toString()),
                                  ]),
                                )
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
                                                width: 24,
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
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Expanded(
                                    flex: 1,
                                    child: Center(),
                                  ),
                                  Flexible(
                                    flex: 4,
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
                                        SizedBox(
                                          width: 5,
                                        ),
                                        boxButton(
                                            context: context,
                                            onTap: () {
                                              processPathData();
                                            },
                                            title: 'Djikstra',
                                            icon: Icons.route),
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
                  if (!widget.isHistory) {
                    Future.delayed(Duration(seconds: 1), () {
                      showModalSchedule(context,
                          tree: trees.isEmpty ? [] : trees.reversed.toList());
                    });
                  }
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
