import 'package:flutter/cupertino.dart';

/// [sizePercent] harus diantara value 0 sd 1.
double sizeByScreenWidth(
    {required BuildContext context, required double sizePercent}) {
  if (sizePercent > 1 || sizePercent <= 0) {
    return MediaQuery.of(context).size.width;
  }
  return MediaQuery.of(context).size.width * sizePercent;
}
