import 'package:flutter/material.dart';
import 'package:mvvm_playground/const/theme.dart';

Widget primaryButton({Function()? onPressed, required String title}) {
  return MaterialButton(
    onPressed: onPressed,
    color: primaryColor,
    child: Text(title),
  );
}

Widget outlinedCircularIconButton(
    {Function()? onPressed, required IconData icon, Color? color}) {
  return MaterialButton(
    onPressed: onPressed,
    shape:
        CircleBorder(side: BorderSide(width: 1, color: color ?? Colors.white)),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Icon(
        icon,
        color: color,
      ),
    ),
  );
}
