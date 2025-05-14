

import 'package:beatsync_app/core/errors/exceptions.dart';
import 'package:beatsync_app/core/services/http_client_service.dart'; 
import 'package:beatsync_app/features/authentication/data/models/login_response_dto.dart';
import 'package:beatsync_app/features/authentication/data/models/logout_request_dto.dart';
import 'package:beatsync_app/features/authentication/data/models/user_register_model.dart';
import 'package:dio/dio.dart'; 

abstract class AuthRemoteDataSource {
  Future<LoginResponseDTO> login({required String email, required String password});

  Future<void> register({required UserRegisterModel userRegisterModel});

  Future<void> logout({required LogoutRequestDTO logoutRequest});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final HttpClientService httpClientService;

  AuthRemoteDataSourceImpl({required this.httpClientService});

  @override
  Future<LoginResponseDTO> login(
      {required String email, required String password}) async {
    const endpoint = '/v1/auth/login';
    try {
      final response = await httpClientService.post(
        endpoint,
        data: {'email': email, 'password': password},
        headers: {'Content-Type': 'application/json'},
      );

      if (response.data != null && response.data is Map<String, dynamic>) {
        final responseBody = response.data as Map<String, dynamic>;

        if (responseBody.containsKey('data') &&
            responseBody['data'] is Map<String, dynamic>) {
          final responseData = responseBody['data'] as Map<String, dynamic>;
          return LoginResponseDTO.fromJson(responseData);
        } else {
          throw ServerException(
              'Invalid response structure: \'data\' field missing or not a Map',
              statusCode: response.statusCode);
        }
      } else {
        throw ServerException(
            'Invalid response structure: response.data is null or not a Map',
            statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw ServerException('Invalid credentials', statusCode: 401);
      }
      throw ServerException('Login failed: ${e.message ?? 'Unknown Dio error'}',
          statusCode: e.response?.statusCode);
    } catch (e) {
      if (e is! ServerException && e is! DioException) {

      }
      if (e is ServerException) rethrow;
      throw ServerException('An unexpected error occurred during login: ${e.toString()}');
    }
  }

  @override
  Future<void> register({required UserRegisterModel userRegisterModel}) async {
    const endpoint = '/v1/auth/register';
    await httpClientService.post(
      endpoint,
      data: userRegisterModel.toJson(),
    );
  }

  @override
  Future<void> logout({required LogoutRequestDTO logoutRequest}) async {
    const endpoint = '/v1/auth/logout';
    await httpClientService.post(
      endpoint,
      data: logoutRequest.toJson(),
    );
  }
}
