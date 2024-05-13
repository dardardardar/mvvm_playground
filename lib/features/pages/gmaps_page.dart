import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mvvm_playground/features/cubit/maps_cubit.dart';
import 'package:mvvm_playground/features/models/tree_model.dart';
import 'package:mvvm_playground/features/state/base_state.dart';
import 'package:mvvm_playground/widgets/modal_sheets.dart';
import 'package:latlong2/latlong.dart' as latLng;

class GmapsPage extends StatefulWidget {
  const GmapsPage({super.key});

  @override
  State<GmapsPage> createState() => _GmapsPageState();
}

class _GmapsPageState extends State<GmapsPage> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  LatLng? lat;

  Map<MarkerId, Marker> markers =
      <MarkerId, Marker>{}; // CLASS MEMBER, MAP OF MARKS

  @override
  void initState() {
    super.initState();
    context.read<MapsCubit>().initLocation();
    context.read<MapsCubit>().add(markers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<MapsCubit, BaseState>(builder: (context, state) {
        if (state is GeneralErrorState) {
          return Center(
            child: Text(state.error),
          );
        }
        if (state is SuccessState<LatLng>) {
          return GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
                target: LatLng(state.data.latitude, state.data.longitude),
                zoom: 20),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            markers: Set<Marker>.of(markers.values),
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      }),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.all(8),
          child: InkWell(
            onTap: () {
              showModalInputQty(context,
                  data: Tree(name: '', position: const latLng.LatLng(0, 0)));
            },
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: ShapeDecoration(
                  shape: CircleBorder(side: BorderSide(color: Colors.white)),
                  color: Colors.transparent),
              child: Icon(Icons.add),
            ),
          ),
        ),
      ),
    );
  }
}
