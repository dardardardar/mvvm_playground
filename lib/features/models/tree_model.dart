import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

class Tree {
  final String name;
  final String idTree;
  final LatLng position;
  final String qty;
  final DateTime? date;

  Tree(
      {required this.name,
      required this.idTree,
      required this.position,
      this.qty = '0',
      this.date});

  factory Tree.fromJson(data) {
    return Tree(
        name: (data['name'].toString() != null) ? data['name'].toString() : '',
        idTree: (data['id'].toString() != null) ? data['id'].toString() : '',
        qty: (data['qty'].toString() != null) ? data['qty'].toString() : '',
        date: data['date'] != null
            ? DateFormat('yyyy-MM-dd HH:mm:ss').parse(data['date'])
            : DateTime(1970, 1, 1),
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

