// lib/domain/repository/cloud_repository.dart

import '../model/auth_token.dart';
import '../model/login_request.dart';
import '../model/patient.dart';
import '../model/sensor_data.dart';
import '../model/recommendation.dart';
import '../model/alarm.dart';

abstract class CloudRepository {
  // 1) LOGIN
  Future<AuthToken> login(LoginRequest credentials);

  // 2) PACIENȚI
  Future<List<Patient>> fetchPatients();
  Future<Patient> createPatient(Patient newPatient);
  Future<Patient> fetchPatient(String patientId);
  Future<Patient> updatePatient(String patientId, Patient updatedPatient);
  Future<void> deletePatient(String patientId);

  // 3) SENZORI (trimite batch)
  Future<void> sendSensorBatch(List<SensorData> batch);

  // 4) RECOMANDĂRI
  Future<List<Recommendation>> fetchRecommendations(String patientId);
  Future<void> postRecommendation(Recommendation recommendation);

  // 5) ALARME
  Future<List<Alarm>> fetchAlarms(String patientId);
  Future<void> postAlarm(Alarm alarm);
}

/// Model simplificat pentru ALERTĂ (poate avea titlu, text, timestamp, nivel)
class AlertModel {
  final String id;
  final String patientId;
  final String title;
  final DateTime timestamp;

  AlertModel({
    required this.id,
    required this.patientId,
    required this.title,
    required this.timestamp,
  });
}