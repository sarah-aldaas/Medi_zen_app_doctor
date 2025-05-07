import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

import '../../constant/storage_key.dart';
import '../../error/exception.dart';
import '../../helpers/enums.dart';
import '../logger/logging.dart';
import '../storage/storage_service.dart';

class NetworkClient {
  final Dio dio;
  final LogService logger;
  final StorageService storageService;

  NetworkClient({required this.dio, required this.logger, required this.storageService /*required this.firebaseLogger*/
      });

  Future<Response> invoke(String url, RequestType requestType, {Map<String, dynamic>? queryParameters, Map<String, dynamic>? headers, dynamic body}) async {
    logger.i(url);
    String? token = storageService.getFromDisk(StorageKey.token);
    logger.f(token);
    dio.options.headers.addAll({'Authorization': 'Bearer $token'});
    Response? response;
    try {
      switch (requestType) {
        case RequestType.get:
          response = await dio.get(url, queryParameters: queryParameters, options: Options(responseType: ResponseType.json, headers: headers));
          break;
        case RequestType.post:
          response = await dio.post(url, queryParameters: queryParameters, data: body, options: Options(responseType: ResponseType.json, headers: headers));
          break;
        case RequestType.put:
          response = await dio.put(url, queryParameters: queryParameters, data: body, options: Options(responseType: ResponseType.json, headers: headers));
          break;
        case RequestType.delete:
          response = await dio.delete(url, queryParameters: queryParameters, data: body, options: Options(responseType: ResponseType.json, headers: headers));
          break;
        case RequestType.patch:
          response = await dio.patch(url, queryParameters: queryParameters, data: body, options: Options(responseType: ResponseType.json, headers: headers));
          break;
      }
      return response;
    } on DioException catch (dioException) {
      logger.e('$runtimeType on DioError:-  $dioException', StackTrace.current);
      // FirebaseCrashlytics.instance.recordFlutterError(FlutterErrorDetails(exception: dioError));
      throw ServerException(dioException: dioException);
    } on SocketException catch (exception) {
      logger.e('$runtimeType on SocketException:-  $exception', StackTrace.current);
      // FirebaseCrashlytics.instance.recordFlutterError(FlutterErrorDetails(exception: exception));
      rethrow;
    }
  }
}
