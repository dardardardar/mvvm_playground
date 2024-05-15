import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:mvvm_playground/features/models/tree_model.dart';
import 'package:mvvm_playground/features/repository/crud_repo.dart';
import 'package:mvvm_playground/features/state/base_state.dart';
import 'package:mvvm_playground/functions/set_location.dart';

@injectable
class GMapsCubit extends Cubit<BaseState> {
  GMapsCubit() : super(BaseState());

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

    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(-6.2277937, 106.833333),
      infoWindow: InfoWindow(title: markerIdVal, snippet: '*'),
      onTap: () {},
    );

    markers[markerId] = marker;
  }
}

@injectable
class MapsCubit extends Cubit<BaseState> {
  final CRUDRepository _crudRepository;

  MapsCubit(this._crudRepository) : super(BaseState());

  Future<void> initMarker() async {
    try {
      emit(LoadingState());
      final data = await _crudRepository.getTree();
      emit(SuccessState<List<Tree>>(data: data));
    } on Exception catch (e) {
      emit(GeneralErrorState(e: e));
    }
  }

  Future<void> sendQty({required double qty, required Tree data}) async {
    try {
      await _crudRepository.sendQty(qty, data);
    } on Exception catch (e) {
      emit(GeneralErrorState(e: e));
    }
  }
}
