import 'package:mvvm_playground/features/state/base_state.dart';

class authData {
  final BaseState checkAuth;
  final BaseState processAuth;
  final BaseState checkTrial;

  authData(
      {BaseState? checkAuth, BaseState? checkTrial, BaseState? processAuth})
      : checkAuth = checkAuth ?? InitialState(),
        processAuth = processAuth ?? InitialState(),
        checkTrial = checkTrial ?? SuccessState<String>(data: 'Full');

  authData copyWith({
    BaseState? checkAuth,
    BaseState? processAuth,
    BaseState? checkTrial,
  }) {
    return authData(
        checkAuth: checkAuth ?? this.checkAuth,
        processAuth: processAuth ?? this.processAuth,
        checkTrial: checkTrial ?? this.checkTrial);
  }
}
