import 'package:flutter/material.dart';

const secondaryColor = Color.fromARGB(255, 226, 248, 231);
const primaryColor = Color.fromARGB(255, 74, 180, 98);
const barBackgroundColor = Color(0xFF1F1F1F);
const backgroundColor = Color(0xFF151515);
const borderColor = Color(0x99ffffff);
const dangerColor = Color.fromARGB(255, 216, 69, 61);

var theme = ThemeData(
    brightness: Brightness.light,
    bottomSheetTheme: BottomSheetThemeData(
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        modalBarrierColor: Colors.black.withOpacity(0.1)),
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
