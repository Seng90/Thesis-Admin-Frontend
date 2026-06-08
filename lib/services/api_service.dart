import 'package:dio/dio.dart';
export 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors for token injection and error handling
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Get token from secure storage / shared preferences
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          String userFriendlyMessage = 'An unexpected error occurred.';
          
          if (e.type == DioExceptionType.connectionTimeout || 
              e.type == DioExceptionType.receiveTimeout || 
              e.type == DioExceptionType.sendTimeout) {
            userFriendlyMessage = 'Connection timed out. Please check your internet connection.';
          } else if (e.type == DioExceptionType.connectionError) {
            userFriendlyMessage = 'Cannot connect to the server. Please verify your connection.';
          } else if (e.response != null) {
            final statusCode = e.response?.statusCode;
            final data = e.response?.data;
            
            if (statusCode == 401) {
              userFriendlyMessage = 'Session expired or unauthorized. Please log in again.';
              // Note: We can emit an event or use a global navigator key here to force logout.
            } else if (statusCode == 403) {
              userFriendlyMessage = 'You do not have permission to perform this action.';
            } else if (statusCode == 404) {
              userFriendlyMessage = 'The requested resource was not found.';
            } else if (statusCode == 500) {
              userFriendlyMessage = 'Internal server error. Please try again later.';
            } else if (data is Map && data['message'] != null) {
              userFriendlyMessage = data['message'].toString();
            } else {
              userFriendlyMessage = 'Server error ($statusCode).';
            }
          }
          
          final customError = DioException(
            requestOptions: e.requestOptions,
            response: e.response,
            type: e.type,
            error: userFriendlyMessage,
          );
          
          return handler.next(customError);
        },
      ),
    );
  }

  Dio get client => _dio;
}
