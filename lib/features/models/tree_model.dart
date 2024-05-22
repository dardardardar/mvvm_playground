import 'package:latlong2/latlong.dart';

class Tree {
  final String name;
  final String idTree;
  final LatLng position;
  final String qty;
  final String date;

  Tree(
      {required this.name,
      required this.idTree,
      required this.position,
      this.qty = '0',
      this.date = ''});

  factory Tree.fromJson(data) {
    return Tree(
        name: (data['name'] != null) ? data['name'] : '',
        idTree: (data['id'] != null) ? data['id'] : '',
        qty: (data['qty'] != null) ? data['qty'] : '',
        date: (data['date'] != null) ? data['date'] : '',
        position:
            LatLng(double.parse(data['lat']), double.parse(data['long'])));
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
