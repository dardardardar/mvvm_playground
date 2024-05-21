import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mvvm_playground/const/theme.dart';

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
            borderRadius: BorderRadius.circular(10), color: backgroundColor),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              title,
            ),
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
            borderRadius: BorderRadius.circular(10), color: backgroundColor),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                icon,
                color: color,
              ),
            ),
            Container(
              width: double.infinity,
              child: Text(
                title,
                style: textHeading2Alt,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        )),
  );
}
