import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mvvm_playground/const/theme.dart';
import 'package:mvvm_playground/features/models/tree_model.dart';

void showModalHistory(BuildContext context, {required List<Tree> history}) {
  showModalBottomSheet<void>(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0),
    ),
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.black,
    useSafeArea: true,
    builder: (context) {
      return Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          color: Colors.black,
        ),
        child: SafeArea(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      for (var i = 0; i < history.length; i++)
                        Text(history[i].date +
                            ' ' +
                            history[i].name +
                            ' ' +
                            history[i].qty),
                    ],
                  ),
                ),
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
            ]),
          ),
        ),
      );
    },
  );
}
