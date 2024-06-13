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
    title: Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        displayText(title ?? '', style: Styles.Display1),
        FutureBuilder<SharedPreferences>(
          future: SharedPreferences.getInstance(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final prefs = snapshot.data!;
            final name = prefs.getString("name") ?? "User";

            return displayText(' Hi $name', style: Styles.Display1);
          },
        ),
      ],
    ),
    centerTitle: isCenter ?? false,
  );
}
