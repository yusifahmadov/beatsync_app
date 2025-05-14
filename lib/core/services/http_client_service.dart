import '../models/http_response.dart';

typedef FromJsonFunction<T> = T Function(dynamic json);

abstract class HttpClientService {
  Future<HttpResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    FromJsonFunction<T>? fromJson,
  });

  Future<HttpResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    FromJsonFunction<T>? fromJson,
  });

  Future<HttpResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    FromJsonFunction<T>? fromJson,
  });

  Future<HttpResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    FromJsonFunction<T>? fromJson,
  });

  Future<HttpResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    FromJsonFunction<T>? fromJson,
  });
}
