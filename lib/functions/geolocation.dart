import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:mvvm_playground/features/models/tree_model.dart';

String Show = '0';

class GeoLocation {
  GeoPoint userlocation = new GeoPoint.createZeroPoint();

  GeoPoint centerlocation = new GeoPoint.createZeroPoint();
  GeoPoint outerlocation = new GeoPoint.createNullPoint();
  double radiuscentermeters = 0.0;
  String nameTree = '';
  String idTree = '';
  double qty = 0.0;
  bool isInRange = false;
  List<dynamic> status = [];
  String currentTree = '';
  String currentidTree = '';
  String blokTree = '';
  LatLng pos = const LatLng(0, 0);
  //constructor
  GeoLocation({required this.userlocation});

  GeoLocation.createZeroUserPoint() {
    userlocation = new GeoPoint.createZeroPoint();
  }

  GeoLocation.createUserPoint(double lat, double long) {
    setPointUser(lat, long);
  }

  GeoLocation.createUserPointLocationData(LocationData loc) {
    setPointUser(loc.latitude!, loc.longitude!);
  }

  GeoLocation.fromJson(Map<String, dynamic> json) {
    setPointUser(json['latitude'], json['longitude']);
  }

  //setter
  void setPointUserLocationData(LocationData loc) {
    setPointUser(loc.latitude!, loc.longitude!);
  }

  void setPointUser(double lat, double long) {
    userlocation.setPoint(lat, long);
    _calculateRadiusMetersAndInRange();
  }

  void setQty(value) {
    var getQty = double.parse(value.toString());
    qty = getQty;
  }

  void setPointOuterLocationData(LocationData loc) {
    setPointOuter(loc.latitude!, loc.longitude!);
  }

  void setPointOuter(double lat, double long) {
    outerlocation.setPoint(lat, long);
    _calculateRadiusMetersAndInRange();
  }

  void setPointCenter(Tree tree) {
    centerlocation.setPoint(tree.position.latitude, tree.position.longitude);
    nameTree = tree.name;
    idTree = tree.idTree;
    blokTree = tree.blok;
    pos = tree.position;
    _calculateRadiusMetersAndInRange();
  }

  set setRadius(double radiusmeters) {
    radiuscentermeters = radiusmeters;
    _calculateInRange();
  }

  //measure
  double distanceUserFromCenter() {
    return centerlocation.distanceWith(userlocation);
  }

  double distanceOuterFromCenter() {
    return centerlocation.distanceWith(outerlocation);
  }

  double distanceUserFromOuter() {
    double radius = distanceUserFromCenter() - distanceOuterFromCenter();
    return radius < 0 ? -radius : radius;
  }

  //calculation
  void _calculateRadiusMetersAndInRange() {
    if (radiuscentermeters == 0.0) _calculateRadiusMeters();
    _calculateInRange();
  }

  void _calculateRadiusMeters() {
    if (outerlocation.latitude != null && outerlocation.longitude != null)
      radiuscentermeters = distanceOuterFromCenter();
  }

  void _calculateInRange() {
    status.add(radiuscentermeters >= distanceUserFromCenter());
    if (radiuscentermeters >= distanceUserFromCenter()) {}
    isInRange = radiuscentermeters >= distanceUserFromCenter();
    if (isInRange) {
      currentTree = nameTree;
      currentidTree = idTree;
    }
  }
}

class GeoPoint {
  double? latitude;
  double? longitude;

  GeoPoint({required this.latitude, required this.longitude});

  GeoPoint.createNullPoint() {
    latitude = null;
    longitude = null;
  }

  GeoPoint.createZeroPoint() {
    latitude = 0.0;
    longitude = 0.0;
  }

  void setPoint(double lat, double long) {
    latitude = lat;
    longitude = long;
  }

  double distanceWith(GeoPoint otherpoint) {
    return GeolocatorPlatform.instance.distanceBetween(
        latitude!, longitude!, otherpoint.latitude!, otherpoint.longitude!);
  }
}
