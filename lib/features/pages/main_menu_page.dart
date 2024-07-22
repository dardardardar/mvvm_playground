import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mvvm_playground/const/enums.dart';
import 'package:mvvm_playground/const/theme.dart';
import 'package:mvvm_playground/features/cubit/auth_cubit.dart';
import 'package:mvvm_playground/features/cubit/auth_cubit_data.dart';
import 'package:mvvm_playground/features/cubit/maps_cubit.dart';
import 'package:mvvm_playground/features/cubit/maps_cubit_data.dart';
import 'package:mvvm_playground/features/pages/data_panen.dart';
import 'package:mvvm_playground/features/pages/flutter_maps_page.dart';
import 'package:mvvm_playground/features/pages/login_page.dart';
import 'package:mvvm_playground/features/state/base_state.dart';
import 'package:mvvm_playground/widgets/buttons.dart';
import 'package:mvvm_playground/widgets/snackbar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

bool checkNav = true;

class MainMenuPage extends StatefulWidget {
  const MainMenuPage({super.key});

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  bool _isLoading = false;
  String _progress = 'Download Maps';
  List<int> bytes = [];
  int downloaded = 0;

  @override
  void initState() {
    super.initState();
    context.read<MapsCubit>().installation('online');
    checkNav = true;
  }

  // download maps
  Future<void> downloadFile() async {
    setState(() {
      _isLoading = true;
      _progress = '0.0';
    });

    try {
      await _updateFile(
          'http://be-bum.tvindo.net/api/v1/gis/road/download-tiles',
          'map.mbtiles');
    } catch (e) {
      print('Error downloading file: $e');
    }
  }

  Future<File> _updateFile(String url, String fileName) async {
    url = 'https://be-bum.tvindo.net/assets/tiles/map1.mbtiles';
    final request = http.Request('GET', Uri.parse(url));
    final response = await request.send();
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);

    Dio dio = Dio();

    // Download the file.
    await dio.download(url, filePath, onReceiveProgress: (received, total) {
      if (total != -1) {
        setState(() {
          _progress = (received / total * 100).toInt().toString();
        });
      } else {
        setState(() {
          _isLoading = false;
          _progress = 'Download Maps';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download complete!')),
        );
      }
    });

    return file;
  }

  String buttontext = 'Sync';
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocListener<AuthCubit, authData>(
        listener: (context, state) {
          if (state.checkAuth is InitialState) {
            if (checkNav == true) {
              setState(() {
                checkNav = false;
              });
            }
          }
        },
        child: Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.black,
              image: DecorationImage(
                opacity: 0.5,
                image: AssetImage('assets/icons/images.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
            child: FutureBuilder<SharedPreferences>(
              future: SharedPreferences.getInstance(),
              builder: (contextPref, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final prefs = snapshot.data!;
                final name = prefs.getString("name");
                if (name == null) {}
                return BlocConsumer<MapsCubit, MapsData>(
                  listener: (contextMap, state) {
                    if (state.sendSync is LoadingState) {
                      setState(() {
                        buttontext = 'Loading..';
                      });
                    } else if (state.sendSync is SuccessState<bool>) {
                      setState(() {
                        buttontext = 'Berhasil..';
                      });
                    } else if (state.sendSync is InitialState) {
                      setState(() {
                        buttontext = 'Sync';
                      });
                    } else {
                      setState(() {
                        buttontext = 'Sync';
                      });
                      if (state.sendSync is GeneralErrorState) {
                        showSnackbar(contextMap,
                            message: 'Error Sync', status: Status.Error);
                      }
                    }
                  },
                  builder: (contextMap, state) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 100),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Go Harvest'.toUpperCase(),
                            style: textHeading.copyWith(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 100),
                        Visibility(
                          visible: (buttontext != 'Loading..'),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: flatButton(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const FlutterMapPage(
                                      isHistory: false,
                                      title: 'Harvest',
                                    ),
                                  ),
                                );
                              },
                              context: context,
                              title: 'Harvest',
                              backgroundColor: primaryColor,
                              icon: Icons.shopping_cart_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Visibility(
                          visible: (buttontext != 'Loading..'),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: flatButton(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const FlutterMapPage(
                                      isHistory: true,
                                      title: 'History',
                                    ),
                                  ),
                                );
                              },
                              context: context,
                              title: 'History',
                              backgroundColor: primaryColor,
                              icon: Icons.shopping_cart_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Visibility(
                          visible: (buttontext != 'Loading..'),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: flatButton(
                              context: context,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const HasilPanenPage(
                                      title: 'Hasil Panen',
                                    ),
                                  ),
                                );
                              },
                              title: 'Hasil Panen',
                              backgroundColor: primaryColor,
                              icon: Icons.timer_outlined,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Visibility(
                          visible: true,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: flatButton(
                              context: context,
                              onTap: () {
                                downloadFile();
                              },
                              title: _progress.toString(),
                              backgroundColor: primaryColor,
                              icon: Icons.timer_outlined,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Visibility(
                          visible: true,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: flatButton(
                              context: context,
                              onTap: () {
                                context
                                    .read<MapsCubit>()
                                    .installation('online');
                              },
                              title: buttontext,
                              backgroundColor: primaryColor,
                              icon: Icons.timer_outlined,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Visibility(
                          visible: (buttontext != 'Loading..'),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: flatButton(
                              context: context,
                              onTap: () {
                                context.read<AuthCubit>().logout();
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginPage(),
                                  ),
                                );
                                showSnackbar(context,
                                    message: 'Berhasil Logout',
                                    status: Status.Success);
                              },
                              title: 'Logout',
                              backgroundColor: primaryColor,
                              icon: Icons.timer_outlined,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 100),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Version 0.1 Demo'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
