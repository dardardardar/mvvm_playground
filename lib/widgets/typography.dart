import 'package:flutter/material.dart';
import 'package:mvvm_playground/const/enums.dart';

import 'package:mvvm_playground/const/theme.dart';

///  Custom Text widget with overflow implementation. jd gaakan overlow lagi.
Widget displayText(String text, {Styles? style, TextOverflow? overflow}) {
  return Text(
    text,
    overflow: overflow ?? TextOverflow.ellipsis,
    style: _styles(style ?? Styles.Body),
  );
}

class TStyles {
  // heading
  static const h1 =
      TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.w800);
  static const h1Alt =
      TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800);
  static const h2 =
      TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w800);
  static const h2Alt =
      TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800);
  static const h3 =
      TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w800);
  static const h3Alt =
      TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800);
  // display
  static const display1 =
      TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.w500);
  static const display1Alt =
      TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w500);
  static const display2 =
      TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w500);
  static const display2Alt =
      TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500);
  static const display3 =
      TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500);
  static const display3Alt =
      TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500);
  static const body = TextStyle(color: Colors.black, fontSize: 14);
  static const bodyAlt = TextStyle(color: Colors.white, fontSize: 14);
  static const subtitle = TextStyle(color: Colors.black, fontSize: 12);
  static const subtitleAlt = TextStyle(color: Colors.white, fontSize: 12);
  static const captions = TextStyle(color: Colors.black, fontSize: 11);
  static const captionsAlt = TextStyle(color: Colors.white, fontSize: 11);
  static const button =
      TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600);
  static const placeholder = TextStyle(color: borderColor, fontSize: 14);
}

TextStyle _styles(Styles s) {
  switch (s) {
    case Styles.Heading1:
      return TStyles.h1;
    case Styles.Heading1Alt:
      return TStyles.h1Alt;
    case Styles.Heading2:
      return TStyles.h2;
    case Styles.Heading2Alt:
      return TStyles.h2Alt;
    case Styles.Heading3:
      return TStyles.h3;
    case Styles.Heading3Alt:
      return TStyles.h3Alt;

    case Styles.Display1:
      return TStyles.display1;
    case Styles.Display1Alt:
      return TStyles.display1Alt;
    case Styles.Display2:
      return TStyles.display2;
    case Styles.Display2Alt:
      return TStyles.display2Alt;
    case Styles.Display3:
      return TStyles.display3;
    case Styles.Display3Alt:
      return TStyles.display3Alt;

    case Styles.Body:
      return TStyles.body;
    case Styles.BodyAlt:
      return TStyles.bodyAlt;
    case Styles.Subtitle:
      return TStyles.subtitle;
    case Styles.SubtitleAlt:
      return TStyles.subtitleAlt;
    case Styles.Captions:
      return TStyles.captions;
    case Styles.CaptionsAlt:
      return TStyles.captionsAlt;
    case Styles.Button:
      return TStyles.button;
    case Styles.Placeholder:
      return TStyles.placeholder;
    default:
      return TStyles.body;
  }
}
