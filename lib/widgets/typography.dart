import 'package:flutter/widgets.dart';

import 'package:mvvm_playground/const/theme.dart';

Widget displayText({required String text, TextStyle? style}) {
  return Flexible(
    child: Container(
      padding: const EdgeInsets.all(2),
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: style ?? Styles.body,
      ),
    ),
  );
}
