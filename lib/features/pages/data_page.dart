import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mvvm_playground/const/theme.dart';
import 'package:mvvm_playground/features/cubit/maps_cubit.dart';
import 'package:mvvm_playground/features/cubit/maps_cubit_data.dart';
import 'package:mvvm_playground/features/state/base_state.dart';
import 'package:mvvm_playground/main.dart';
import 'package:mvvm_playground/widgets/navigation_bar.dart';
import 'package:provider/provider.dart';

import '../models/tree_model.dart';

class DataPage extends StatefulWidget {
  final bool isHistory;
  final String title;
  const DataPage({super.key, required this.isHistory, required this.title});

  @override
  State<StatefulWidget> createState() {
    return _HomeViewPageState();
  }
}

class _HomeViewPageState extends State<DataPage> {
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
      appBar: appBar(title: widget.title, context: context),
      body: _buildInputDataBody(context),
    );
  }

  Widget _buildInputDataBody(BuildContext context) {
    return Container(
      color: secondaryColor,
      child: BlocBuilder<MapsCubit, MapsData>(
        builder: (context, state) {
          if (state.listTree is SuccessState<List<Tree>> &&
              state.listRoute is SuccessState<List<Tree>> &&
              state.listHistory is SuccessState<List<Tree>>) {
            final trees = (state.listTree as SuccessState<List<Tree>>).data;
            final routes = (state.listRoute as SuccessState<List<Tree>>).data;
            final histories =
                (state.listRoute as SuccessState<List<Tree>>).data;
            final users = (state.listUsers as SuccessState<List<User>>).data;
            if (widget.title == 'Trees') {
              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: trees.map((item) {
                    return Container(
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
                              item.idTree,
                              style: subtitle2,
                            ),
                          ),
                          Expanded(
                              flex: 3,
                              child: Text(
                                (item.name == 'null') ? '' : item.name,
                                style: subtitle2,
                              )),
                          Expanded(
                              flex: 4,
                              child: Text(
                                item.position.toString(),
                                style: subtitle2,
                              )),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            } else if (widget.title == 'Routes') {
              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: routes.map((item) {
                    return Container(
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
                              item.idTree,
                              style: subtitle2,
                            ),
                          ),
                          Expanded(
                              flex: 4,
                              child: Text(
                                item.position.toString(),
                                style: subtitle2,
                              )),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            } else if (widget.title == 'Users') {
              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: users.map((item) {
                    return Container(
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
                              item.id_user,
                              style: subtitle2,
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              item.name,
                              style: subtitle2,
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              item.username,
                              style: subtitle2,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            } else if (widget.title == 'Histories') {
              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: histories.map((item) {
                    return Container(
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
                              item.date,
                              style: subtitle2,
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              item.position.toString(),
                              style: subtitle2,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            }
          } else {
            return Text('No Data');
          }
          return Text('No Data');
        },
      ),
    );
  }
}
