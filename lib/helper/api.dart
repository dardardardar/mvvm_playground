import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

enum LogType { INFO, WARN, ERROR }

final getIt = GetIt.instance;
final dio = Dio();

class DioExceptionCubit extends Cubit<bool> {
  DioExceptionCubit(super.initialState);
  showTimeoutError() {
    emit(true);
    emit(false);
  }
}

class Api {
  static String BASE_URL = 'sinarmas.tvindo.net';
  static String URL(endpoint, {data}) {
    return Uri.https(BASE_URL, endpoint, data).toString();
  }

  static Future<Options> getOptions({contentType, usebearer = true}) async {
    Map<String, String> headers = {
      'Content-Type': contentType ?? 'application/json',
    };

    return Options(
      headers: headers,
      receiveDataWhenStatusError: true,
      followRedirects: false,
      receiveTimeout: Duration(minutes: 1),
      validateStatus: (status) {
        return status! < 500;
      },
    );
  }

  static Future<Response> post(
    endpoint,
    data, {
    contentType,
    queryparam,
  }) async {
    try {
      final options = await getOptions(
        contentType: contentType,
      );
      final url = URL(endpoint);
      final result = await dio.post(
        url,
        options: options,
        data: data,
        queryParameters: queryparam,
      );
      return result;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.receiveTimeout) {
        getIt.get<DioExceptionCubit>().showTimeoutError();
      }
      rethrow;
    }
  }

  static Future<Response> get(
    endpoint, {
    Map<String, dynamic>? data,
    contentType,
    usebearer = true,
    queryparam,
  }) async {
    try {
      final options = await getOptions(
        contentType: contentType,
        usebearer: usebearer,
      );
      final result = await dio.get(
        URL(endpoint, data: data),
        options: options,
        queryParameters: queryparam,
      );
      return result;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.receiveTimeout) {
        getIt.get<DioExceptionCubit>().showTimeoutError();
      }
      rethrow;
    }
  }
}
