import 'package:injectable/injectable.dart';
import 'package:mvvm_playground/const/enums.dart';
import 'package:mvvm_playground/features/state/base_state.dart';
import 'package:mvvm_playground/helper/api.dart';
import 'package:mvvm_playground/helper/logger.dart';
import 'package:mvvm_playground/helper/sql_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/tree_model.dart';

@injectable
class AuthRepository {
  Future<BaseState> Login(String username) async {
    try {
      //Offline
      // final response = await DatabaseService.instance
      //     .queryAllRows('users', 'username', username);
      // if (response.isNotEmpty) {
      //   final rss = response[0];
      //   final prefs = await SharedPreferences.getInstance();
      //   await prefs.setString('id_user', rss['id_user'].toString());
      //   await prefs.setString('name', rss['username']);
      //   await prefs.setString('username', rss['username']);
      //   await prefs.setString('rnc_panen_kg', rss['rnc_panen_kg'].toString());
      //   await prefs.setString(
      //       'rnc_panen_janjang', rss['rnc_panen_janjang'].toString());
      //   await prefs.setString(
      //       'rnc_penghasilan', rss['rnc_penghasilan'].toString());
      //   return SuccessState(data: response);
      // } else {
      final result =
          await Api.post('wp-json/sinar/v1/bum/login', {"username": username});
      final response = result.data;
      if (response['message'] != 'No user') {
        final rss = response['user'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('id_user', rss['id'].toString());
        await prefs.setString('name', rss['username']);
        await prefs.setString('username', rss['username']);
        await prefs.setString('rnc_panen_kg', rss['rnc_panen_kg'].toString());
        await prefs.setString(
            'rnc_panen_janjang', rss['rnc_panen_janjang'].toString());
        await prefs.setString(
            'rnc_penghasilan', rss['rnc_penghasilan'].toString());

        if (response['is_expired'] == false) {
          return SuccessState<String>(data: 'success');
        } else {
          return SuccessState<String>(data: 'expired');
        }
      } else {
        return SuccessState<String>(data: 'notfound');
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

  Future<bool> getOnTrial() async {
    try {
      final result = await Api.get('wp-json/sinar/v1/bum/ontrial');
      final response = result.data;
      return response.toString() == 'true';
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

  Future<BaseState> checkDatabase() async {
    try {
      final response = await DatabaseService.instance.queryRow('users');
      if (response.isNotEmpty) {
        return SuccessState(data: 'Berhasil');
      } else {
        return GeneralErrorState(e: Exception(), error: 'Error');
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
      prefs.remove('rnc_panen_kg');
      prefs.remove('rnc_panen_janjang');
      prefs.remove('rnc_penghasilan');
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
