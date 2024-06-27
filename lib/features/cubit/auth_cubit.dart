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
        processAuth: LoadingState<bool>(),
      ));

      final authResponse = await _authRepository.Login(username);
      if (authResponse is SuccessState<dynamic>) {
        final checkDatabase = await _authRepository.checkDatabase();
        if (checkDatabase is ErrorState) {
          await getIt.get<MapsCubit>().instalation('offline');
        }
        emit(state.copyWith(
          processAuth: SuccessState<bool>(data: true),
          checkAuth: SuccessState<bool>(data: true),
        ));
        emit(state.copyWith(
          processAuth: InitialState(),
        ));
      } else {
        emit(state.copyWith(
          checkAuth: InitialState(),
        ));
      }
    } on Exception catch (e) {
      emit(state.copyWith(
        processAuth: GeneralErrorState(e: e, error: e.toString()),
        checkAuth: GeneralErrorState(e: e, error: e.toString()),
      ));
    }
  }

  Future<void> initialLogin() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? id_user = prefs.getString('id_user');
      if (id_user == null) {
        emit(state.copyWith(
          checkAuth: InitialState(),
        ));
      } else {
        emit(state.copyWith(
          checkAuth: SuccessState<bool>(data: true),
        ));
      }
    } on Exception catch (e) {
      emit(state.copyWith(
        checkAuth: GeneralErrorState(e: e, error: e.toString()),
      ));
    }
  }

  Future<void> logout() async {
    try {
      await _authRepository.logout();
      emit(state.copyWith(
        checkAuth: InitialState(),
      ));
    } on Exception catch (e) {
      emit(state.copyWith(
        checkAuth: GeneralErrorState(e: e, error: e.toString()),
      ));
    }
  }

  Future<void> checkTrial() async {
    try {
      DateTime now = DateTime.now();
      DateTime date1 = DateTime(2024, 10, 5);
      DateTime date2 = DateTime(now.year, now.month, now.day);
      bool isBefore = date2.isBefore(date1);
      if (isBefore != true) {
        getIt.get<AuthCubit>().logout();
        emit(state.copyWith(
            checkTrial: SuccessState<String>(data: 'Trial'),
            processAuth: InitialState(),
            checkAuth: InitialState()));
      }
    } on Exception catch (e) {
      emit(state.copyWith(
        checkTrial: GeneralErrorState(e: e, error: e.toString()),
      ));
    }
  }
}
