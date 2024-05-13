import 'package:flutter/material.dart';

const primaryColor = Color(0xFF0078d4);
const barBackgroundColor = Color(0xFF1F1F1F);
const backgroundColor = Color(0xFF151515);
const borderColor = Color(0x99ffffff);
const dangerColor = Color(0xFFff5f56);

var theme = ThemeData(
    brightness: Brightness.dark,
    bottomSheetTheme:
        const BottomSheetThemeData(surfaceTintColor: Colors.transparent),
    colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: primaryColor,
        onPrimary: Colors.white,
        secondary: Colors.white,
        onSecondary: Colors.black,
        error: dangerColor,
        onError: Colors.white,
        background: Colors.black,
        onBackground: Colors.white,
        surface: primaryColor,
        onSurface: Colors.white));

const textHeadingAlt =
    TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800);

const textHeading = TextStyle(
  color: Colors.white,
  fontSize: 22,
);
const textHeading2Alt =
    TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600);

const textHeading2 = TextStyle(
  color: Colors.white,
  fontSize: 16,
);
const textBody = TextStyle(
  color: Colors.white,
  fontSize: 14,
);
const subtitle = TextStyle(color: borderColor, fontSize: 14);
const subtitle2 = TextStyle(color: borderColor, fontSize: 12);
const inputPlaceholder = TextStyle(color: borderColor, fontSize: 14);
