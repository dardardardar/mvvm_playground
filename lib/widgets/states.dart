import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

Widget circularLoading({String? text}) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        text == null ? const Center() : Text(text),
        const SizedBox(
          height: 16,
        ),
        const CircularProgressIndicator(color: Colors.white, strokeWidth: 1.5),
      ],
    ),
  );
}

Widget errorAlert({required String text}) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('Exception occurred'),
        const SizedBox(
          height: 16,
        ),
        Text(text),
      ],
    ),
  );
}
