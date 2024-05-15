import 'package:injectable/injectable.dart';
import 'package:mvvm_playground/features/models/tree_model.dart';
import 'package:mvvm_playground/features/state/base_state.dart';
import 'package:mvvm_playground/helper/api.dart';

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
    } on Exception {
      rethrow;
    }
  }

  Future<List<Route>> getRoute() async {
    try {
      final result =
          await Api.get('wp-json/sinar/v1/bum/locations', data: {"type": '2'});
      final response = result.data;
      if (response != null) {
        final routeData =
            (response as List<dynamic>).map((e) => Route.fromJson(e));
        return routeData.toList();
      } else {
        return [];
      }
    } on Exception {
      rethrow;
    }
  }

  Future<BaseState> sendQty(double qty, Tree tree) async {
    try {
      final result = await Api.post('wp-json/sinar/v1/bum/input', {
        "qty": qty,
        "id_user": '2',
        "id_tree": tree.idTree,
        "lat": tree.position.latitude,
        "long": tree.position.longitude,
      });
      final response = result.data;
      if (response != null) {
        return SuccessState(data: result);
      } else {
        return GeneralErrorState(e: Exception(), error: response);
      }
    } on Exception {
      rethrow;
    }
  }
}
