import 'package:flutter/material.dart';

Widget ScrollPage({required Widget child}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    child: SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: child,
    ),
  );
}
