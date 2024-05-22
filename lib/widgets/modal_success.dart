import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mvvm_playground/const/theme.dart';

void showModalSuccess(BuildContext context, {name}) {
  showModalBottomSheet<void>(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0),
    ),
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.black,
    useSafeArea: true,
    builder: (context) {
      var textTree = '';
      if (name != 'Tree Not Found') {
        textTree = 'Berhasil Melakukan Input Data ' + name;
      } else {
        textTree = 'Berhasil Melakukan Input diluar jangkauan Pohon Terdaftar';
      }
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.3,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(textTree),
            SizedBox(
              height: 15,
            ),
            InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(8)),
                    child: Text('Tutup'.toUpperCase())))
          ],
        ),
      );
    },
  );
}
