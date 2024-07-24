import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:math';

class CompassScreen extends StatefulWidget {
  @override
  _CompassScreenState createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen> {
  final _magnetometerStream = Sensors().magnetometerEventStream();
  final _accelerometerStream = Sensors().accelerometerEventStream();
  final _combinedStream = Rx.combineLatest2(
    Sensors().magnetometerEventStream(),
    Sensors().accelerometerEventStream(),
    (MagnetometerEvent mag, AccelerometerEvent acc) {
      return _calculateHeading(mag, acc);
    },
  );
  double _heading = 0.0;

  @override
  void initState() {
    super.initState();

    _combinedStream.listen((heading) {
      setState(() {
        _heading = heading;
      });
    });
  }

  static double _calculateHeading(
      MagnetometerEvent magnetometer, AccelerometerEvent accelerometer) {
    final ax = accelerometer.x;
    final ay = accelerometer.y;
    final az = accelerometer.z;

    final mx = magnetometer.x;
    final my = magnetometer.y;
    final mz = magnetometer.z;

    final pitch = atan2(-ax, sqrt(ay * ay + az * az));
    final roll = atan2(ay, az);

    final mx1 = mx * cos(pitch) + mz * sin(pitch);
    final my1 = mx * sin(roll) * sin(pitch) +
        my * cos(roll) -
        mz * sin(roll) * cos(pitch);
    final mz1 = mx * cos(roll) * sin(pitch) -
        my * sin(roll) -
        mz * cos(pitch) * cos(roll);

    final heading = atan2(-my1, mx1) * (180 / pi);
    return (heading + 360) % 360; // Normalize to 0-360 degrees
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Compass Example')),
      body: Center(
        child: Text(
          'Heading: ${_heading.toStringAsFixed(2)}°',
          style: TextStyle(fontSize: 24, color: Colors.black),
        ),
      ),
    );
  }
}
