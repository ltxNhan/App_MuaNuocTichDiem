import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_endpoints.dart';

class DioClient {
  late final Dio _dio;
  final FlutterSecureStorage _storage;

  static const String _accessTokenKey = 'brewpoint_access_token';
  static const String _refreshTokenKey = 'brewpoint_refresh_token';

  DioClient(this._storage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // Automatic token refresh handling on 401
          if (error.response?.statusCode == 401) {
            final refreshToken = await getRefreshToken();
            if (refreshToken != null && refreshToken.isNotEmpty) {
              try {
                final refreshResponse = await Dio(
                  BaseOptions(baseUrl: AppEndpoints.baseUrl),
                ).post(
                  AppEndpoints.refreshToken,
                  data: {'refresh_token': refreshToken},
                );

                if (refreshResponse.statusCode == 200 &&
                    refreshResponse.data['success'] == true) {
                  final newAccessToken =
                      refreshResponse.data['data']['accessToken'];
                  final newRefreshToken =
                      refreshResponse.data['data']['refreshToken'];

                  await saveTokens(newAccessToken, newRefreshToken);

                  // Retry the original request
                  final retryOptions = error.requestOptions;
                  retryOptions.headers['Authorization'] =
                      'Bearer $newAccessToken';

                  final response = await _dio.fetch(retryOptions);
                  return handler.resolve(response);
                }
              } catch (_) {
                // If refresh token also fails, clear storage
                await clearTokens();
              }
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}
