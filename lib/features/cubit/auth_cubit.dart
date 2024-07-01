import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:injectable/injectable.dart';
import 'package:mvvm_playground/features/cubit/auth_cubit_data.dart';
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
      if (authResponse is SuccessState<String>) {
        final ressData = (authResponse as SuccessState<String>).data;
        if (ressData == 'success') {
          await _authRepository.checkDatabase();
          emit(state.copyWith(
            processAuth: SuccessState<bool>(data: true),
            checkAuth: SuccessState<bool>(data: true),
          ));
        } else if (ressData == 'expired') {
          emit(state.copyWith(
            processAuth:
                GeneralErrorState(e: Exception(), error: 'Aplikasi Kadarluasa'),
          ));
        } else {
          emit(state.copyWith(
            processAuth: GeneralErrorState(
                e: Exception(), error: 'User tidak diketahui'),
          ));
        }
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
      final check = await _authRepository.getOnTrial();
      if (check == true) {
        emit(state.copyWith(
          checkTrial: SuccessState<String>(data: 'Full'),
        ));
      } else {
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
