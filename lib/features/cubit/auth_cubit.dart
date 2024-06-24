import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:injectable/injectable.dart';
import 'package:mvvm_playground/features/cubit/auth_cubit_data.dart';
import 'package:mvvm_playground/features/cubit/maps_cubit.dart';
import 'package:mvvm_playground/features/repository/auth_repo.dart';
import 'package:mvvm_playground/features/state/base_state.dart';
import 'package:mvvm_playground/helper/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

@injectable
class AuthCubit extends Cubit<authData> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(authData());

  Future<void> sendAuth(String username) async {
    try {
      emit(state.copyWith(
        sendAuth: LoadingState<bool>(),
      ));

      final authResponse = await _authRepository.Login(username);
      if (authResponse is SuccessState<dynamic>) {
        await getIt.get<MapsCubit>().instalation('offline');
        emit(state.copyWith(
          sendAuth: SuccessState<bool>(data: true),
        ));
        emit(state.copyWith(
          sendAuth: InitialState<bool>(),
        ));
      }
    } on Exception catch (e) {
      emit(state.copyWith(
        sendAuth: GeneralErrorState(e: e, error: e.toString()),
      ));
    }
  }

  Future<void> initialLogin() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? id_user = prefs.getString('id_user');
      if (id_user == null) {
        emit(state.copyWith(
          sendAuth: InitialState(),
        ));
      } else {
        emit(state.copyWith(
          sendAuth: SuccessState<bool>(data: true),
        ));
      }
    } on Exception catch (e) {
      emit(state.copyWith(
        sendAuth: GeneralErrorState(e: e, error: e.toString()),
      ));
    }
  }

  Future<void> logout() async {
    try {
      emit(state.copyWith(
        sendAuth: InitialState(),
      ));
    } on Exception catch (e) {
      emit(state.copyWith(
        sendAuth: GeneralErrorState(e: e, error: e.toString()),
      ));
    }
  }
}
