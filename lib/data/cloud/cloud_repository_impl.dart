// lib/data/cloud/cloud_repository_impl.dart

import 'package:dio/dio.dart';
import '../../domain/model/auth_token.dart';
import '../../domain/model/login_request.dart';
import '../../domain/model/patient.dart';
import '../../domain/model/recommendation.dart';
import '../../domain/model/alarm.dart';
import '../../domain/model/burst_data.dart';       // ← import pentru BurstData
import '../../domain/repository/cloud_repository.dart';
import 'api_service.dart';

class CloudRepositoryImpl implements CloudRepository {
  final ApiService _api;

  CloudRepositoryImpl(ApiService api) : _api = api;

  @override
  Future<AuthToken> login(LoginRequest credentials) {
    return _api.login(credentials);
  }

  @override
  Future<List<Recommendation>> fetchRecommendations(String patientId) {
    return _api.fetchRecommendations(patientId);
  }

  @override
  Future<void> postRecommendation(Recommendation recommendation) {
    return _api.postRecommendation(recommendation);
  }

  @override
  Future<List<Alarm>> fetchAlarms(String patientId) {
    return _api.fetchAlarms(patientId);
  }

  @override
  Future<void> postAlarm(Alarm alarm) {
    return _api.postAlarm(alarm);
  }

  /// 6) Metoda pentru trimiterea unui BurstData la backend
  ///    (acesta este fix endpoint-ul "/sensor/burst" definit în ApiService).
  @override
  Future<void> sendBurst(BurstData burst) {
    return _api.sendBurst(burst);
  }
}
