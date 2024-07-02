import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mvvm_playground/const/enums.dart';
import 'package:mvvm_playground/const/theme.dart';
import 'package:mvvm_playground/features/cubit/maps_cubit.dart';
import 'package:mvvm_playground/features/cubit/maps_cubit_data.dart';
import 'package:mvvm_playground/features/state/base_state.dart';
import 'package:mvvm_playground/widgets/navigation_bar.dart';
import 'package:mvvm_playground/widgets/states.dart';
import 'package:mvvm_playground/widgets/typography.dart';
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
                if (histories.isEmpty) {
                  return SizedBox(
                    height: double.infinity,
                    child: Center(
                      child: displayText('Hasil Panen Kosong'),
                    ),
                  );
                }
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
                              padding: EdgeInsets.all(12),
                              margin: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    spreadRadius: 0,
                                    blurRadius: 4,
                                    offset: Offset(
                                        1, 3), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: displayText(
                                            'Tanggal',
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Center(
                                            child: displayText(
                                              item.date.toString(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    child: Column(
                                      children: [
                                        Container(
                                          alignment: Alignment.centerLeft,
                                          child: displayText(
                                            'Rencana Harian Kerja',
                                            style: Styles.Display3,
                                          ),
                                        ),
                                        Divider(
                                          thickness: 0.75,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 4),
                                          child: Row(
                                            children: [
                                              displayText(
                                                'Rencana Panen :',
                                              ),
                                              Spacer(),
                                              displayText(
                                                '$rnc_panen_kg kg',
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 4),
                                          child: Row(
                                            children: [
                                              displayText(
                                                'Rencana Panen Janjang :',
                                              ),
                                              Spacer(),
                                              displayText(
                                                rnc_panen_janjang,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 4),
                                          child: Row(
                                            children: [
                                              displayText(
                                                'Penghasilan :',
                                              ),
                                              Spacer(),
                                              displayText(
                                                NumberFormat.currency(
                                                  locale: 'id',
                                                  symbol: 'Rp ',
                                                ).format(
                                                    int.parse(rnc_penghasilan)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    child: Column(
                                      children: [
                                        Container(
                                          alignment: Alignment.centerLeft,
                                          child: displayText(
                                            'Hasil Panen',
                                            style: Styles.Display3,
                                          ),
                                        ),
                                        Divider(
                                          thickness: 0.75,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 4),
                                          child: Row(
                                            children: [
                                              displayText(
                                                'Proporsi Pendapatan (kg)',
                                              ),
                                              Spacer(),
                                              displayText(
                                                '${((int.parse(rnc_penghasilan) / int.parse(rnc_panen_kg))).toStringAsFixed(2)} kg',
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 4),
                                          child: Row(
                                            children: [
                                              displayText(
                                                'Total Pendapatan Hari ini (kg)',
                                              ),
                                              Spacer(),
                                              displayText(
                                                '${sumQty / (int.parse(rnc_panen_kg) / int.parse(rnc_panen_janjang))} kg',
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 4),
                                          child: Row(
                                            children: [
                                              displayText(
                                                'Pendapatan Pemanen Hari ini :',
                                              ),
                                              Spacer(),
                                              displayText(
                                                NumberFormat.currency(
                                                  locale: 'id',
                                                  symbol: 'Rp ',
                                                ).format(((((int.parse(
                                                            rnc_penghasilan) /
                                                        int.parse(
                                                            rnc_panen_kg))) *
                                                    (sumQty /
                                                        (int.parse(
                                                                rnc_panen_kg) /
                                                            int.parse(
                                                                rnc_panen_janjang)))))),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  )
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

              return circularLoading(text: 'Fetching Data...');
            },
          ),
        );
      },
    );
  }
}
