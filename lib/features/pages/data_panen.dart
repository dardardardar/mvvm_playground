import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mvvm_playground/const/theme.dart';
import 'package:mvvm_playground/features/cubit/maps_cubit.dart';
import 'package:mvvm_playground/features/cubit/maps_cubit_data.dart';
import 'package:mvvm_playground/features/state/base_state.dart';
import 'package:mvvm_playground/widgets/navigation_bar.dart';
import 'package:mvvm_playground/widgets/states.dart';
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
    context.read<MapsCubit>().initHarvest();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: appBar(title: widget.title, context: context),
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
              if (state.listHarvest is SuccessState<List<Harvest>> &&
                  state.listHistory is SuccessState<List<Tree>>) {
                final harvest =
                    (state.listHarvest as SuccessState<List<Harvest>>).data;
                final histories =
                    (state.listHistory as SuccessState<List<Tree>>).data;

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      ...harvest.map((item) {
                        final sumQty = histories
                            .where(
                                (element) => element.date.contains(item.date))
                            .fold<int>(0, (sum, item) {
                          return sum + int.parse(item.qty);
                        });
                        return Column(
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
                                    flex: 3,
                                    child: Text(
                                      'Tanggal',
                                      style: subtitle2,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Center(
                                      child: Text(
                                        item.date.toString(),
                                        style: subtitle2,
                                      ),
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
                                      'Rencana Panen',
                                      style: subtitle2,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Center(
                                      child: Text(
                                        rnc_panen_kg,
                                        style: subtitle2,
                                      ),
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
                                      'Rencana Panen Janjang',
                                      style: subtitle2,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Center(
                                      child: Text(
                                        rnc_panen_janjang,
                                        style: subtitle2,
                                      ),
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
                                      'Penghasilan',
                                      style: subtitle2,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Center(
                                      child: Text(
                                        rnc_penghasilan,
                                        style: subtitle2,
                                      ),
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
                                      'Proporsi Pendapatan (kg)',
                                      style: subtitle2,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Center(
                                      child: Text(
                                        ((int.parse(rnc_penghasilan) /
                                                int.parse(rnc_panen_kg)))
                                            .toStringAsFixed(2),
                                        style: subtitle2,
                                      ),
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
                                      'Total Penapatan Hari ini (kg)',
                                      style: subtitle2,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Center(
                                      child: Text(
                                        (sumQty /
                                                (int.parse(rnc_panen_kg) /
                                                    int.parse(
                                                        rnc_panen_janjang)))
                                            .toString(),
                                        style: subtitle2,
                                      ),
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
                                      'Pendapatan Pemanen Hari ini (Rp)',
                                      style: subtitle2,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Center(
                                      child: Text(
                                        (((int.parse(rnc_penghasilan) /
                                                    int.parse(rnc_panen_kg))) *
                                                (sumQty /
                                                    (int.parse(rnc_panen_kg) /
                                                        int.parse(
                                                            rnc_panen_janjang))))
                                            .toStringAsFixed(2),
                                        style: subtitle2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),

                      // Other Containers...
                    ],
                  ),
                );
              }

              return circularLoading(text: 'Loading Stream...');
            },
          ),
        );
      },
    );
  }
}
