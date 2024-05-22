import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mvvm_playground/const/theme.dart';
import 'package:mvvm_playground/features/models/tree_model.dart';
import 'package:intl/intl.dart';

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
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text('Waktu'),
                  ),
                  Expanded(flex: 3, child: Text('Tree')),
                  Expanded(flex: 1, child: Text('Qty')),
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      for (var i = 0; i < history.length; i++)
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text(DateFormat('HH:mm').format(
                                  history[i].date ?? DateTime(1970, 1, 1))),
                            ),
                            Expanded(flex: 3, child: Text(history[i].name)),
                            Expanded(flex: 1, child: Text(history[i].qty)),
                          ],
                        ),
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
