import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('--> ${options.method.toUpperCase()} ${options.uri}');
      debugPrint('Headers:');
      options.headers.forEach((k, v) => debugPrint('$k: $v'));
      if (options.queryParameters.isNotEmpty) {
        debugPrint('queryParameters:');
        options.queryParameters.forEach((k, v) => debugPrint('$k: $v'));
      }
      if (options.data != null) {
        debugPrint('Body: ${options.data}');
      }
      debugPrint('--> END ${options.method.toUpperCase()}');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
          '<-- ${response.statusCode} ${response.requestOptions.method.toUpperCase()} ${response.requestOptions.uri}');
      debugPrint('Headers:');
      response.headers.forEach((k, v) => debugPrint('$k: $v'));
      debugPrint('Response: ${response.data}');
      debugPrint('<-- END HTTP');
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('*** DioException ***:');
      debugPrint('URI: ${err.requestOptions.uri}');
      debugPrint('$err');
      if (err.response != null) {
        debugPrint('Response Data: ${err.response?.data}');
      }
      debugPrint('*** END DioException ***');
    }
    super.onError(err, handler);
  }
}
