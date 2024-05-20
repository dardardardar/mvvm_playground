import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:mvvm_playground/const/theme.dart';
import 'package:mvvm_playground/features/cubit/maps_cubit.dart';
import 'package:mvvm_playground/features/models/tree_model.dart';
import 'package:mvvm_playground/functions/geolocation.dart';
import 'package:mvvm_playground/widgets/input.dart';
import 'package:provider/provider.dart';

void showModalInputQty(BuildContext context,
    {bool? isNear, required Tree data, required LatLng current}) {
  void sendQty(qty) {
    context.read<MapsCubit>().sendQty(
          qty: qty,
          data: data,
        );
  }

  showModalBottomSheet<void>(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0),
    ),
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.black,
    useSafeArea: true,
    builder: (context) {
      var userloc = Provider.of<GeoLocation>(context);
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
              Text(
                'Panen',
                style: textHeadingAlt,
              ),
              const SizedBox(
                height: 8,
              ),
              Text('Masukkan jumlah sawit yang dipanen'),
              Visibility(
                visible: data.idTree.isEmpty,
                child: Container(
                  margin: EdgeInsets.all(8),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline),
                      SizedBox(
                        width: 8,
                      ),
                      Flexible(
                        child: Text(
                          'Pohon tidak ditemukan, sistem akan mengasumsikan pohon ini sebagai pohon baru',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              InputQty(onQtyChanged: (value) {
                userloc.setQty(value);
              }),
              const SizedBox(
                height: 8,
              ),
              InkWell(
                  onTap: () {
                    sendQty(userloc.qty);
                    Navigator.pop(context);
                  },
                  child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(8)),
                      child: Text('Panen Sekarang'.toUpperCase())))
            ]),
          ),
        ),
      );
    },
  );
}
