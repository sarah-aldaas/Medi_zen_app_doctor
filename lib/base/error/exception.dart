import 'package:dio/dio.dart';

enum ErrorType { noInternet, badRequest, unauthorised, forbidden, success, dataParsing, other }

class ServerException implements Exception {
  late DioException dioException;
  late String? message;
  final bool? payByAPI;
  late ErrorType? errorType;

  ServerException({required this.dioException, this.message, this.errorType, this.payByAPI});

  ServerException.withException({required DioException dioError, this.payByAPI});
}

class CubitException implements Exception {
  late String? message;
  late ErrorType? errorType;

  CubitException({this.errorType, this.message});
}

class NoInternetException implements Exception {
  final String message;

  NoInternetException({required this.message});
}

class CacheException implements Exception {}
