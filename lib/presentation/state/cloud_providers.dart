import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/cloud/api_service.dart';
import '../../data/cloud/cloud_repository_impl.dart';
import '../../domain/repository/cloud_repository.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://sencareapp-backend.azurewebsites.net',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    contentType: Headers.jsonContentType,
    headers: {'Content-Type': 'application/json'},
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      // Poți adăuga un interceptor de token, dacă ai nevoie
      return handler.next(options);
    },
    onError: (err, handler) {
      return handler.next(err);
    },
  ));

  return dio;
});

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(ref.read(dioProvider));
});

// În loc să injectăm doar `ApiService`, injectăm și `Dio` pentru debug
final cloudRepositoryProvider = Provider<CloudRepository>((ref) {
  final api = ref.read(apiServiceProvider);
  final dio = ref.read(dioProvider);
  return CloudRepositoryImpl(api, dio);
});
