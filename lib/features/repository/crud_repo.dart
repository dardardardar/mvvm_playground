import 'package:injectable/injectable.dart';
import 'package:mvvm_playground/const/enums.dart';
import 'package:mvvm_playground/features/models/tree_model.dart';
import 'package:mvvm_playground/features/models/users_model.dart';
import 'package:mvvm_playground/features/response/constants.dart';
import 'package:mvvm_playground/features/state/base_state.dart';
import 'package:mvvm_playground/helper/api.dart';
import 'package:mvvm_playground/helper/logger.dart';
import 'package:mvvm_playground/helper/sql_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

@injectable
class CRUDRepository {
  Future<BaseState> Installation(status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id_user = prefs.getString("id_user").toString();
      var resultAll;
      if (status == 'online') {
        resultAll = await Api.get('wp-json/sinar/v1/bum/all');
        resultAll = resultAll.data;
      } else {
        resultAll = responseStatic;
      }

      final List<dynamic> responseUsers;
      final List<dynamic> responseSchedule;
      final List<dynamic> responseLocation;
      final List<dynamic> responseRoute;
      final List<dynamic> responseHarvest;
      if (resultAll['status'] != 'failed') {
        if (status == 'offline') {
          responseUsers = resultAll['user'] as List<dynamic>;
          responseSchedule = resultAll['schedule'] as List<dynamic>;
          responseLocation = resultAll['location'] as List<dynamic>;
          responseRoute = resultAll['route'] as List<dynamic>;
          responseHarvest = [];
        } else {
          responseUsers = resultAll['user'];
          responseSchedule = resultAll['schedule'];
          responseLocation = resultAll['location'];
          responseRoute = resultAll['route'];
          responseHarvest = resultAll['forage_result'];
        }

        await DatabaseService.instance.truncate('users');
        await DatabaseService.instance.truncate('trees');
        await DatabaseService.instance.truncate('routes');
        await DatabaseService.instance.truncate('schedules');
        await DatabaseService.instance.delete(1, 'harvest', 'tipe');

        for (var i = 0; responseUsers.length > i; i++) {
          await DatabaseService.instance.insert(
              Users(
                id_user: responseUsers[i]['id'].toString(),
                name: responseUsers[i]['name'].toString(),
                username: responseUsers[i]['username'].toString(),
                rnc_panen_janjang:
                    responseUsers[i]['rnc_panen_janjang'].toString(),
                rnc_panen_kg: responseUsers[i]['rnc_panen_kg'].toString(),
                rnc_penghasilan: responseUsers[i]['rnc_penghasilan'].toString(),
              ).toMap(),
              'users');
        }

        for (var i = 0; responseLocation.length > i; i++) {
          var id_trees = responseLocation[i]['id'].toString();
          var names = responseLocation[i]['name'].toString();
          var lats = responseLocation[i]['lat'].toString();
          var longs = responseLocation[i]['long'].toString();
          var nomor = responseLocation[i]['nomor'].toString();
          var baris = responseLocation[i]['lat'].toString();
          var ancak = responseLocation[i]['ancak'].toString();
          var blok = responseLocation[i]['blok'].toString();
          var estate = responseLocation[i]['estate'].toString();
          var afd = responseLocation[i]['afd'].toString();
          var keterangan = responseLocation[i]['keterangan'].toString();
          await DatabaseService.instance.insert(
              sendTree(
                id_tree: id_trees,
                name: names,
                lat: lats,
                long: longs,
                nomor: nomor,
                baris: baris,
                ancak: ancak,
                blok: blok,
                estate: estate,
                afd: afd,
                keterangan: keterangan,
              ).toMap(),
              'trees');
        }

        for (var i = 0; responseRoute.length > i; i++) {
          await DatabaseService.instance.insert(
              sendRoute(
                      id_user: responseRoute[i]['id_user'].toString(),
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
                      id_user: responseSchedule[i]['id_user'].toString(),
                      id_tree: responseSchedule[i]['id_tree'].toString(),
                      lat: responseSchedule[i]['lat'].toString(),
                      long: responseSchedule[i]['long'].toString(),
                      name: responseSchedule[i]['name'].toString(),
                      nomor: responseSchedule[i]['nomor'].toString(),
                      baris: responseSchedule[i]['baris'].toString(),
                      ancak: responseSchedule[i]['ancak'].toString(),
                      blok: responseSchedule[i]['blok'].toString(),
                      estate: responseSchedule[i]['estate'].toString(),
                      afd: responseSchedule[i]['afd'].toString(),
                      keterangan: responseSchedule[i]['keterangan'].toString())
                  .toMap(),
              'schedules');
        }
        if (status == 'online') {
          for (var i = 0; responseHarvest.length > i; i++) {
            await DatabaseService.instance.insert(
                sendHistoryQty(
                  id_user: responseHarvest[i]['id_user'].toString(),
                  id_tree: (responseHarvest[i]['id_tree'] == null)
                      ? ''
                      : responseHarvest[i]['id_tree'],
                  lat: responseHarvest[i]['lat'].toString(),
                  name: (responseHarvest[i]['name'] == null)
                      ? ''
                      : responseHarvest[i]['id_tree'].toString(),
                  long: responseHarvest[i]['long'].toString(),
                  qty: double.parse(responseHarvest[i]['qty']),
                  id_harvest: responseHarvest[i]['id'].toString(),
                  tipe: '1',
                ).toMap(),
                'harvest');
          }
        }
        return SuccessState<bool>(data: true);
      } else {
        return GeneralErrorState(e: Exception('error'));
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

  Future<List<Tree>> getTree() async {
    final prefs = await SharedPreferences.getInstance();
    final id_user = prefs.getString("id_user").toString();
    try {
      final response = await DatabaseService.instance
          .queryAllRows('schedules', 'id_user', id_user);

      if (response.isNotEmpty) {
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
      if (response.isNotEmpty) {
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
    final prefs = await SharedPreferences.getInstance();
    final id_user = prefs.getString("id_user").toString();
    try {
      final result = await Api.get('wp-json/sinar/v1/bum/history',
          data: {"id_user": id_user});
      final responseHarvestData = result.data;
      final status = responseHarvestData['status'];
      if (status == 'ok') {
        final data = responseHarvestData['data'] as List<dynamic>;
        final historyList = data.map((e) => Tree.fromJson(e));
        return historyList.toList();
      } else {
        return [];
      }
    } on Exception catch (e, s) {
      final response = await DatabaseService.instance
          .queryAllRows('harvest', 'id_user', id_user);
      if (response.isNotEmpty) {
        final historyList = response.map((e) => Tree.fromJson(e));
        return historyList.toList();
      } else {
        return [];
      }
    }
  }

  Future<List<User>> getUsers() async {
    try {
      final response = await DatabaseService.instance.queryRow('users');
      if (response.isNotEmpty) {
        final usersData = response.map((e) => User.fromJson(e));
        return usersData.toList();
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

      await DatabaseService.instance.insert(
          sendRoute(
                  id_user: id_user,
                  lat: lat,
                  long: long,
                  tipe: '2',
                  date: DateTime.now().toIso8601String())
              .toMap(),
          'routes');
      final response = result.data;
      if (response != null) {
        return SuccessState(data: result);
      } else {
        return GeneralErrorState(e: Exception(), error: response);
      }
    } on Exception {
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
      final addQty = await Api.post('wp-json/sinar/v1/bum/manual-input', {
        "id_user": prefs.getString('id_user').toString(),
        "data": [
          {
            "qty": (qty! < 1) ? 1 : qty,
            "id_tree": tree.idTree.isEmpty ? '' : tree.idTree,
            "lat": tree.position.latitude.toString(),
            "long": tree.position.longitude.toString(),
            "date": DateTime.now().toIso8601String()
          },
        ],
      });

      final resultResponse = addQty.data;

      if (resultResponse['status'] == 'success') {
        final response = await DatabaseService.instance.insert(
            sendHistoryQty(
              id_user: prefs.getString('id_user').toString(),
              id_tree: tree.idTree.isEmpty ? '' : tree.idTree,
              lat: tree.position.latitude.toString(),
              name: tree.idTree.isEmpty ? '' : tree.name,
              long: tree.position.longitude.toString(),
              qty: (qty! < 1) ? 1 : qty,
              tipe: '1',
              id_harvest: resultResponse['inserted'][0]['id'].toString(),
            ).toMap(),
            'harvest');

        return SuccessState(data: response);
      } else {
        return GeneralErrorState(
            e: Exception(), error: resultResponse['status']);
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

  Future<BaseState> sendSyncAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id_user = prefs.getString("id_user").toString();

      final getDataRoutes = await DatabaseService.instance
          .queryAllRowsDobule('routes', 'tipe', 'id_user', '1', id_user);
      if (getDataRoutes.length > 0) {
        var arrRoutes = [];
        for (var i = 0; getDataRoutes.length > i; i++) {
          arrRoutes.add({
            "lat": getDataRoutes[i]['lat'],
            "long": getDataRoutes[i]['long']
          });
        }

        var sendArrayRoute = {
          "id_user": id_user,
          "data": arrRoutes,
        };

        await Api.post('wp-json/sinar/v1/bum/manual_history', sendArrayRoute);

        await DatabaseService.instance
            .update({'tipe': '2'}, 'routes', 'id_user', id_user);
      }
      final getDataHarvest = await DatabaseService.instance
          .queryAllRowsDobule('harvest', 'tipe', 'id_user', '1', id_user);
      if (getDataHarvest.length > 0) {
        var arrHarvest = [];
        for (var i = 0; getDataHarvest.length > i; i++) {
          arrHarvest.add({
            "qty": getDataHarvest[i]['qty'],
            "id_tree": getDataHarvest[i]['id_tree'],
            "lat": getDataHarvest[i]['lat'],
            "long": getDataHarvest[i]['long'],
            "date": getDataHarvest[i]['created_at']
          });
        }
        var sendArrayHarvest = {
          "id_user": id_user,
          "data": arrHarvest,
        };

        await Api.post('wp-json/sinar/v1/bum/manual-input', sendArrayHarvest);
        await DatabaseService.instance
            .queryAllRowsDobule('harvest', 'tipe', 'id_user', '1', id_user);

        await DatabaseService.instance
            .update({'tipe': '2'}, 'harvest', 'id_user', id_user);
      }
      return SuccessState<bool>(data: true);
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
