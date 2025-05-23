import 'package:dio/dio.dart';

class ServerException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic responseData;

  ServerException({
    required this.message,
    this.statusCode,
    this.responseData,
  });

  factory ServerException.fromDioException(DioException dioException) {
    String message;
    int? statusCode = dioException.response?.statusCode;
    dynamic responseData = dioException.response?.data;

    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timed out. Please try again.';
        break;
      case DioExceptionType.badResponse:
        if (statusCode == 400) {
          message = responseData is Map && responseData['msg'] != null
              ? responseData['msg']
              : 'Invalid request. Please check your input.';
        } else if (statusCode == 401) {
          message = 'Unauthorized. Please log in again.';
        } else if (statusCode == 403) {
          message = 'Forbidden. You do not have permission.';
        } else if (statusCode == 404) {
          message = 'Resource not found.';
        } else if (statusCode == 500) {
          message = 'Server error. Please try again later.';
        } else {
          message = responseData is Map && responseData['msg'] != null
              ? responseData['msg']
              : 'An error occurred. Please try again.';
        }
        break;
      case DioExceptionType.cancel:
        message = 'Request was cancelled.';
        break;
      case DioExceptionType.connectionError:
        message = 'No internet connection. Please check your network.';
        break;
      case DioExceptionType.badCertificate:
        message = 'Invalid SSL certificate.';
        break;
      case DioExceptionType.unknown:
      default:
        message = 'An unexpected error occurred. Please try again.';
        break;
    }

    return ServerException(
      message: message,
      statusCode: statusCode,
      responseData: responseData,
    );
  }

  @override
  String toString() => 'ServerException: $message (Status: $statusCode)';
}