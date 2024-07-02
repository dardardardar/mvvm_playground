import 'package:mvvm_playground/features/models/tree_model.dart';
import 'package:mvvm_playground/features/state/base_state.dart';

class MapsData {
  final BaseState listTree;
  final BaseState listRoute;
  final BaseState listHistory;
  final BaseState listHarvest;
  final BaseState listUsers;
  final BaseState sendQty;
  final BaseState sendSync;

  MapsData(
      {BaseState? listTree,
      BaseState? listRoute,
      BaseState? listHistory,
      BaseState? listHarvest,
      BaseState? listUsers,
      BaseState? sendSync,
      BaseState? sendQty})
      : listTree = listTree ?? InitialState<Tree>(),
        listRoute = listRoute ?? InitialState<Tree>(),
        listHarvest = listHarvest ?? InitialState<Harvest>(),
        listHistory = listHistory ?? InitialState<Tree>(),
        listUsers = listUsers ?? InitialState<User>(),
        sendSync = sendSync ?? InitialState<bool>(),
        sendQty = sendQty ?? InitialState<bool>();

  MapsData copyWith({
    BaseState? listTree,
    BaseState? listRoute,
    BaseState? listHarvest,
    BaseState? listHistory,
    BaseState? listUsers,
    BaseState? sendSync,
    BaseState? sendQty,
  }) {
    return MapsData(
        listTree: listTree ?? this.listTree,
        listRoute: listRoute ?? this.listRoute,
        listHarvest: listHarvest ?? this.listHarvest,
        listHistory: listHistory ?? this.listHistory,
        listUsers: listUsers ?? this.listUsers,
        sendSync: sendSync ?? this.sendSync,
        sendQty: sendQty ?? this.sendQty);
  }
}
