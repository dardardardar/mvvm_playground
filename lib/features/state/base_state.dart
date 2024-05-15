class BaseState {}

class LoadingState<T> extends BaseState {}

class InitialState<T> extends BaseState {}

class SuccessState<T> extends BaseState {
  T data;
  SuccessState({required this.data});
}

class GeneralErrorState<T> extends BaseState {
  Exception e;
  T? data;
  String error;
  GeneralErrorState({required this.e, this.error = '', this.data});
}

class NetworkErrorState extends GeneralErrorState {
  NetworkErrorState()
      : super(
            e: Exception('No internet connection!'),
            error: 'No internet connection!');
}

class InvalidCredentialState extends GeneralErrorState {
  InvalidCredentialState({super.error})
      : super(e: Exception('Credential not valid'));
}

class NotRegisteredEmailState<T> extends GeneralErrorState<T?> {
  NotRegisteredEmailState({required super.e, super.error, super.data});
}

class NotApprovedEmailState<T> extends GeneralErrorState<T?> {
  NotApprovedEmailState({required super.e, super.error, super.data});
}

class NotRegisteredEmailSSOState<T> extends GeneralErrorState<T?> {
  NotRegisteredEmailSSOState({required super.e, super.error, super.data});
}

class SSOErrorState extends GeneralErrorState {
  SSOErrorState({required super.e, super.error});
}

class AccountPendingApprovalState extends GeneralErrorState {
  AccountPendingApprovalState({required super.e, super.error});
}

class AccountNotApprovedState extends GeneralErrorState {
  AccountNotApprovedState({required super.e, super.error});
}

class InvalidInputState extends GeneralErrorState {
  InvalidInputState({required super.e, super.error});
}

class ServerErrorState extends GeneralErrorState {
  ServerErrorState({required super.e, super.error});
}

class LoadedState<T> extends SuccessState {
  LoadedState({data}) : super(data: data);
}
