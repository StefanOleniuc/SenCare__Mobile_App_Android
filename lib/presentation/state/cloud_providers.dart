// lib/presentation/state/cloud_providers.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/cloud/api_service.dart';
import '../../data/cloud/cloud_repository_impl.dart';
import '../../domain/repository/cloud_repository.dart';
import '../../domain/model/auth_token.dart';

/// 1) Provider-ul pentru instanța Dio (HTTP client).
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://sencareapp-backend.azurewebsites.net',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),

    contentType: Headers.jsonContentType,
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  // 2) Interceptor pentru token-ul JWT
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      /*final token = ref.read(authTokenProvider)?.token;
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }*/
      return handler.next(options);
    },
    onError: (err, handler) {
      // Aici poți implementa logică de refresh token, dacă backend-ul
      // oferă un endpoint de genul /auth/refresh
      return handler.next(err);
    },
  ));

  return dio;
});

/// 3) Provider Retrofit ApiService
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(ref.read(dioProvider));
});

/// 4) Provider-ul concret pentru CloudRepository
final cloudRepositoryProvider = Provider<CloudRepository>((ref) {
  return CloudRepositoryImpl(ref.read(apiServiceProvider));
});

/// 5) AuthToken Provider (stochează în memorie AuthToken după login).
///    Când token-ul e null, utilizatorul nu e autentificat; atunci redirecționăm către LoginScreen.
final authTokenProvider = StateProvider<AuthToken?>((ref) => null);
