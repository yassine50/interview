import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  factory ApiException.fromDio(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;

    if (data is Map &&
        data['error'] != null &&
        data['error'].toString().isNotEmpty) {
      return ApiException(data['error'].toString(), statusCode: status);
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          'Request timed out, please try again.',
          statusCode: status,
        );
      case DioExceptionType.connectionError:
        return ApiException(
          'Unable to reach the server. Check your connection.',
          statusCode: status,
        );
      case DioExceptionType.badResponse:
        if (status == 404) {
          return ApiException('Note not found.', statusCode: 404);
        }
        if (status == 400) {
          return ApiException('Invalid request data.', statusCode: 400);
        }
        if (status == 405) {
          return ApiException('Method not allowed.', statusCode: 405);
        }
        if (status != null && status >= 500) {
          return ApiException(
            'Server error ($status). Please try later.',
            statusCode: status,
          );
        }
        return ApiException('Request failed ($status).', statusCode: status);
      default:
        return ApiException(e.message ?? 'Network error.', statusCode: status);
    }
  }

  @override
  String toString() => message;
}
