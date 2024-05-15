import 'package:latlong2/latlong.dart';

class Tree {
  final String name;
  final String idTree;
  final LatLng position;

  Tree({required this.name, required this.idTree, required this.position});

  factory Tree.fromJson(data) {
    return Tree(
        name: data['name'],
        idTree: data['id'],
        position:
            LatLng(double.parse(data['lat']), double.parse(data['long'])));
  }
}

class Route {
  final LatLng position;

  Route({required this.position});

  factory Route.fromJson(data) {
    return Route(
        position:
            LatLng(double.parse(data['lat']), double.parse(data['long'])));
  }
}

class ApprovalData {
  String idTree;
  String lat;
  String long;
  double qty;

  ApprovalData({
    this.idTree = '0',
    this.lat = '',
    this.long = '',
    this.qty = 0.0,
  });

  factory ApprovalData.fromJson(Map<String, dynamic> data) => ApprovalData(
        idTree: data['idTree'],
        lat: data['lat'],
        long: data['long'],
        qty: data['qty'],
      );
}
