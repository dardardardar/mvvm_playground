import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:mvvm_playground/features/state/base_state.dart';
import 'package:mvvm_playground/functions/set_location.dart';

@injectable
class MapsCubit extends Cubit<BaseState> {
  MapsCubit() : super(BaseState());

  Future initLocation() async {
    emit(LoadingState());
    try {
      final pos = await determinePosition();
      emit(SuccessState<LatLng>(data: pos));
    } on Exception catch (e) {
      emit(GeneralErrorState(e: e));
    }
  }

  void add(Map<MarkerId, Marker> markers) {
    var markerIdVal = Random().toString();
    final MarkerId markerId = MarkerId(markerIdVal);

    // creating a new MARKER
    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(-6.2277937, 106.833333),
      infoWindow: InfoWindow(title: markerIdVal, snippet: '*'),
      onTap: () {},
    );

    // adding a new marker to map
    markers[markerId] = marker;
  }
}
