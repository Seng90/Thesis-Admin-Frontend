import 'package:dio/dio.dart';

class ErrorHandler {
  static String getErrorMessage(dynamic error, {String defaultMessage = 'An unexpected error occurred'}) {
    if (error is DioException && error.error != null) {
      return error.error.toString();
    }
    return '$defaultMessage: $error';
  }
}
