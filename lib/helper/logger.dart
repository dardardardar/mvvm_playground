// ignore: library_prefixes
import 'dart:developer' as Dev;

import 'package:mvvm_playground/const/enums.dart';

class Logger {
  static void log(
      {required LogStatus status,
      String? function,
      String? className,
      String? message,
      Exception? exception,
      StackTrace? stackTrace}) {
    final fun = function != null ? 'on Function: $function\n' : '';
    final msg = message != null ? 'Message: $message\n' : '';
    final err = exception != null ? 'Exception: $exception\n' : '';
    final st = stackTrace != null ? 'Stack Trace: $stackTrace\n' : '';
    final cl = className != null ? 'on Class: $className\n' : '';
    final string =
        '${status.name.toUpperCase()} - ${DateTime.now().toIso8601String()}\n$msg$cl$fun$err$st';
    if (status == LogStatus.Info) {
      Dev.log('\x1B[34m$string\x1B[0m');
    } else if (status == LogStatus.Warning) {
      Dev.log('\x1B[33m$string\x1B[0m');
    } else {
      Dev.log('\x1B[31m$string\x1B[0m');
    }
  }
}
