import 'package:injectable/injectable.dart';
import 'package:mvvm_playground/features/state/base_state.dart';
import 'package:mvvm_playground/helper/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

@injectable
class AuthRepository {
  Future<BaseState> Login(String username) async {
    try {
      final result =
          await Api.post('wp-json/sinar/v1/bum/login', {"username": username});
      final response = result.data;
      if (response['message'] != 'No user') {
        final rss = response['user'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('id_user', rss['id']);
        await prefs.setString('name', rss['name']);
        await prefs.setString('username', rss['username']);
        return SuccessState(data: result);
      } else {
        throw Exception('Data tidak valid');
      }
    } on Exception {
      rethrow;
    }
  }
}
