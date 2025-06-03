// lib/data/cloud/cloud_repository_impl.dart

import '../../domain/model/auth_token.dart';
import '../../domain/model/login_request.dart';
import '../../domain/model/burst_data.dart';
import '../../domain/model/recommendation.dart';
import '../../domain/model/alarm.dart';
import '../../domain/repository/cloud_repository.dart';
import 'api_service.dart';
import 'dart:convert';


class CloudRepositoryImpl implements CloudRepository {
  final ApiService _api;
  CloudRepositoryImpl(ApiService api) : _api = api;

  @override
  Future<AuthToken> login(LoginRequest credentials) {
    return _api.login(credentials);
  }

  @override
  Future<void> sendBurstData(String patientId, BurstData burst) async {
    // 1) Construim payload cu Puls/Temperatura/Umiditate
    // 2) Pentru EKG, convertim lista de double la JSON-string
    final String ecgJsonArray = jsonEncode(burst.ecgValues);

    final Map<String, dynamic> payload = {
      'Puls'       : burst.bpmAvg,
      'Temperatura': burst.tempAvg,
      'Umiditate'  : burst.humAvg,
      'ECG'        : ecgJsonArray,
      // NU trimitem Data_timp—backend‐ul va completa automat timestamp‐ul
    };

    print('[CloudRepository] 🚀 Trimitem date fiziologice → '
        'pacientID=$patientId, payload=$payload');

    try {
      await _api.sendPhysioData(patientId, payload);
      print('[CloudRepository] ✅ Trimis cu succes datele fiziologice.');
    } catch (e) {
      print('[CloudRepository] ❌ Eroare la trimiterea datelor fiziologice: $e');
      rethrow;
    }
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
}