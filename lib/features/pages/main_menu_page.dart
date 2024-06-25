import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mvvm_playground/const/enums.dart';
import 'package:mvvm_playground/const/theme.dart';
import 'package:mvvm_playground/features/cubit/auth_cubit.dart';
import 'package:mvvm_playground/features/cubit/maps_cubit.dart';
import 'package:mvvm_playground/features/cubit/maps_cubit_data.dart';
import 'package:mvvm_playground/features/pages/dataset_page.dart';
import 'package:mvvm_playground/features/pages/flutter_maps_page.dart';
import 'package:mvvm_playground/features/state/base_state.dart';
import 'package:mvvm_playground/widgets/buttons.dart';
import 'package:mvvm_playground/widgets/snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainMenuPage extends StatefulWidget {
  const MainMenuPage({super.key});

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  String buttontext = 'Sync';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final prefs = snapshot.data!;
              final name = prefs.getString("name") ?? "User";

              return BlocConsumer<MapsCubit, MapsData>(
                listener: (context, state) {
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
                      showSnackbar(context,
                          message: 'Error Sync', status: Status.Error);
                    }
                  }
                },
                builder: (context, state) {
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
                      Padding(
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
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: flatButton(
                          context: context,
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
                          title: 'History',
                          backgroundColor: primaryColor,
                          icon: Icons.timer_outlined,
                          color: Colors.white,
                        ),
                      ),
                      Visibility(
                        visible: true,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: flatButton(
                            context: context,
                            onTap: () {
                              context.read<MapsCubit>().instalation('online');
                            },
                            title: buttontext,
                            backgroundColor: primaryColor,
                            icon: Icons.timer_outlined,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: flatButton(
                          context: context,
                          onTap: () {
                            context.read<AuthCubit>().logout();
                            Navigator.of(context, rootNavigator: true).pop();
                          },
                          title: 'Logout',
                          backgroundColor: primaryColor,
                          icon: Icons.timer_outlined,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 100),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Version 0.1'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
