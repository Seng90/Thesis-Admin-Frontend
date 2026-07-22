import 'package:dio/dio.dart';
export 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  static void Function()? onUnauthorized;

  late final Dio _dio;

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

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
          
          // Prevent aggressive browser caching on Web for GET requests
          if (options.method == 'GET') {
            options.queryParameters['_t'] = DateTime.now().millisecondsSinceEpoch.toString();
            options.headers['Cache-Control'] = 'no-cache, no-store, must-revalidate';
            options.headers['Pragma'] = 'no-cache';
            options.headers['Expires'] = '0';
          }
          
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          String userFriendlyMessage = 'An unexpected error occurred.';

          if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.sendTimeout) {
            userFriendlyMessage =
                'Connection timed out. Please check your internet connection.';
          } else if (e.type == DioExceptionType.connectionError) {
            userFriendlyMessage =
                'Cannot connect to the server. Please verify your connection.';
          } else if (e.response != null) {
            final statusCode = e.response?.statusCode;
            final data = e.response?.data;

            if (statusCode == 401) {
              // Try to refresh token before failing
              if (e.requestOptions.path != '/auth/refresh' &&
                  e.requestOptions.path != '/auth/login') {
                try {
                  final prefs = await SharedPreferences.getInstance();
                  final refreshToken = prefs.getString('refresh_token');

                  if (refreshToken != null && refreshToken.isNotEmpty) {
                    // Create a new Dio instance just for refresh to avoid interceptor loops
                    final refreshDio = Dio(
                      BaseOptions(baseUrl: AppConstants.baseUrl),
                    );
                    final refreshResponse = await refreshDio.post(
                      '/auth/refresh',
                      data: {'refresh_token': refreshToken},
                    );

                    if (refreshResponse.statusCode == 200 ||
                        refreshResponse.statusCode == 201) {
                      final newAccessToken =
                          refreshResponse.data['access_token'];
                      final newRefreshToken =
                          refreshResponse.data['refresh_token'];

                      await prefs.setString('auth_token', newAccessToken);
                      await prefs.setString('refresh_token', newRefreshToken);

                      // Retry the original request with the new token
                      final opts = e.requestOptions;
                      opts.headers['Authorization'] = 'Bearer $newAccessToken';

                      final cloneReq =
                          await Dio(
                            BaseOptions(baseUrl: AppConstants.baseUrl),
                          ).request(
                            opts.path,
                            options: Options(
                              method: opts.method,
                              headers: opts.headers,
                            ),
                            data: opts.data,
                            queryParameters: opts.queryParameters,
                          );

                      return handler.resolve(cloneReq);
                    }
                  }
                } catch (_) {
                  // Refresh failed, proceed to normal 401 handling
                }
              }

              if (e.requestOptions.path != '/auth/refresh' &&
                  e.requestOptions.path != '/auth/login') {
                if (onUnauthorized != null) {
                  onUnauthorized!();
                }
              }

              userFriendlyMessage =
                  'Session expired or unauthorized. Please log in again.';
            } else if (statusCode == 403) {
              userFriendlyMessage =
                  'You do not have permission to perform this action.';
            } else if (statusCode == 404) {
              userFriendlyMessage = 'The requested resource was not found.';
            } else if (statusCode == 500) {
              userFriendlyMessage =
                  'Internal server error. Please try again later.';
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
