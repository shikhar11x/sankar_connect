import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import 'api_exception.dart';

/// Dio wrapper used by every service.
///
/// Responsibilities:
/// * configures base URL and timeouts once,
/// * retries transient network failures automatically,
/// * converts every failure into a friendly [ApiException].
class ApiClient {
  ApiClient({Dio? dio, this.maxRetries = 2})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: ApiConstants.baseUrl,
              connectTimeout: ApiConstants.connectTimeout,
              receiveTimeout: ApiConstants.receiveTimeout,
              headers: const <String, dynamic>{'Accept': 'application/json'},
            ),
          );

  final Dio _dio;

  /// How many extra attempts are made for transient failures.
  final int maxRetries;

  Future<T> get<T>(String path, {Map<String, dynamic>? query}) async {
    int attempt = 0;
    while (true) {
      try {
        final Response<dynamic> response = await _dio.get<dynamic>(
          path,
          queryParameters: query,
        );
        final Object? data = response.data;
        if (data is T) return data;
        throw const ApiException('Received an unexpected response format.');
      } on DioException catch (error) {
        if (_isTransient(error) && attempt < maxRetries) {
          attempt++;
          await Future<void>.delayed(Duration(milliseconds: 600 * attempt));
          continue;
        }
        throw ApiException.fromDioException(error);
      }
    }
  }

  bool _isTransient(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      default:
        return false;
    }
  }
}
