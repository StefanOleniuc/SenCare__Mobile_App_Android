// lib/data/cloud/cloud_repository_impl.dart

import '../../domain/model/auth_token.dart';
import '../../domain/model/login_request.dart';
import '../../domain/model/burst_data.dart';
import '../../domain/model/recommendation.dart';
import '../../domain/model/alarm_model.dart';
import '../../domain/repository/cloud_repository.dart';
import '../../domain/model/normal_values.dart';
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
  Future<void> sendBurstData(String userId, BurstData burst) async {
    // Convertim totul într-un JSON conform așteptărilor backend-ului:
    final payload = {
      'userId':      int.parse(userId),
      'Puls':       burst.bpmAvg,
      'Temperatura': burst.tempAvg,
      'Umiditate':   burst.humAvg,
      // ECG trebuie să fie String — serializăm lista de dubluri la JSON:
      'ECG':         burst.ecgString,
      // Data_timp trebuie să se cheme exact așa:
      'Data_timp':   burst.timestamp.toIso8601String(),
    };

    print('[CloudRepository] 🚀 Trimitem date fiziologice → userID=$userId, payload=$payload');

    try {
      await _api.sendPhysioDataMobile(payload);
      print('[CloudRepository] ✅ Server mobile a răspuns OK (2xx)');
    } catch (e) {
      print('[CloudRepository] ❌ Eroare la trimitere (mobile): $e');
      rethrow;
    }
  }
  //RECOMANDARI
  @override
  Future<List<Recommendation>> fetchRecommendations(String userId) {
    return _api.fetchRecommendationsMobile(userId);
  }

  @override
  Future<List<AlarmModel>> fetchAlarms(String patientId) {
    return _api.fetchAlarms(patientId);
  }

  @override
  Future<void> postAlarm(AlarmModel alarm) {
    return _api.postAlarm(alarm);
  }

  @override
  Future<NormalValues> fetchNormalValues(String userId) {
    return _api.fetchNormalValuesMobile(userId);
  }

  // trimite istoric alarmă
  @override
  Future<void> sendAlarmHistory({
    required String userId,
    required int alarmaId,
    required String tipAlarma,
    required String descriere,
    required String actiune,
  }) async {
    final payload = {
      "userId": int.parse(userId),
      "alarmaId": alarmaId,
      "tipAlarma": tipAlarma,
      "descriere": descriere,
      "actiune": actiune,
    };
    await _api.sendAlarmHistoryMobile(payload);
  }
}