import 'package:flutter/material.dart';
import 'package:mvvm_playground/const/theme.dart';

Widget primaryButton({Function()? onPressed, required String title}) {
  return MaterialButton(
    onPressed: onPressed,
    color: primaryColor,
    child: Text(title),
  );
}
