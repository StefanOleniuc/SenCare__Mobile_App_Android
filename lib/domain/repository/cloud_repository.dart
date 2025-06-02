// lib/domain/repository/cloud_repository.dart

import '../model/auth_token.dart';
import '../model/login_request.dart';
import '../model/patient.dart';
import '../model/recommendation.dart';
import '../model/alarm.dart';
import '../model/burst_data.dart';

abstract class CloudRepository {

  // 1) Trimite un BurstData la server
  Future<void> sendBurst(BurstData burst);

  // 2) Autentificare
  Future<AuthToken> login(LoginRequest credentials);

  // 3) RECOMANDĂRI
  Future<List<Recommendation>> fetchRecommendations(String patientId);
  Future<void> postRecommendation(Recommendation recommendation);

  // 4) ALARME
  Future<List<Alarm>> fetchAlarms(String patientId);
  Future<void> postAlarm(Alarm alarm);

/// (Opțional, dacă vei implementa alerte)
// Future<void> sendAlert(AlertData alert);
}