import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';

class GeoLocation {
  GeoPoint userlocation = new GeoPoint.createZeroPoint();

  GeoPoint centerlocation = new GeoPoint.createZeroPoint();
  GeoPoint outerlocation = new GeoPoint.createNullPoint();
  double radiuscentermeters = 0.0;
  String name = '';
  bool isInRange = false;
  List<dynamic> status = [];
  List<dynamic> currentTree = [];

  //constructor
  GeoLocation({required this.userlocation});

  GeoLocation.createZeroUserPoint() {
    this.userlocation = new GeoPoint.createZeroPoint();
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
  setCurrentTree(String tree) {
    name = tree;
  }

  //setter
  void setPointUserLocationData(LocationData loc) {
    setPointUser(loc.latitude!, loc.longitude!);
  }

  void setPointUser(double lat, double long) {
    userlocation.setPoint(lat, long);
    this._calculateRadiusMetersAndInRange();
  }

  void setPointOuterLocationData(LocationData loc) {
    setPointOuter(loc.latitude!, loc.longitude!);
  }

  void setPointOuter(double lat, double long) {
    outerlocation.setPoint(lat, long);
    this._calculateRadiusMetersAndInRange();
  }

  // void setPointCenterLocationData(LocationData loc) {
  //   setPointCenter(loc.latitude!, loc.longitude!);
  // }

  void setPointCenter(double lat, double long, String tree) {
    centerlocation.setPoint(lat, long);
    name = tree;
    this._calculateRadiusMetersAndInRange();
  }

  set setRadius(double radiusmeters) {
    this.radiuscentermeters = radiusmeters;
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
    double radius =
        this.distanceUserFromCenter() - this.distanceOuterFromCenter();
    return radius < 0 ? -radius : radius;
  }

  //calculation
  void _calculateRadiusMetersAndInRange() {
    if (this.radiuscentermeters == 0.0) this._calculateRadiusMeters();
    _calculateInRange();
  }

  void _calculateRadiusMeters() {
    if (this.outerlocation.latitude != null &&
        this.outerlocation.longitude != null)
      this.radiuscentermeters = this.distanceOuterFromCenter();
  }

  void _calculateInRange() {
    status.add(this.radiuscentermeters >= this.distanceUserFromCenter());
    if (this.radiuscentermeters >= this.distanceUserFromCenter()) {}
    this.isInRange = this.radiuscentermeters >= this.distanceUserFromCenter();
  }
}

class GeoPoint {
  double? latitude;
  double? longitude;

  GeoPoint({required this.latitude, required this.longitude});

  GeoPoint.createNullPoint() {
    this.latitude = null;
    this.longitude = null;
  }

  GeoPoint.createZeroPoint() {
    this.latitude = 0.0;
    this.longitude = 0.0;
  }

  void setPoint(double lat, double long) {
    this.latitude = lat;
    this.longitude = long;
  }

  double distanceWith(GeoPoint otherpoint) {
    return GeolocatorPlatform.instance.distanceBetween(this.latitude!,
        this.longitude!, otherpoint.latitude!, otherpoint.longitude!);
  }
}
