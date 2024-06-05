import 'package:injectable/injectable.dart';
import 'package:mvvm_playground/const/enums.dart';
import 'package:mvvm_playground/features/state/base_state.dart';
import 'package:mvvm_playground/helper/api.dart';
import 'package:mvvm_playground/helper/logger.dart';
import 'package:mvvm_playground/helper/sql_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

@injectable
class AuthRepository {
  Future<BaseState> Login(String username) async {
    try {
      //Offline
      final response = await DatabaseService.instance
          .queryAllRows('users', 'username', username);
      if (response.isNotEmpty) {
        final rss = response[0];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('id_user', rss['id_user'].toString());
        await prefs.setString('name', rss['username']);
        await prefs.setString('username', rss['username']);
        return SuccessState(data: response);
      } else {
        final result = await Api.post(
            'wp-json/sinar/v1/bum/login', {"username": username});
        final response = result.data;
        if (response['message'] != 'No user') {
          final rss = response['user'];
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('id_user', rss['id'].toString());
          await prefs.setString('name', rss['username']);
          await prefs.setString('username', rss['username']);
          return SuccessState(data: response);
        }
        throw Exception('Data tidak valid');
      }
    } on Exception catch (e, s) {
      Logger.log(
          status: LogStatus.Error,
          className: AuthRepository().toString(),
          function: '$this',
          exception: e,
          stackTrace: s);
      rethrow;
    }
  }

  Future<BaseState> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.remove('id_user');
      prefs.remove('name');
      prefs.remove('username');
      return SuccessState<bool>(data: true);
    } on Exception catch (e, s) {
      Logger.log(
          status: LogStatus.Error,
          className: AuthRepository().toString(),
          function: '$this',
          exception: e,
          stackTrace: s);
      rethrow;
    }
  }
}
