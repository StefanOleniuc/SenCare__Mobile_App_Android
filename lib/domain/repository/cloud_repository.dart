// lib/domain/repository/cloud_repository.dart

import '../model/auth_token.dart';
import '../model/login_request.dart';
import '../model/burst_data.dart';
import '../model/recommendation.dart';
import '../model/alarm.dart';

abstract class CloudRepository {
  // 1) LOGIN
  Future<AuthToken> login(LoginRequest credentials);

  // 2) TRIMITERE BURSTDATA (date fiziologice agregate)
  Future<void> sendBurstData(String patientId, BurstData burst);

  // 3) RECOMANDĂRI
  Future<List<Recommendation>> fetchRecommendations(String userId);

  // 4) ALARME
  Future<List<Alarm>> fetchAlarms(String patientId);
  Future<void> postAlarm(Alarm alarm);
}
