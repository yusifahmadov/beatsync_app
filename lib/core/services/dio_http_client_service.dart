import 'package:dio/dio.dart';

import '../errors/network_exceptions.dart';
import '../models/http_response.dart' as custom_response;
import 'http_client_service.dart';

class DioHttpClientService implements HttpClientService {
  final Dio _dio;

  DioHttpClientService(this._dio);

  Future<custom_response.HttpResponse<T>> _handleRequest<T>(
    Future<Response> Function() dioRequest, {
    FromJsonFunction<T>? fromJson,
  }) async {
    try {
      final response = await dioRequest();
      T? responseData;

      if (response.data != null && fromJson != null) {
        try {
          responseData = fromJson(response.data);
        } catch (e, s) {
          throw DataParsingException(
              message: 'Failed to parse response data using provided fromJson: $e',
              stackTrace: s,
              error: e);
        }
      } else if (response.data != null && fromJson == null) {
        if (T == dynamic || T == Object || T == Null) {
          responseData = response.data as T?;
        } else {
          try {
            responseData = response.data as T?;
          } catch (e, s) {
            throw DataParsingException(
                message:
                    'Failed to cast response data (${response.data.runtimeType}) to expected type $T: $e',
                stackTrace: s,
                error: e);
          }
        }
      }

      return custom_response.HttpResponse<T>(
        data: responseData,
        statusCode: response.statusCode,
        headers:
            response.headers.map.map((key, value) => MapEntry(key, value.join(', '))),
      );
    } on DioException catch (e) {
      if (e.error is NetworkException) {
        throw e.error as NetworkException;
      }

      throw UnexpectedException(
          message: e.message ?? 'An unexpected DioError occurred.',
          stackTrace: e.stackTrace,
          error: e);
    } catch (e, s) {
      if (e is NetworkException) rethrow;
      throw UnexpectedException(
          message: 'An unexpected error occurred: $e', stackTrace: s, error: e);
    }
  }

  @override
  Future<custom_response.HttpResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    FromJsonFunction<T>? fromJson,
  }) {
    return _handleRequest(
      () => _dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      ),
      fromJson: fromJson,
    );
  }

  @override
  Future<custom_response.HttpResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    FromJsonFunction<T>? fromJson,
  }) {
    return _handleRequest(
      () => _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      ),
      fromJson: fromJson,
    );
  }

  @override
  Future<custom_response.HttpResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    FromJsonFunction<T>? fromJson,
  }) {
    return _handleRequest(
      () => _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      ),
      fromJson: fromJson,
    );
  }

  @override
  Future<custom_response.HttpResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    FromJsonFunction<T>? fromJson,
  }) {
    return _handleRequest(
      () => _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      ),
      fromJson: fromJson,
    );
  }

  @override
  Future<custom_response.HttpResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    FromJsonFunction<T>? fromJson,
  }) {
    return _handleRequest(
      () => _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      ),
      fromJson: fromJson,
    );
  }
}
