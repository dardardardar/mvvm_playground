import 'package:flutter/material.dart';
import 'package:mvvm_playground/const/theme.dart';

appBar({String? title}) {
  return AppBar(
    backgroundColor: Colors.green.shade50,
    surfaceTintColor: Colors.green.shade50,
    foregroundColor: Colors.black,
    elevation: 0,
    title: Text(
      title ?? '',
      style: textHeading,
    ),
    centerTitle: false,
  );
}
