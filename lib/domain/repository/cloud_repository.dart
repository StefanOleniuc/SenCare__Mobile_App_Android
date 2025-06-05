// lib/domain/repository/cloud_repository.dart

import '../model/auth_token.dart';
import '../model/login_request.dart';
import '../model/burst_data.dart';
import '../model/recommendation.dart';
import '../model/alarm_model.dart';
import '../model/normal_values.dart';

abstract class CloudRepository {
  // 1) LOGIN
  Future<AuthToken> login(LoginRequest credentials);

  // 2) TRIMITERE BURSTDATA (date fiziologice agregate)
  Future<void> sendBurstData(String patientId, BurstData burst);

  // 3) RECOMANDĂRI
  Future<List<Recommendation>> fetchRecommendations(String userId);

  // 5) NORMAL VALUES
  Future<NormalValues> fetchNormalValues(String userId);

  // 6) TRIMITE ISTORIC ALARMĂ
  Future<void> sendAlarmHistory({
    required String userId,
    required int alarmaId,
    required String tipAlarma,
    required String descriere,
    required String actiune,
  });
}
