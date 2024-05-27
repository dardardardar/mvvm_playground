import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:mvvm_playground/const/theme.dart';
import 'package:mvvm_playground/features/cubit/maps_cubit.dart';
import 'package:mvvm_playground/features/cubit/maps_cubit_data.dart';
import 'package:mvvm_playground/features/state/base_state.dart';
import 'package:mvvm_playground/functions/geolocation.dart';
import 'package:mvvm_playground/widgets/bottom_bar.dart';
import 'package:mvvm_playground/widgets/buttons.dart';
import 'package:mvvm_playground/widgets/map_components.dart';
import 'package:mvvm_playground/widgets/modal_history.dart';
import 'package:mvvm_playground/widgets/modal_sheets.dart';
import 'package:mvvm_playground/widgets/navigation_bar.dart';
import 'package:mvvm_playground/widgets/states.dart';
import 'package:provider/provider.dart';

import '../models/tree_model.dart';

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
      context.read<MapsCubit>().sendHistory(
          lat: position.latitude.toString(),
          long: position.longitude.toString());
      await Future.delayed(const Duration(seconds: 1));
    }
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
      appBar: appBar(
        title: widget.title,
      ),
      body: _buildInputDataBody(context),
    );
  }

  Widget _buildInputDataBody(BuildContext context) {
    return Container(
      color: Colors.green.shade50,
      child: BlocBuilder<MapsCubit, MapsData>(
        builder: (context, state) {
          if (state.listTree is SuccessState<List<Tree>> &&
              state.listRoute is SuccessState<List<Tree>>) {
            final trees = (state.listTree as SuccessState<List<Tree>>).data;
            final routes = (state.listRoute as SuccessState<List<Tree>>).data;
            return StreamBuilder<latLng.LatLng>(
              stream: locationStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var userLocation = Provider.of<GeoLocation>(context);
                  userLocation.radiuscentermeters = 5;
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
                                initialZoom: 20,
                                initialCenter: latLng.LatLng(
                                    userLocationCurrent.latitude,
                                    userLocationCurrent.longitude)),
                            children: [
                              mapTiles(context),
                              Visibility(
                                visible: widget.isHistory,
                                child: PolylineLayer(
                                  polylines: routes.isEmpty
                                      ? []
                                      : mapPolyline(routes: routes),
                                  polylineCulling: true,
                                ),
                              ),
                              MarkerClusterLayerWidget(
                                options: MarkerClusterLayerOptions(
                                  maxClusterRadius: 100,
                                  size: Size(40, 40),
                                  markers: [
                                    for (var i = 0; i < trees.length; i++)
                                      treeMarker(context, tree: trees[i])
                                  ],
                                  builder: (context, markers) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: primaryColor,
                                      ),
                                      child: Center(
                                        child: Text(
                                          markers.length.toString(),
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              // Visibility(
                              //   visible: true,
                              //   child: CircleLayer(
                              //     circles: [
                              //       for (var i = 0; i < trees.length; i++)
                              //         circleMarkerOverlays(
                              //             position: trees[i].position,
                              //             radius: 5,
                              //             color: primaryColor.withOpacity(0.3)),
                              //     ],
                              //   ),
                              // ),
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
                                  for (var i = 0; i < routes.length; i++)
                                    InputMarkers(context,
                                        tree: routes[i], no: i.toString()),
                                ]),
                              )
                            ],
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
                                                    Text(
                                                      'Palm near',
                                                      style: subtitle3,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    Text(
                                                      userLocation.currentTree
                                                              .isEmpty
                                                          ? '-'
                                                          : '${userLocation.currentTree.first}',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: subtitle,
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
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      'No. reg',
                                                      style: subtitle3,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    Text(
                                                      userLocation.currentTree
                                                              .isEmpty
                                                          ? '-'
                                                          : '${userLocation.currentidTree.first}',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: subtitle,
                                                    ),
                                                  ],
                                                ),
                                              )
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
                                    flex: 1,
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
                                                                .currentidTree
                                                                .first,
                                                        name: userLocation
                                                                .currentTree
                                                                .isEmpty
                                                            ? 'No Tree found'
                                                            : userLocation
                                                                .currentTree
                                                                .first,
                                                        position: latLng.LatLng(
                                                            userLocation.centerlocation.latitude ?? 0,
                                                            userLocation.centerlocation.longitude ?? 0)));
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
                                                    history: routes.isEmpty
                                                        ? []
                                                        : routes.reversed
                                                            .toList());
                                              },
                                              title: 'History',
                                              icon: Icons.history),
                                        )
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
