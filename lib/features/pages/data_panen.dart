import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mvvm_playground/const/theme.dart';
import 'package:mvvm_playground/features/cubit/maps_cubit.dart';
import 'package:mvvm_playground/features/cubit/maps_cubit_data.dart';
import 'package:mvvm_playground/features/state/base_state.dart';
import 'package:mvvm_playground/widgets/navigation_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/tree_model.dart';

class HasilPanenPage extends StatefulWidget {
  final String title;
  const HasilPanenPage({super.key, required this.title});

  @override
  State<StatefulWidget> createState() {
    return _HomeViewPageState();
  }
}

class _HomeViewPageState extends State<HasilPanenPage> {
  @override
  void initState() {
    super.initState();
    context.read<MapsCubit>().initMarker();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: appBar(
        title: widget.title,
      ),
      body: _buildInputDataBody(context),
    );
  }

  Widget _buildInputDataBody(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final prefs = snapshot.data!;
        final rnc_panen_kg = prefs.getString("rnc_panen_kg") ?? "User";
        final rnc_panen_janjang =
            prefs.getString("rnc_panen_janjang") ?? "User";
        final rnc_penghasilan = prefs.getString("rnc_penghasilan") ?? "User";

        return Container(
          color: secondaryColor,
          child: BlocBuilder<MapsCubit, MapsData>(
            builder: (context, state) {
              if (state.listTree is SuccessState<List<Tree>> &&
                  state.listHistory is SuccessState<List<Tree>>) {
                final histories =
                    (state.listHistory as SuccessState<List<Tree>>).data;
                final sumQty = histories.fold<int>(0, (sum, item) {
                  return sum +
                      int.parse(item
                          .qty); // Assuming item.qty is a String, parse it to int
                });
                return SingleChildScrollView(
                  child: Column(
                    children: [
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
                              flex: 2,
                              child: Text(
                                'Rencana Panen',
                                style: subtitle2,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                rnc_panen_kg,
                                style: subtitle2,
                              ),
                            ),
                          ],
                        ),
                      ),
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
                              flex: 2,
                              child: Text(
                                'Penghasilan',
                                style: subtitle2,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                rnc_penghasilan,
                                style: subtitle2,
                              ),
                            ),
                          ],
                        ),
                      ),
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
                              flex: 2,
                              child: Text(
                                'Rencana Panen',
                                style: subtitle2,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                rnc_panen_kg,
                                style: subtitle2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Column(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: histories.map((item) {
                      //     return Container(
                      //       padding: EdgeInsets.all(8),
                      //       margin: EdgeInsets.symmetric(vertical: 8),
                      //       decoration: BoxDecoration(
                      //         color: Colors.white,
                      //         borderRadius: BorderRadius.circular(8),
                      //       ),
                      //       child: Row(
                      //         children: [
                      //           Expanded(
                      //             flex: 2,
                      //             child: Text(
                      //               item.date,
                      //               style: subtitle2,
                      //             ),
                      //           ),
                      //           Expanded(
                      //             flex: 1,
                      //             child: Text(
                      //               item.name,
                      //               style: subtitle2,
                      //             ),
                      //           ),
                      //           Expanded(
                      //             flex: 1,
                      //             child: Text(
                      //               item.qty,
                      //               style: subtitle2,
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //     );
                      //   }).toList(),
                      // ),
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
                              flex: 3,
                              child: Text(
                                'Total Buah',
                                style: subtitle2,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                sumQty.toString(),
                                style: subtitle2,
                              ),
                            ),
                          ],
                        ),
                      ),
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
                              flex: 3,
                              child: Text(
                                'Total Berat Kg',
                                style: subtitle2,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                (sumQty * 5).toString(),
                                style: subtitle2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Text('No Data');
            },
          ),
        );
      },
    );
  }
}
