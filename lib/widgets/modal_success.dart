import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mvvm_playground/const/theme.dart';
import 'package:mvvm_playground/functions/functions.dart';

void showModalSuccess(BuildContext context, {name}) {
  showModalBottomSheet<void>(
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0),
    ),
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white10,
    useSafeArea: true,
    builder: (context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            color: Colors.white10,
          ),
          child: SafeArea(
            child: Container(
              padding: EdgeInsets.all(16),
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    children: [
                      Text(
                        'Panen berhasil diinput',
                        style: textHeadingAlt,
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Image.asset('assets/icons/check-circle.png',
                          color: Colors.green.shade800,
                          width: sizeByScreenWidth(
                              context: context, sizePercent: 0.4)),
                      SizedBox(
                        height: 12,
                      ),
                    ],
                  ),
                  InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(8)),
                          child: Text('Tutup'.toUpperCase())))
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
