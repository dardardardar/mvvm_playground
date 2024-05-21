import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:injectable/injectable.dart';
import 'package:mvvm_playground/features/cubit/auth_cubit_data.dart';
import 'package:mvvm_playground/features/repository/auth_repo.dart';
import 'package:mvvm_playground/features/state/base_state.dart';

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
}
