import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:injectable/injectable.dart';
import 'package:mvvm_playground/features/cubit/maps_cubit_data.dart';
import 'package:mvvm_playground/features/models/tree_model.dart';
import 'package:mvvm_playground/features/repository/crud_repo.dart';
import 'package:mvvm_playground/features/state/base_state.dart';

@injectable
class MapsCubit extends Cubit<MapsData> {
  final CRUDRepository _crudRepository;

  MapsCubit(this._crudRepository) : super(MapsData());

  Future<void> sendSyncAll() async {
    try {
      if (state.sendSync is LoadingState) {
        await _crudRepository.sendSyncAll();
      }
    } on Exception catch (e) {
      emit(state.copyWith(
          sendSync: GeneralErrorState(e: e, error: e.toString())));
    }
  }

  Future<void> installation(status) async {
    try {
      emit(state.copyWith(
        sendSync: LoadingState(),
      ));
      final ress = await _crudRepository.Installation(status);
      await ress;
      if (ress is SuccessState<bool>) {
        emit(state.copyWith(
          sendSync: SuccessState<bool>(data: true),
        ));
      }
    } on Exception catch (e) {
      emit(state.copyWith(
          sendSync: GeneralErrorState(e: e, error: e.toString())));
    }
  }

  Future<void> syncLogin(status) async {
    try {
      emit(state.copyWith(
        sendSync: LoadingState(),
      ));
      final ress2 = await _crudRepository.syncLogin(status);
      if (ress2 is SuccessState<bool>) {
        emit(state.copyWith(
          sendSync: SuccessState<bool>(data: true),
        ));
      }
      emit(state.copyWith(
        sendSync: InitialState<bool>(),
      ));
    } on Exception catch (e) {
      emit(state.copyWith(
          sendSync: GeneralErrorState(e: e, error: e.toString())));
    }
  }

  Future<void> initHarvest() async {
    try {
      emit(state.copyWith(
        listHarvest: LoadingState<List<Harvest>>(),
        listHistory: LoadingState<List<Tree>>(),
      ));
      final harvest = await _crudRepository.getHarvestResult();
      final history = await _crudRepository.getHistory();

      emit(state.copyWith(
        listHarvest: SuccessState<List<Harvest>>(data: harvest),
        listHistory: SuccessState<List<Tree>>(data: history),
      ));
    } on Exception catch (e) {
      emit(state.copyWith(
        listHarvest: GeneralErrorState(e: e, error: e.toString()),
        listHistory: GeneralErrorState(e: e, error: e.toString()),
      ));
    }
  }

  Future<void> initMarker() async {
    try {
      emit(state.copyWith(
        listTree: LoadingState<List<Tree>>(),
        listRoute: LoadingState<List<Tree>>(),
        listHistory: LoadingState<List<Tree>>(),
        listUsers: LoadingState<List<User>>(),
      ));
      final tree = await _crudRepository.getTree();
      final route = await _crudRepository.getRoute();
      final history = await _crudRepository.getHistory();
      final users = await _crudRepository.getUsers();

      emit(state.copyWith(
        listTree: SuccessState<List<Tree>>(data: tree),
        listRoute: SuccessState<List<Tree>>(data: route),
        listHistory: SuccessState<List<Tree>>(data: history),
        listUsers: SuccessState<List<User>>(data: users),
      ));
    } on Exception catch (e) {
      emit(state.copyWith(
        listTree: GeneralErrorState(e: e, error: e.toString()),
        listRoute: GeneralErrorState(e: e, error: e.toString()),
        listHistory: GeneralErrorState(e: e, error: e.toString()),
        listUsers: GeneralErrorState(e: e, error: e.toString()),
      ));
    }
  }

  Future<void> getUsers() async {
    try {
      emit(state.copyWith(
        listTree: LoadingState<List<Tree>>(),
        listRoute: LoadingState<List<Tree>>(),
        listHistory: LoadingState<List<Tree>>(),
      ));
      final tree = await _crudRepository.getTree();
      final route = await _crudRepository.getRoute();
      final history = await _crudRepository.getHistory();

      emit(state.copyWith(
        listTree: SuccessState<List<Tree>>(data: tree),
        listRoute: SuccessState<List<Tree>>(data: route),
        listHistory: SuccessState<List<Tree>>(data: history),
      ));
    } on Exception catch (e) {
      emit(state.copyWith(
        listTree: GeneralErrorState(e: e, error: e.toString()),
        listRoute: GeneralErrorState(e: e, error: e.toString()),
        listHistory: GeneralErrorState(e: e, error: e.toString()),
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
