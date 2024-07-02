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
import 'package:mvvm_playground/const/enums.dart';
import 'package:mvvm_playground/const/theme.dart';
import 'package:mvvm_playground/features/cubit/maps_cubit.dart';
import 'package:mvvm_playground/features/cubit/maps_cubit_data.dart';
import 'package:mvvm_playground/features/state/base_state.dart';
import 'package:mvvm_playground/functions/geolocation.dart';
import 'package:mvvm_playground/widgets/bottom_bar.dart';
import 'package:mvvm_playground/widgets/buttons.dart';
import 'package:mvvm_playground/widgets/map_components.dart';
import 'package:mvvm_playground/widgets/modal_sheets.dart';
import 'package:mvvm_playground/widgets/navigation_bar.dart';
import 'package:mvvm_playground/widgets/states.dart';
import 'package:mvvm_playground/widgets/typography.dart';
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
  bool _isCheckedCheckbox = false;

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
    Future.delayed(const Duration(seconds: 5));
    while (true) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);
      yield latLng.LatLng(position.latitude, position.longitude);
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
                                // visible: (widget.isHistory == false),
                                visible: false,
                                child: PolylineLayer(
                                  polylines: routes.isEmpty
                                      ? []
                                      : mapPolyline(routes: routes),
                                  polylineCulling: true,
                                ),
                              ),
                              Visibility(
                                visible: _isCheckedCheckbox,
                                // visible: false,
                                child: PolylineLayer(
                                  polylines: histories.isEmpty
                                      ? []
                                      : mapPolylineHistories(routes: histories),
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
                                        borderRadius: BorderRadius.circular(20),
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
                                visible: _isCheckedCheckbox,
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
                                    visible: true,
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
                                            children: [
                                              Theme(
                                                data:
                                                    Theme.of(context).copyWith(
                                                  checkboxTheme:
                                                      CheckboxThemeData(
                                                    side: BorderSide(
                                                        color: Colors.green,
                                                        width:
                                                            2), // Set your border color here
                                                  ),
                                                ),
                                                child: Checkbox(
                                                  value: _isCheckedCheckbox,
                                                  onChanged: (bool? value) {
                                                    setState(() {
                                                      _isCheckedCheckbox =
                                                          value!;
                                                    });
                                                  },
                                                  activeColor: Colors.green,
                                                  checkColor: Colors.white,
                                                  hoverColor: Colors.green,
                                                  focusColor: Colors.green,
                                                ),
                                              ),
                                              displayText('Show History',
                                                  style: Styles.Captions),
                                            ],
                                          ),
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
                                    flex: 3,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Visibility(
                                          visible:
                                              (_isCheckedCheckbox == false),
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
                                          visible: _isCheckedCheckbox,
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
                  if (_isCheckedCheckbox == false) {
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
