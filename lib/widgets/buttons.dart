import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mvvm_playground/const/enums.dart';
import 'package:mvvm_playground/const/theme.dart';
import 'package:mvvm_playground/widgets/typography.dart';

Widget primaryButton({Function()? onPressed, required String title}) {
  return MaterialButton(
    onPressed: onPressed,
    color: primaryColor,
    child: Text(title),
  );
}

Widget bigButton(
    {required BuildContext context,
    Function()? onTap,
    required String title,
    Color? backgroundColor,
    Color? color,
    required IconData icon}) {
  return InkWell(
    onTap: onTap,
    child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8), color: backgroundColor),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
            ),
            SizedBox(
              height: 8,
            ),
            displayText(title, style: Styles.Button),
          ],
        )),
  );
}

Widget flatButton(
    {required BuildContext context,
    Function()? onTap,
    required String title,
    Color? backgroundColor,
    Color? color,
    required IconData icon}) {
  return InkWell(
    onTap: onTap,
    child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8), color: backgroundColor),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              alignment: Alignment.center,
              child: displayText(
                title,
                style: Styles.Button,
              ),
            ),
          ],
        )),
  );
}

Widget boxButton(
    {required BuildContext context,
    Function()? onTap,
    required String title,
    Color? backgroundColor,
    Color? color,
    required IconData icon}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: backgroundColor ?? primaryColor,
          borderRadius: BorderRadius.circular(10)),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(
              icon,
              color: color ?? Colors.white,
            ),
            const SizedBox(
              height: 2,
            ),
            displayText(
              title,
              style: Styles.CaptionsAlt,
            )
          ]),
    ),
  );
}
