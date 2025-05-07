
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../configuration/app_config.dart';
import '../network/network_client.dart';
import 'injection_container_common.dart';

class NetworkClientDependencyInjection {
  static Future<void> initDi() async {
    final Dio dio = Dio();
    BaseOptions baseOptions = BaseOptions(
        headers: {
          "Access-Control-Allow-Origin": '*',
          "Access-Control-Allow-Credentials": true, // Required for cookies, authorization headers with HTTPS
          "Access-Control-Allow-Headers": "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
          "Access-Control-Allow-Methods": "*"
        },
        // Default receive timeout
        receiveTimeout: const Duration(milliseconds: 30000),
        // Default connect timeout
        connectTimeout: const Duration(milliseconds: 30000),
        baseUrl: AppConfig.baseUrl,
        contentType: Headers.jsonContentType,
        maxRedirects: 2);

    dio.options = baseOptions;
    dio.options.contentType = Headers.formUrlEncodedContentType;

    // try {
    //   (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
    //     final client = HttpClient();
    //     client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    //     return client;
    //   };
    // } catch (e) {
    //   logger.e(e, StackTrace.current);
    // }

    dio.interceptors.clear();

    // Logger for API calls.
    dio.interceptors.add(PrettyDioLogger(
        requestBody: true, error: true, request: true, compact: true, maxWidth: 90, requestHeader: true, responseBody: true, responseHeader: false));

    // If we need to call refresh access token API.
    // We can modify below network interceptor.
    dio.interceptors.add(InterceptorsWrapper(onError: (DioException error, handler) {
      return handler.next(error);
    }, onRequest: (RequestOptions requestOptions, handler) async {
      // TODO:  Get latest access token from preferences
      var accessToken = "";
      if (accessToken != "") {
        var authHeader = {'Authorization': 'Bearer $accessToken'};
        requestOptions.headers.addAll(authHeader);
      }
      return handler.next(requestOptions);
    }, onResponse: (response, handler) async {
      return handler.next(response);
    }));

    serviceLocator.registerLazySingleton(() => dio);

    // Network Client.
    serviceLocator.registerLazySingleton(() => NetworkClient(dio: serviceLocator(), logger: serviceLocator(), storageService: serviceLocator()));
  }
}
