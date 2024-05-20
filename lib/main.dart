import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mvvm_playground/const/theme.dart';
import 'package:mvvm_playground/features/cubit/home_cubit.dart';
import 'package:mvvm_playground/features/cubit/maps_cubit.dart';
import 'package:mvvm_playground/features/pages/flutter_maps_page.dart';
import 'package:mvvm_playground/features/repository/crud_repo.dart';
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
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setup();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeCubit>(
          create: (_) => HomeCubit(),
        ),
        BlocProvider(create: (_) => getIt.get<MapsCubit>()),
      ],
      child: StreamProvider<GeoLocation>(
        initialData: GeoLocation.createZeroUserPoint(),
        create: (context) => LocationService().locationStream,
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: theme,
          home: const FlutterMapPage(),
        ),
      ),
    );
  }
}
