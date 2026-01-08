// lib/services/api_client.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:meetzone/core/app_constants.dart';
import 'package:meetzone/services/storage_service.dart';

class ApiClient {
  static bool _isRefreshing = false;
  static final List<void Function(String)> _pendingRequests = [];

  static final Dio _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    )
    ..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          debugPrint('REQUEST[${options.method}] => PATH: ${options.path}');
          debugPrint('PAYLOAD: ${options.data}');

          // Add Auth Token
          final token = await StorageService.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint(
            'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
          );
          debugPrint('DATA: ${response.data}');
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          debugPrint(
            'ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}',
          );
          debugPrint('MESSAGE: ${e.message}');
          if (e.response != null) {
            debugPrint('ERROR DATA: ${e.response?.data}');
          }

          // Handle 401 Unauthorized - Token Expired
          if (e.response?.statusCode == 401 &&
              !e.requestOptions.path.contains('/auth/refresh')) {
            final refreshToken = await StorageService.getRefreshToken();

            if (refreshToken != null) {
              if (!_isRefreshing) {
                _isRefreshing = true;

                try {
                  debugPrint('🔄 Access token expired, refreshing...');

                  // Call refresh endpoint
                  final refreshResponse = await Dio(
                    BaseOptions(baseUrl: ApiConstants.baseUrl),
                  ).post(
                    ApiConstants.refreshToken,
                    data: {'refresh_token': refreshToken},
                  );

                  final newAccessToken = refreshResponse.data['access_token'];
                  final newRefreshToken = refreshResponse.data['refresh_token'];

                  // Save new tokens
                  await StorageService.saveTokens(
                    accessToken: newAccessToken,
                    refreshToken: newRefreshToken,
                  );

                  debugPrint('✅ Token refreshed successfully');

                  // Update the failed request with new token
                  e.requestOptions.headers['Authorization'] =
                      'Bearer $newAccessToken';

                  // Process pending requests
                  for (var callback in _pendingRequests) {
                    callback(newAccessToken);
                  }
                  _pendingRequests.clear();

                  _isRefreshing = false;

                  // Retry the original request
                  final response = await _dio.fetch(e.requestOptions);
                  return handler.resolve(response);
                } catch (refreshError) {
                  debugPrint('❌ Token refresh failed: $refreshError');
                  _isRefreshing = false;
                  _pendingRequests.clear();

                  // Clear all data and force logout
                  await StorageService.clearAll();

                  return handler.next(e);
                }
              } else {
                // Token is being refreshed, wait for it
                debugPrint('⏳ Waiting for token refresh...');
                return handler.next(e);
              }
            }
          }

          return handler.next(e);
        },
      ),
    );

  // Optional: Add token automatically on every request
  static void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  static void clearToken() {
    _dio.options.headers.remove('Authorization');
  }

  // Getter so we can use it everywhere
  static Dio get dio => _dio;
}


