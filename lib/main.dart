import 'package:flutter/material.dart';
import 'package:mvvm_playground/features/pages/flutter_maps_page.dart';
import 'package:mvvm_playground/functions/geolocation.dart';
import 'package:mvvm_playground/functions/location.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamProvider<GeoLocation>(
      initialData: GeoLocation.createZeroUserPoint(),
      create: (context) => LocationService().locationStream,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const FlutterMapPage(),
      ),
    );
  }
}
