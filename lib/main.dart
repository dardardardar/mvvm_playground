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
  bool _isOnline = false;

  Future<void> _startConnectivityCheck() async {
    while (true) {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult[0] == ConnectivityResult.mobile ||
          connectivityResult[0] == ConnectivityResult.wifi) {
        setState(() {
          _isOnline = true;
        });
      } else {
        setState(() {
          _isOnline = false;
        });
      }
      await Future.delayed(Duration(seconds: 4));
    }
  }

  @override
  void initState() {
    super.initState();
    _startConnectivityCheck();
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
          BlocListener<AuthCubit, authData>(
            listener: (context, state) {
              if (state.sendAuth is SuccessState) {
                setState(() {
                  currentPage = const MainMenuPage();
                });
              } else if (state.sendAuth is InitialState) {
                setState(() {
                  currentPage = const LoginPage();
                });
              } else if (state.sendAuth is ErrorState) {
                setState(() {
                  currentPage = const LoginPage();
                });
              }
            },
          ),
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
