// lib/base/services/network/network_client.dart
import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:medi_zen_app_doctor/base/configuration/app_config.dart';

import '../../../main.dart';
import '../../constant/storage_key.dart';
import '../../error/exception.dart';
import '../../helpers/enums.dart';
import '../logger/logging.dart';
import '../storage/storage_service.dart';

class NetworkClient {
  final Dio dio;
  final LogService logger;
  final StorageService storageService;

  NetworkClient({
    required this.dio,
    required this.logger,
    required this.storageService,
  });

  Future<Response> invoke(
    String url,
    RequestType requestType, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    dynamic body,
    Options? options,
  }) async {
    logger.i(url);
    // String? token = storageService.getFromDisk(StorageKey.token);
    logger.f(token);

    final mergedHeaders = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...?headers,
    };

    final mergedOptions = Options(
      responseType: options?.responseType ?? ResponseType.json,
      headers: options?.headers ?? mergedHeaders,
      extra: options?.extra ?? {},
      followRedirects: options?.followRedirects ?? true,
      maxRedirects: options?.maxRedirects ?? 5,
      method: options?.method,
      receiveDataWhenStatusError: options?.receiveDataWhenStatusError ?? true,
      receiveTimeout: options?.receiveTimeout,
      sendTimeout: options?.sendTimeout,
      validateStatus: options?.validateStatus,
    );

    Response? response;
    try {
      switch (requestType) {
        case RequestType.get:
          response = await dio.get(
            AppConfig.baseUrl + url,
            queryParameters: queryParameters,
            options: mergedOptions,
          );
          break;
        case RequestType.post:
          response = await dio.post(
            AppConfig.baseUrl + url,
            queryParameters: queryParameters,
            data: body,
            options: mergedOptions,
          );
          break;
        case RequestType.put:
          response = await dio.put(
            AppConfig.baseUrl + url,
            queryParameters: queryParameters,
            data: body,
            options: mergedOptions,
          );
          break;
        case RequestType.delete:
          response = await dio.delete(
            AppConfig.baseUrl + url,
            queryParameters: queryParameters,
            data: body,
            options: mergedOptions,
          );
          break;
        case RequestType.patch:
          response = await dio.patch(
            AppConfig.baseUrl + url,
            queryParameters: queryParameters,
            data: body,
            options: mergedOptions,
          );
          break;
      }
      return response;
    } on DioException catch (dioException) {
      logger.e(
        '$runtimeType on DioException:- $dioException',
        StackTrace.current,
      );
      throw ServerException.fromDioException(dioException);
    } on SocketException catch (exception) {
      logger.e(
        '$runtimeType on SocketException:- $exception',
        StackTrace.current,
      );
      throw ServerException(
        message: 'No internet connection. Please check your network.',
        statusCode: null,
        responseData: null,
      );
    }
  }

  Future<Response> invokeMultipart(
    String url,
    RequestType requestType, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    required FormData formData,
  }) async {
    logger.i(url);
    // String? token = storageService.getFromDisk(StorageKey.token);
    logger.f(token);
    dio.options.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });
    Response? response;
    try {
      switch (requestType) {
        case RequestType.post:
          response = await dio.post(
            AppConfig.baseUrl + url,
            queryParameters: queryParameters,
            data: formData,
            options: Options(headers: headers),
          );
          break;
        case RequestType.put:
          response = await dio.put(
            AppConfig.baseUrl + url,
            queryParameters: queryParameters,
            data: formData,
            options: Options(headers: headers),
          );
          break;
        case RequestType.patch:
          response = await dio.patch(
            AppConfig.baseUrl + url,
            queryParameters: queryParameters,
            data: formData,
            options: Options(headers: headers),
          );
          break;
        default:
          throw ServerException(
            message: 'Multipart request not supported for $requestType',
            statusCode: null,
            responseData: null,
          );
      }
      return response;
    } on DioException catch (dioException) {
      logger.e(
        '$runtimeType on DioException:- $dioException',
        StackTrace.current,
      );
      throw ServerException.fromDioException(dioException);
    } on SocketException catch (exception) {
      logger.e(
        '$runtimeType on SocketException:- $exception',
        StackTrace.current,
      );
      throw ServerException(
        message: 'No internet connection. Please check your network.',
        statusCode: null,
        responseData: null,
      );
    }
  }
}
