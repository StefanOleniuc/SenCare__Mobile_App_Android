// lib/data/cloud/cloud_repository_impl.dart

import 'package:dio/dio.dart';
import '../../domain/model/auth_token.dart';
import '../../domain/model/login_request.dart';
import '../../domain/model/patient.dart';
import '../../domain/model/sensor_data.dart';
import '../../domain/model/recommendation.dart';
import '../../domain/model/alarm.dart';
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
  Future<List<Patient>> fetchPatients() {
    return _api.fetchPatients();
  }

  @override
  Future<Patient> createPatient(Patient newPatient) {
    return _api.createPatient(newPatient);
  }

  @override
  Future<Patient> fetchPatient(String patientId) {
    return _api.fetchPatient(patientId);
  }

  @override
  Future<Patient> updatePatient(String patientId, Patient updatedPatient) {
    return _api.updatePatient(patientId, updatedPatient);
  }

  @override
  Future<void> deletePatient(String patientId) {
    return _api.deletePatient(patientId);
  }

  @override
  Future<void> sendSensorBatch(List<SensorData> batch) {
    return _api.sendSensorBatch(batch);
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
