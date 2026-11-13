import 'package:dio/dio.dart';

/// A user-friendly error thrown by the data layer.
///
/// Dio exceptions are translated here so that UI code never has to know
/// anything about Dio and can simply show [message].
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  factory ApiException.fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          'The request timed out. Please check your connection and try again.',
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          'No internet connection. Please check your network and retry.',
        );
      case DioExceptionType.badResponse:
        final int? code = error.response?.statusCode;
        if (code == 404) {
          return ApiException('We could not find what you were looking for.',
              statusCode: code);
        }
        if (code != null && code >= 500) {
          return ApiException(
            'The server is having trouble right now. Please try again later.',
            statusCode: code,
          );
        }
        return ApiException('Something went wrong (error $code).',
            statusCode: code);
      case DioExceptionType.cancel:
        return const ApiException('The request was cancelled.');
      case DioExceptionType.badCertificate:
        return const ApiException(
          'A secure connection could not be established.',
        );
      case DioExceptionType.unknown:
        return const ApiException(
          'Something unexpected happened. Please try again.',
        );
    }
  }

  @override
  String toString() => message;
}