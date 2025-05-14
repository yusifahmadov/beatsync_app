import 'dart:io'; 

import 'package:dio/dio.dart';

import '../errors/network_exceptions.dart';

class ErrorHandlingInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _determineException(err);

    NetworkException customException;
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        customException = TimeoutException(stackTrace: err.stackTrace, error: err);
        break;
      case DioExceptionType.badResponse:
        switch (err.response?.statusCode) {
          case 400:
            customException = BadRequestException(
                errors: err.response?.data, stackTrace: err.stackTrace, error: err);
            break;
          case 401:
            customException =
                UnauthorizedException(stackTrace: err.stackTrace, error: err);
            break;
          case 403:
            customException = ForbiddenException(stackTrace: err.stackTrace, error: err);
            break;
          case 404:
            customException = NotFoundException(stackTrace: err.stackTrace, error: err);
            break;
          case 409:
            customException = ConflictException(stackTrace: err.stackTrace, error: err);
            break;
          case 500:
          case 502:
          case 503:
          case 504:
            customException = ServerException(
                message: err.response?.statusMessage,
                stackTrace: err.stackTrace,
                error: err);
            break;
          default:
            customException = UnexpectedException(
                message:
                    'Status: ${err.response?.statusCode} - ${err.response?.statusMessage}',
                stackTrace: err.stackTrace,
                error: err);
        }
        break;
      case DioExceptionType.cancel:
        customException = UnexpectedException(
            message: 'Request was cancelled.', stackTrace: err.stackTrace, error: err);
        break;
      case DioExceptionType.connectionError:
        customException = NoInternetException(stackTrace: err.stackTrace, error: err);
        break;
      case DioExceptionType.unknown:
        if (err.error is SocketException) {
          customException = NoInternetException(stackTrace: err.stackTrace, error: err);
        } else if (err.error is FormatException) {
          customException = DataParsingException(
              message: 'Error parsing JSON response',
              stackTrace: err.stackTrace,
              error: err);
        } else {
          customException = UnexpectedException(stackTrace: err.stackTrace, error: err);
        }
        break;
      default:
        customException = UnexpectedException(stackTrace: err.stackTrace, error: err);
    }

    return handler.reject(DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: customException,
    ));
  }

  NetworkException _determineException(DioException err) {
    if (err.error is NetworkException) return err.error as NetworkException;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(stackTrace: err.stackTrace, error: err);
      case DioExceptionType.badResponse:
        switch (err.response?.statusCode) {
          case 400:
            return BadRequestException(
                errors: err.response?.data, stackTrace: err.stackTrace, error: err);
          case 401:
            return UnauthorizedException(stackTrace: err.stackTrace, error: err);
          case 403:
            return ForbiddenException(stackTrace: err.stackTrace, error: err);
          case 404:
            return NotFoundException(stackTrace: err.stackTrace, error: err);
          case 409:
            return ConflictException(stackTrace: err.stackTrace, error: err);
          case 500:
          case 502:
          case 503:
          case 504:
            return ServerException(
                message: err.response?.statusMessage,
                stackTrace: err.stackTrace,
                error: err);
          default:
            return UnexpectedException(
                message:
                    'Status: ${err.response?.statusCode} - ${err.response?.statusMessage}',
                stackTrace: err.stackTrace,
                error: err);
        }
      case DioExceptionType.cancel:
        return UnexpectedException(
            message: 'Request was cancelled.',
            stackTrace: err.stackTrace,
            error: err); 
      case DioExceptionType.connectionError:
        return NoInternetException(stackTrace: err.stackTrace, error: err);
      case DioExceptionType.unknown:
        if (err.error is SocketException) {
          return NoInternetException(stackTrace: err.stackTrace, error: err);
        }
        if (err.error is FormatException) {
          return DataParsingException(
              message: 'Error parsing JSON response',
              stackTrace: err.stackTrace,
              error: err);
        }
        return UnexpectedException(stackTrace: err.stackTrace, error: err);
      default:
        return UnexpectedException(stackTrace: err.stackTrace, error: err);
    }
  }
}
