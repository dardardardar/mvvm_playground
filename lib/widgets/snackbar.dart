import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mvvm_playground/const/enums.dart';
import 'package:mvvm_playground/const/theme.dart';
import 'package:mvvm_playground/widgets/typography.dart';

// ignore: constant_identifier_names

void showSnackbar(BuildContext context,
    {required String message, Status status = Status.Info}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
        content: Row(
          children: [
            _icon(index: status.index),
            const SizedBox(
              width: 4,
            ),
            displayText(message,
                style: status.index == 1 ? Styles.Body : Styles.BodyAlt),
          ],
        ),
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        shape: const StadiumBorder(),
        backgroundColor: _bgColor(index: status.index)),
  );
}

Color _bgColor({required int index}) {
  if (index == 0) return primaryColor;
  if (index == 1) return Colors.grey;
  return dangerColor;
}

Icon _icon({required int index}) {
  if (index == 0) {
    return const Icon(
      Icons.check_circle_outline_rounded,
      color: Colors.white,
    );
  }
  if (index == 1) {
    return const Icon(
      Icons.info_outline_rounded,
      color: Colors.black,
    );
  }
  return const Icon(
    Icons.error_outline_rounded,
    color: Colors.white,
  );
}
