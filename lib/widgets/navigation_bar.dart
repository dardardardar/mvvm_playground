import 'package:flutter/material.dart';
import 'package:mvvm_playground/const/enums.dart';
import 'package:mvvm_playground/widgets/typography.dart';

appBar({String? title, bool? isCenter}) {
  return AppBar(
    backgroundColor: Colors.green.shade50,
    surfaceTintColor: Colors.green.shade50,
    foregroundColor: Colors.black,
    elevation: 0,
    title: displayText(title ?? '', style: Styles.Display1),
    centerTitle: isCenter ?? false,
  );
}
