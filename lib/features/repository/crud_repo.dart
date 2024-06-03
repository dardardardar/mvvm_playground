import 'package:injectable/injectable.dart';
import 'package:mvvm_playground/const/enums.dart';
import 'package:mvvm_playground/features/models/tree_model.dart';
import 'package:mvvm_playground/features/models/users_model.dart';
import 'package:mvvm_playground/features/state/base_state.dart';
import 'package:mvvm_playground/helper/api.dart';
import 'package:mvvm_playground/helper/logger.dart';
import 'package:mvvm_playground/helper/sql_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

@injectable
class CRUDRepository {
  // insert data local
  Future<BaseState> Installation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id_user = prefs.getString("id_user").toString();

      final resultAll =
          await Api.get('wp-json/sinar/v1/bum/all', data: {"id_user": id_user});

      if (resultAll.data['status'] != 'failed') {
        final responseUsers = resultAll.data['user'];
        final responseSchedule = resultAll.data['schedule'];
        final responseLocation = resultAll.data['location'];
        final responseRoute = resultAll.data['route'];

        await DatabaseService.instance.truncate('users');
        await DatabaseService.instance.truncate('trees');
        await DatabaseService.instance.truncate('routes');
        await DatabaseService.instance.truncate('schedules');

        for (var i = 0; responseUsers.length > i; i++) {
          await DatabaseService.instance.insert(
              Users(
                      id_user: responseUsers[i]['id'].toString(),
                      name: responseUsers[i]['name'].toString(),
                      username: responseUsers[i]['username'].toString())
                  .toMap(),
              'users');
        }

        for (var i = 0; responseLocation.length > i; i++) {
          await DatabaseService.instance.insert(
              sendTree(
                id_tree: responseLocation[i]['id'].toString(),
                name: responseLocation[i]['name'].toString(),
                lat: responseLocation[i]['lat'].toString(),
                long: responseLocation[i]['long'].toString(),
              ).toMap(),
              'trees');
        }

        for (var i = 0; responseRoute.length > i; i++) {
          await DatabaseService.instance.insert(
              sendRoute(
                      id_user: id_user,
                      lat: responseRoute[i]['lat'].toString(),
                      long: responseRoute[i]['long'].toString(),
                      tipe: '2',
                      date: DateTime.now().toIso8601String())
                  .toMap(),
              'routes');
        }

        for (var i = 0; responseSchedule.length > i; i++) {
          await DatabaseService.instance.insert(
              sendSchedule(
                id_user: id_user,
                id_tree: responseSchedule[i]['id_tree'].toString(),
                lat: responseSchedule[i]['lat'].toString(),
                long: responseSchedule[i]['long'].toString(),
                name: responseSchedule[i]['name'].toString(),
              ).toMap(),
              'schedules');
        }
        return SuccessState<bool>(data: true);
      } else {
        return GeneralErrorState(e: Exception('error'));
      }
    } on Exception catch (e) {
      rethrow;
    }
  }

  Future<List<Tree>> getTree() async {
    try {
      final response = await DatabaseService.instance.queryRow('trees');
      print(response);

      if (response is List<dynamic> && response.isNotEmpty) {
        final treeData = response.map((e) => Tree.fromJson(e));
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
      final response = await DatabaseService.instance.queryRow('routes');
      if (response is List<dynamic> && response.isNotEmpty) {
        final routeData = response.map((e) => Tree.fromJson(e));
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

  Future<List<Tree>> getHistory() async {
    try {
      final response = await DatabaseService.instance.queryRow('harvest');
      if (response is List<dynamic> && response.isNotEmpty) {
        final harvestData = response.map((e) => Tree.fromJson(e));
        return harvestData.toList();
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
    final prefs = await SharedPreferences.getInstance();
    final id_user = prefs.getString("id_user").toString();

    try {
      final result = await Api.post('wp-json/sinar/v1/bum/listen', {
        "id_user": prefs.getString("id_user"),
        "lat": lat,
        "long": long,
      });
      final response = result.data;
      if (response != null) {
        return SuccessState(data: result);
      } else {
        return GeneralErrorState(e: Exception(), error: response);
      }
    } on Exception catch (e) {
      await DatabaseService.instance.insert(
          sendRoute(
                  id_user: id_user,
                  lat: lat,
                  long: long,
                  tipe: '1',
                  date: DateTime.now().toIso8601String())
              .toMap(),
          'routes');
      return InitialState();
    }
  }

  Future<BaseState> sendQty(double? qty, Tree tree) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final response = await DatabaseService.instance.insert(
          sendHistoryQty(
            id_user: prefs.getString('id_user').toString(),
            id_tree: tree.idTree.isEmpty ? '' : tree.idTree,
            lat: tree.position.latitude.toString(),
            long: tree.position.longitude.toString(),
            qty: qty ?? 0.0,
          ).toMap(),
          'harvest');

      if (response != null) {
        return SuccessState(data: response);
      } else {
        return GeneralErrorState(e: Exception(), error: response.toString());
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
