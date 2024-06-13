import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mvvm_playground/const/enums.dart';
import 'package:mvvm_playground/const/theme.dart';
import 'package:mvvm_playground/widgets/typography.dart';
import 'package:shared_preferences/shared_preferences.dart';

appBar({String? title, bool? isCenter}) {
  return AppBar(
    backgroundColor: secondaryColor,
    surfaceTintColor: Colors.transparent,
    foregroundColor: Colors.black,
    elevation: 0,
    title: FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final prefs = snapshot.data!;
        final name = prefs.getString("name") ?? "User";
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            displayText(title ?? '', style: Styles.Display1),
            Row(
              children: [
                Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const ShapeDecoration(
                          shape: CircleBorder(), color: Colors.black),
                      child: const Icon(
                        Icons.person,
                        color: secondaryColor,
                        size: 16,
                      ),
                    )),
                displayText(name, style: Styles.Body),
              ],
            )
          ],
        );
      },
    ),
    centerTitle: isCenter ?? false,
  );
}
