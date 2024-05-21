import 'package:mvvm_playground/features/state/base_state.dart';

class authData {
  final BaseState sendAuth;

  authData({BaseState? sendAuth}) : sendAuth = sendAuth ?? InitialState<bool>();

  authData copyWith({
    BaseState? sendAuth,
  }) {
    return authData(sendAuth: sendAuth ?? this.sendAuth);
  }
}
