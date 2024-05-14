import 'package:latlong2/latlong.dart';

class Trees {
  final List<Tree> data;

  Trees({required this.data});
  factory Trees.fromJson(Map<String, dynamic> json) {
    return Trees(
        data: (json['data'] as List<dynamic>)
            .map((e) => Tree.fromJson(e))
            .toList());
  }
}

class Tree {
  final String name;
  final LatLng position;

  Tree({required this.name, required this.position});

  factory Tree.fromJson(Map<String, dynamic> json) {
    return Tree(
        name: json['name'],
        position: LatLng(double.parse(json['lat']), double.parse(json['lon'])));
  }
}
