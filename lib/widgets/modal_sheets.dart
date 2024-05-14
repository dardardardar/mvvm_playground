import 'package:flutter/material.dart';
import 'package:mvvm_playground/const/theme.dart';
import 'package:mvvm_playground/features/models/tree_model.dart';
import 'package:mvvm_playground/widgets/input.dart';

void showModalInputQty(BuildContext context,
    {bool? isNear, required Tree data}) {
  showModalBottomSheet<void>(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.black,
    useSafeArea: true,
    builder: (context) {
      return Container(
        color: Colors.black,
        child: SafeArea(
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(8),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(
                'Input collected items',
                style: textHeadingAlt,
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                'Name: ${data.name.isEmpty ? 'No tree found' : data.name}',
              ),
              SizedBox(
                height: 8,
              ),
              SizedBox(
                height: 8,
              ),
              InputQty(onQtyChanged: (value) {}),
              SizedBox(
                height: 8,
              ),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: primaryColor),
                  child: Text('Submit'),
                ),
              )
            ]),
          ),
        ),
      );
    },
  );
}