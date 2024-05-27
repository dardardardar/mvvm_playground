import 'package:flutter/material.dart';

const secondaryColor = Color(0xFF0078d4);
const primaryColor = Color.fromARGB(255, 74, 180, 98);
const barBackgroundColor = Color(0xFF1F1F1F);
const backgroundColor = Color(0xFF151515);
const borderColor = Color(0x99ffffff);
const dangerColor = Color(0xFFff5f56);

var theme = ThemeData(
    brightness: Brightness.light,
    bottomSheetTheme: const BottomSheetThemeData(
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        modalBarrierColor: Colors.black12),
    colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primaryColor,
        onPrimary: Colors.white,
        secondary: Colors.black,
        onSecondary: Colors.white,
        error: dangerColor,
        onError: Colors.white,
        background: Colors.white,
        onBackground: Colors.black,
        surface: primaryColor,
        onSurface: Colors.white));

const textHeadingAlt =
    TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.w800);

const textHeading = TextStyle(
  color: Colors.black,
  fontSize: 22,
);
const textHeading2Alt =
    TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600);

const textHeading2 = TextStyle(
  color: Colors.black,
  fontSize: 16,
);
const textBody = TextStyle(
  color: Colors.black,
  fontSize: 14,
);
const subtitle = TextStyle(color: Colors.black, fontSize: 14);
const subtitle2 = TextStyle(color: Colors.black, fontSize: 12);
const subtitle3 = TextStyle(color: Colors.black, fontSize: 11);
const inputPlaceholder = TextStyle(color: borderColor, fontSize: 14);
const textButton2 = TextStyle(
  color: Colors.white,
  fontSize: 14,
);
const textButton = TextStyle(
    color: primaryColor,
    fontSize: 14,
    decoration: TextDecoration.underline,
    decorationColor: primaryColor);

const txtH1 =
    TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.w800);

/// [Styles] kalo ada 'Alt' warna text di invert
class Styles {
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
      TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500);
  static const placeholder = TextStyle(color: borderColor, fontSize: 14);
}
