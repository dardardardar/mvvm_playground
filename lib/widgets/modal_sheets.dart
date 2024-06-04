import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:mvvm_playground/const/enums.dart';
import 'package:mvvm_playground/const/theme.dart';
import 'package:mvvm_playground/features/cubit/maps_cubit.dart';
import 'package:mvvm_playground/features/models/tree_model.dart';
import 'package:mvvm_playground/functions/functions.dart';
import 'package:mvvm_playground/functions/geolocation.dart';
import 'package:mvvm_playground/widgets/input.dart';
import 'package:mvvm_playground/widgets/typography.dart';
import 'package:provider/provider.dart';

void showModalInputQty(BuildContext context,
    {bool? isNear, required Tree data, required LatLng current}) {
  void sendQty(qty, bool isNewTree) {
    Tree tree = Tree(name: data.name, idTree: data.idTree, position: current);
    context.read<MapsCubit>().sendQty(
          qty: qty,
          data: tree,
        );
  }

  showModalBottomSheet<void>(
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0),
    ),
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.grey.shade300.withOpacity(0.2),
    useSafeArea: true,
    builder: (context) {
      var userloc = Provider.of<GeoLocation>(context);
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            color: Colors.grey.shade300.withOpacity(0.2),
          ),
          child: SafeArea(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                displayText(
                  'Panen',
                  style: Styles.Display1,
                ),
                const SizedBox(
                  height: 8,
                ),
                displayText(
                  'Masukkan jumlah sawit yang dipanen',
                ),
                Visibility(
                  visible: data.idTree.isEmpty,
                  child: Container(
                    margin: EdgeInsets.all(8),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.green.shade200.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.green.shade900,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Flexible(
                          child: Text(
                            'Pohon tidak ditemukan, sistem akan mengasumsikan pohon ini sebagai pohon baru',
                            style: subtitle2.copyWith(
                                color: Colors.green.shade900),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                InputQty(
                  onQtyChanged: (value) {
                    userloc.setQty(value);
                  },
                ),
                const SizedBox(
                  height: 8,
                ),
                InkWell(
                    onTap: () {
                      sendQty(userloc.qty, data.idTree.isEmpty);
                      Navigator.pop(context);
                      showModalSuccess(context, name: data.name);
                    },
                    child: Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          'Panen Sekarang'.toUpperCase(),
                          style: textButton2,
                        )))
              ]),
            ),
          ),
        ),
      );
    },
  );
}

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
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        displayText(
                          'Panen berhasil diinput',
                          style: Styles.Display1,
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
                          child: displayText('Tutup'.toUpperCase())))
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

void showModalHistory(BuildContext context, {required List<Tree> history}) {
  showModalBottomSheet<void>(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0),
    ),
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.green.shade50,
    useSafeArea: true,
    builder: (context) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          color: Colors.green.shade50,
        ),
        child: SafeArea(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          'No',
                          style: subtitle2,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Waktu',
                          style: subtitle2,
                        ),
                      ),
                      Expanded(
                          flex: 3,
                          child: Text(
                            'Tree',
                            style: subtitle2,
                          )),
                      Expanded(
                          flex: 1,
                          child: Text(
                            'Qty',
                            style: subtitle2,
                          )),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          for (var i = 0; i < history.length; i++)
                            Container(
                              padding: EdgeInsets.all(8),
                              margin: EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      (i + 1).toString(),
                                      style: subtitle2,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      'test',
                                      style: subtitle2,
                                    ),
                                  ),
                                  Expanded(
                                      flex: 3,
                                      child: Text(
                                        (history[i].name == 'null')
                                            ? ''
                                            : history[i].name,
                                        style: subtitle2,
                                      )),
                                  Expanded(
                                      flex: 1,
                                      child: Text(
                                        history[i].qty,
                                        style: subtitle2,
                                      )),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 12,
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
                ]),
          ),
        ),
      );
    },
  );
}
