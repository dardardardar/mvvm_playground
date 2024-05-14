import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:mvvm_playground/const/theme.dart';
import 'package:mvvm_playground/features/cubit/maps_cubit.dart';
import 'package:mvvm_playground/features/state/base_state.dart';
import 'package:mvvm_playground/functions/geolocation.dart';
import 'package:mvvm_playground/widgets/input.dart';
import 'package:mvvm_playground/widgets/modal_sheets.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/tree_model.dart';

// add-- permisions
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

  Polyline firstPolyline = Polyline(
    points: [
      latLng.LatLng(-6.227787860077413, 106.83344878298254),
      latLng.LatLng(-6.228012025218627, 106.83346895355372),
      latLng.LatLng(-6.228020460551202, 106.83333653209965),
      latLng.LatLng(-6.228115365486504, 106.83334392789742),
      latLng.LatLng(-6.228108380578882, 106.83341906947368),
      latLng.LatLng(-6.228129120134003, 106.83344056435672),
      latLng.LatLng(-6.228342800341565, 106.83344878298254),
      latLng.LatLng(-6.228355998234495, 106.83337291865526),
      latLng.LatLng(-6.228438956410974, 106.83338366611142),
      latLng.LatLng(-6.22839752205345, 106.83409602806141),
      latLng.LatLng(-6.228396265101803, 106.8340859128276),
      latLng.LatLng(-6.228391865814138, 106.83453035136445),
    ],
    color: Colors.green,
    strokeWidth: 3,
    isDotted: false,
    useStrokeWidthInMeter: true,
  );
  List<Tree> tree = [
    Tree(
        name: 'Palma One',
        position: const latLng.LatLng(-6.2277937, 106.833333)),
    Tree(
        name: 'Tikungan Pom Bensin',
        position: const latLng.LatLng(-6.228418, 106.833359)),
    Tree(
        name: 'Belokan Nasi Soto',
        position: const latLng.LatLng(-6.228384, 106.834523)),
    Tree(
        name: 'Kebab Turki',
        position: const latLng.LatLng(-6.2283196, 106.8336922)),
  ];
  @override
  void initState() {
    super.initState();
    locationStream = getLocationStream();
    context.read<MapsCubit>().initMarker();
  }

  Stream<latLng.LatLng> getLocationStream() async* {
    while (true) {
      await Permission.location.request();
      await Permission.locationWhenInUse.request();
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);

      yield latLng.LatLng(position.latitude, position.longitude);
      await Future.delayed(Duration(seconds: 1));
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
      body: SafeArea(child: _buildInputDataBody(context)),
    );
  }

  Widget _buildInputDataBody(BuildContext context) {
    return BlocBuilder<MapsCubit, BaseState>(
      builder: (context, state) {
        if (state is SuccessState<Trees>) {
          return StreamBuilder<latLng.LatLng>(
            stream: locationStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var userLocation = Provider.of<GeoLocation>(context);
                userLocation.radiuscentermeters = 10;
                for (var i = 0; i < tree.length; i++) {
                  userLocation.setPointCenter(tree[i].position.latitude,
                      tree[i].position.longitude, tree[i].name);
                }
                var userLocationCurrent = snapshot.data!;
                return Column(
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
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.app',
                          ),
                          PolylineLayer(
                            polylines: [firstPolyline],
                            polylineCulling: true,
                          ),
                          CircleLayer(
                            circles: [
                              CircleMarker(
                                  point: latLng.LatLng(
                                      userLocationCurrent.latitude,
                                      userLocationCurrent.longitude),
                                  color: Colors.blue.withOpacity(0.3),
                                  radius: metersToPixels(
                                      10, userLocationCurrent.latitude, 15.0)),
                            ],
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                  width: 300.0,
                                  height: 300.0,
                                  point: latLng.LatLng(
                                      userLocationCurrent.latitude,
                                      userLocationCurrent.longitude),
                                  child: Icon(
                                    Icons.circle,
                                    color: Colors.purple,
                                  )),
                              for (var i = 0; i < state.data.data.length; i++)
                                Marker(
                                  width: 300.0,
                                  height: 300.0,
                                  point: state.data.data[i].position,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(8),
                                        child: Icon(
                                          size: 48,
                                          Icons.pin_drop,
                                          color: primaryColor,
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            color: primaryColor),
                                        child: Text(
                                          state.data.data[i].name,
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Wrap(
                            children: [
                              Text('Lat : ${userLocationCurrent.latitude}'),
                              SizedBox(
                                width: 8,
                              ),
                              Text('Long : ${userLocationCurrent.latitude}'),
                              SizedBox(
                                width: 8,
                              ),
                              Text(
                                  'isInRange : ${userLocation.status.contains(true)}'),
                            ],
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          InkWell(
                            onTap: () {
                              showModalInputQty(context,
                                  isNear: userLocation.status.contains(true),
                                  data: Tree(
                                      name: userLocation.currentTree.isEmpty
                                          ? 'No Tree found'
                                          : userLocation.currentTree.first,
                                      position: latLng.LatLng(
                                          userLocation
                                                  .centerlocation.latitude ??
                                              0,
                                          userLocation
                                                  .centerlocation.longitude ??
                                              0)));
                            },
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: ShapeDecoration(
                                  shape: CircleBorder(
                                      side: BorderSide(color: Colors.white)),
                                  color: Colors.transparent),
                              child: Icon(Icons.add),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return CircularProgressIndicator(); // Loading indicator while waiting for data
              }
            },
          );
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}