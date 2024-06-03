import 'package:mvvm_playground/features/models/tree_model.dart';
import 'package:mvvm_playground/features/state/base_state.dart';

class MapsData {
  final BaseState listTree;
  final BaseState listRoute;
  final BaseState listHistory;
  final BaseState sendQty;
  final BaseState sendSync;

  MapsData(
      {BaseState? listTree,
      BaseState? listRoute,
      BaseState? listHistory,
      BaseState? sendSync,
      BaseState? sendQty})
      : listTree = listTree ?? InitialState<Tree>(),
        listRoute = listRoute ?? InitialState<Tree>(),
        listHistory = listHistory ?? InitialState<Tree>(),
        sendSync = sendSync ?? InitialState<bool>(),
        sendQty = sendQty ?? InitialState<bool>();

  MapsData copyWith({
    BaseState? listTree,
    BaseState? listRoute,
    BaseState? listHistory,
    BaseState? sendSync,
    BaseState? sendQty,
  }) {
    return MapsData(
        listTree: listTree ?? this.listTree,
        listRoute: listRoute ?? this.listRoute,
        listHistory: listHistory ?? this.listHistory,
        sendSync: sendSync ?? this.sendSync,
        sendQty: sendQty ?? this.sendQty);
  }
}
