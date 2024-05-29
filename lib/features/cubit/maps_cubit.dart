import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:injectable/injectable.dart';
import 'package:mvvm_playground/features/cubit/maps_cubit_data.dart';
import 'package:mvvm_playground/features/models/tree_model.dart';
import 'package:mvvm_playground/features/repository/crud_repo.dart';
import 'package:mvvm_playground/features/state/base_state.dart';
import 'package:mvvm_playground/functions/connection.dart';

@injectable
class MapsCubit extends Cubit<MapsData> {
  final CRUDRepository _crudRepository;

  MapsCubit(this._crudRepository) : super(MapsData());

  Future<void> initMarker() async {
    try {
      emit(state.copyWith(
        listTree: LoadingState<List<Tree>>(),
        listRoute: LoadingState<List<Routes>>(),
      ));
      final tree = await _crudRepository.getTree();
      final route = await _crudRepository.getRoute();

      emit(state.copyWith(
        listTree: SuccessState<List<Tree>>(data: tree),
        listRoute: SuccessState<List<Tree>>(data: route),
      ));
    } on Exception catch (e) {
      emit(state.copyWith(
        listTree: GeneralErrorState(e: e, error: e.toString()),
        listRoute: GeneralErrorState(e: e, error: e.toString()),
      ));
    }
  }

  Future<void> sendQty({required double qty, required Tree data}) async {
    try {
      await _crudRepository.sendQty(qty, data);
    } on Exception catch (e) {
      emit(state.copyWith(
          sendQty: GeneralErrorState(e: e, error: e.toString())));
    }
  }

  Future<void> sendHistory({required String lat, required String long}) async {
    try {
      await _crudRepository.sendHistory(lat, long);
    } on Exception catch (e) {
      emit(state.copyWith(
          sendQty: GeneralErrorState(e: e, error: e.toString())));
    }
  }
}
