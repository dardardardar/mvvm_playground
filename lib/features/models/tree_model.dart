import 'package:latlong2/latlong.dart';

class Tree {
  final String name;
  final String idTree;
  final LatLng position;
  final String qty;

  Tree(
      {required this.name,
      required this.idTree,
      required this.position,
      this.qty = '0'});

  factory Tree.fromJson(data) {
    return Tree(
        name: data['name'].toString(),
        idTree: data['id'].toString(),
        qty: data['qty'].toString(),
        position:
            LatLng(double.parse(data['lat']), double.parse(data['long'])));
  }
}

class User {
  final String id_user;
  final String name;
  final String username;

  User({
    required this.id_user,
    required this.name,
    required this.username,
  });

  factory User.fromJson(data) {
    return User(
      id_user: data['id_user'].toString(),
      name: data['name'].toString(),
      username: data['username'].toString(),
    );
  }
}

class Routes {
  final LatLng position;

  Routes({required this.position});

  factory Routes.fromJson(data) {
    return Routes(
        position:
            LatLng(double.parse(data['lat']), double.parse(data['long'])));
  }
}
