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
import 'package:path/path.dart' as path;

bool checkNav = true;

class MainMenuPage extends StatefulWidget {
  const MainMenuPage({super.key});

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  String _progress = 'Download Maps';
  List<int> bytes = [];
  int downloaded = 0;
  bool filesMaps = false;

  @override
  void initState() {
    super.initState();
    checkNav = true;
    checkMbtilesFile();
  }

  void checkMbtilesFile() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final mbtilesFile = File(path.join(documentsDir.path, 'map.mbtiles'));

    if (await mbtilesFile.exists()) {
      setState(() {
        filesMaps = true;
      });
    } else {
      setState(() {
        filesMaps = false;
      });
    }
  }

  Future<void> downloadFile() async {
    setState(() {
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
    url = 'https://cms-bum.tvindo.net/assets/tiles/map1.mbtiles';
    final request = http.Request('GET', Uri.parse(url));
    await request.send();
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);

    Dio dio = Dio();

    await dio.download(url, filePath, onReceiveProgress: (received, total) {
      if (total != -1) {
        setState(() {
          _progress = (received / total * 100).toInt().toString();
          if (_progress == '100') {
            _progress = 'done';
            checkMbtilesFile();
          }
        });
      } else {
        setState(() {
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
    bool hasSynced = false;
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
                        buttontext = 'Sync';
                      });

                      if (hasSynced == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Berhasil sync!',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 3),
                          ),
                        );
                        hasSynced = false;
                      }
                    } else if (state.sendSync is InitialState) {
                      setState(() {
                        buttontext = 'Sync';
                      });
                      hasSynced = false;
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
                          visible:
                              (buttontext != 'Loading..' && filesMaps == true),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: flatButton(
                              onTap: () {
                                hasSynced = false;
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
                          visible:
                              (buttontext != 'Loading..' && filesMaps == true),
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
                          visible: state.sendSync is SuccessState<bool>,
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
                          visible: state.sendSync is SuccessState<bool>,
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
                          visible: state.sendSync is SuccessState<bool>,
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
