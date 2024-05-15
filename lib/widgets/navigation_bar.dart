import 'package:flutter/material.dart';
import 'package:mvvm_playground/const/theme.dart';

appBar({String? title}) {
  return AppBar(
    backgroundColor: backgroundColor,
    surfaceTintColor: backgroundColor,
    elevation: 4,
    title: Text(
      title ?? '',
      style: textHeading,
    ),
    centerTitle: false,
  );
}
