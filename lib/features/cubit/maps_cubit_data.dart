import 'package:mvvm_playground/features/models/tree_model.dart';
import 'package:mvvm_playground/features/state/base_state.dart';

class MapsData {
  final BaseState listTree;
  final BaseState listRoute;
  final BaseState sendQty;

  MapsData({BaseState? listTree, BaseState? listRoute, BaseState? sendQty})
      : listTree = listTree ?? InitialState<Tree>(),
        listRoute = listRoute ?? InitialState<Routes>(),
        sendQty = sendQty ?? InitialState<bool>();

  MapsData copyWith({
    BaseState? listTree,
    BaseState? listRoute,
    BaseState? sendQty,
  }) {
    return MapsData(
        listTree: listTree ?? this.listTree,
        listRoute: listRoute ?? this.listRoute,
        sendQty: sendQty ?? this.sendQty);
  }
}
