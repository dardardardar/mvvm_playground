import 'package:flutter/material.dart';
import 'package:mvvm_playground/const/theme.dart';
import 'package:mvvm_playground/features/models/tree_model.dart';
import 'package:mvvm_playground/widgets/input.dart';

void showModalInputQty(BuildContext context,
    {bool? isNear, required Tree data}) {
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
            padding: EdgeInsets.all(16),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(
                'Input collected items'.toUpperCase(),
                style: textHeadingAlt,
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                'Name: ${data.name.isEmpty ? 'No tree found' : data.name}',
              ),
              const SizedBox(
                height: 8,
              ),
              const SizedBox(
                height: 8,
              ),
              InputQty(onQtyChanged: (value) {}),
              const SizedBox(
                height: 8,
              ),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  width: MediaQuery.of(context).size.width / 3,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: primaryColor),
                  child: Center(child: Text('Submit'.toUpperCase())),
                ),
              )
            ]),
          ),
        ),
      );
    },
  );
}
