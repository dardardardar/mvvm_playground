import 'package:injectable/injectable.dart';
import 'package:mvvm_playground/const/enums.dart';
import 'package:mvvm_playground/features/models/tree_model.dart';
import 'package:mvvm_playground/features/state/base_state.dart';
import 'package:mvvm_playground/helper/api.dart';
import 'package:mvvm_playground/helper/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

@injectable
class CRUDRepository {
  Future<List<Tree>> getTree() async {
    try {
      final result =
          await Api.get('wp-json/sinar/v1/bum/locations', data: {"type": '1'});
      final response = result.data;
      if (response != null) {
        final treeData =
            (response as List<dynamic>).map((e) => Tree.fromJson(e));
        return treeData.toList();
      } else {
        return [];
      }
    } on Exception catch (e, s) {
      Logger.log(
          status: LogStatus.Error,
          className: CRUDRepository().toString(),
          function: '$this',
          exception: e,
          stackTrace: s);
      rethrow;
    }
  }

  Future<List<Tree>> getRoute() async {
    try {
      final result = await Api.get('wp-json/sinar/v1/bum/history');
      final response = result.data;
      if (response != null) {
        final routeData =
            (response as List<dynamic>).map((e) => Tree.fromJson(e));
        return routeData.toList();
      } else {
        return [];
      }
    } on Exception catch (e, s) {
      Logger.log(
          status: LogStatus.Error,
          className: CRUDRepository().toString(),
          function: '$this',
          exception: e,
          stackTrace: s);
      rethrow;
    }
  }

  Future<BaseState> sendHistory(String lat, String long) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final result = await Api.post('wp-json/sinar/v1/bum/listen',
          {"id_user": prefs.getString("id_user"), "lat": lat, "long": long});
      final response = result.data;
      if (response != null) {
        return SuccessState(data: result);
      } else {
        return GeneralErrorState(e: Exception(), error: response);
      }
    } on Exception catch (e, s) {
      Logger.log(
          status: LogStatus.Error,
          function: '$this',
          exception: e,
          stackTrace: s);
      rethrow;
    }
  }

  Future<BaseState> sendQty(double? qty, Tree tree) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final result = await Api.post('wp-json/sinar/v1/bum/input', {
        "qty": qty,
        "id_user": prefs.getString("id_usera"),
        "id_tree": tree.idTree.isEmpty ? null : tree.idTree,
        "lat": tree.position.latitude,
        "long": tree.position.longitude,
      });
      final response = result.data;
      if (response != null) {
        return SuccessState(data: result);
      } else {
        return GeneralErrorState(e: Exception(), error: response);
      }
    } on Exception catch (e, s) {
      Logger.log(
          status: LogStatus.Error,
          className: CRUDRepository().toString(),
          exception: e,
          stackTrace: s);
      rethrow;
    }
  }
}
