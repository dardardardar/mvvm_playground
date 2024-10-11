import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mvvm_playground/const/theme.dart';
import 'package:mvvm_playground/features/cubit/auth_cubit.dart';
import 'package:mvvm_playground/features/cubit/auth_cubit_data.dart';
import 'package:mvvm_playground/features/cubit/maps_cubit.dart';
import 'package:mvvm_playground/features/pages/login_page.dart';
import 'package:mvvm_playground/features/pages/main_menu_page.dart';
import 'package:mvvm_playground/features/repository/auth_repo.dart';
import 'package:mvvm_playground/features/repository/crud_repo.dart';
import 'package:mvvm_playground/features/response/trialConstant.dart';
import 'package:mvvm_playground/features/state/base_state.dart';
import 'package:mvvm_playground/functions/geolocation.dart';
import 'package:mvvm_playground/functions/location.dart';
import 'package:mvvm_playground/functions/set_location.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

final getIt = GetIt.instance;

void setup() {
  final _crudRepository = CRUDRepository();
  final mapsCubit = MapsCubit(_crudRepository);
  getIt.registerSingleton<MapsCubit>(mapsCubit);

  final _authRepository = AuthRepository();
  final authCubit = AuthCubit(_authRepository);
  getIt.registerSingleton<AuthCubit>(authCubit);

  determinePosition();
}

void initialLoading() {
  getIt.get<AuthCubit>().initialLogin();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setup();
  initialLoading();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Timer? _trialTimer;
  bool chcekCubit = false;

  Future<void> _checkTrial() async {
    getIt.get<AuthCubit>().checkTrial();
  }

  Future<void> _startTrialTimer() async {
    _trialTimer?.cancel();
    _trialTimer = Timer.periodic(Duration(seconds: 60), (timer) async {
      await _checkTrial();
      await _startConnectivityCheck();
    });
  }

  Future<void> _startConnectivityCheck() async {
    while (true) {
      Future.delayed(Duration(seconds: 1));
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult[0] == ConnectivityResult.mobile ||
          connectivityResult[0] == ConnectivityResult.wifi) {
        setState(() {
          connectivityStatus = true;
        });
      } else {
        setState(() {
          connectivityStatus = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _startTrialTimer();
  }

  Widget currentPage = const LoginPage();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt.get<MapsCubit>()),
        BlocProvider(create: (_) => getIt.get<AuthCubit>()),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<AuthCubit, authData>(listener: (context, state) {
            final ress = (state.checkTrial as SuccessState).data;
            if (ress == 'Trial') {
              setState(() {
                checkingTrial = 'Trial';
              });
            } else {
              setState(() {
                checkingTrial = 'Full';
              });
            }
            if (state.checkAuth is SuccessState &&
                state.checkTrial is SuccessState<String>) {
              if ((state.checkTrial as SuccessState).data != 'Trial') {
                setState(() {
                  currentPage = const MainMenuPage();
                });
              }
            } else if (state.checkTrial is SuccessState<String> &&
                state.checkAuth is InitialState) {
              if ((state.checkTrial as SuccessState).data != 'Trial') {
                setState(() {
                  currentPage = const LoginPage();
                });
              }
            } else if (state.checkTrial is SuccessState<String> &&
                state.checkAuth is ErrorState) {
              if ((state.checkTrial as SuccessState).data != 'Trial') {
                setState(() {
                  currentPage = const LoginPage();
                });
              }
            } else {
              if ((state.checkTrial as SuccessState<String>).data == 'Trial') {
                setState(() {
                  checkingTrial = 'Trial';
                  currentPage = const LoginPage();
                });
              }
            }
          }),
        ],
        child: StreamProvider<GeoLocation>(
          initialData: GeoLocation.createZeroUserPoint(),
          create: (context) => LocationService().locationStream,
          child: MaterialApp(
            title: 'Flutter Demo',
            theme: theme,
            home: currentPage,
          ),
        ),
      ),
    );
  }
}
