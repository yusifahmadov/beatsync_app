import 'package:dio/dio.dart';

import '../auth/auth_token_provider.dart';

class AuthInterceptor extends Interceptor {
  final AuthTokenProvider _authTokenProvider;

  AuthInterceptor(this._authTokenProvider);

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _authTokenProvider.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['Accept'] = 'application/json';

    super.onRequest(options, handler);
  }
























}
