import 'package:latlong2/latlong.dart';

class Tree {
  final String name;
  final LatLng position;

  Tree({required this.name, required this.position});

  factory Tree.fromJson(data) {
    return Tree(
        name: data['name'],
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
