// lib/data/cloud/api_service.dart

import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

import '../../domain/model/auth_token.dart';
import '../../domain/model/login_request.dart';
import '../../domain/model/patient.dart';
import '../../domain/model/sensor_data.dart';
import '../../domain/model/recommendation.dart';
import '../../domain/model/alarm.dart';

part 'api_service.g.dart';

@RestApi(baseUrl: 'https://sencareapp-backend.azurewebsites.net')
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  // 1) LOGIN
  @POST('/api/login')
  Future<AuthToken> login(@Body() LoginRequest credentials);

  // 2) PACIENȚI
  @GET('/api/patients')
  Future<List<Patient>> fetchPatients();

  @POST('/api/patients')
  Future<Patient> createPatient(@Body() Patient newPatient);

  @GET('/api/patients/{id}')
  Future<Patient> fetchPatient(@Path('id') String patientId);

  @PUT('/api/patients/{id}')
  Future<Patient> updatePatient(
      @Path('id') String patientId,
      @Body() Patient updatedPatient,
      );

  @DELETE('/api/patients/{id}')
  Future<void> deletePatient(@Path('id') String patientId);

  // 3) SENZORI
  @POST('/api/sensor/batch')
  Future<void> sendSensorBatch(@Body() List<SensorData> batch);

  // 4) RECOMANDĂRI
  @GET('/api/recommendations/{patientId}')
  Future<List<Recommendation>> fetchRecommendations(
      @Path('patientId') String patientId,
      );

  @POST('/api/recommendations')
  Future<void> postRecommendation(@Body() Recommendation recommendation);

  // 5) ALARME
  @GET('/api/alarms/{patientId}')
  Future<List<Alarm>> fetchAlarms(@Path('patientId') String patientId);

  @POST('/api/alarms')
  Future<void> postAlarm(@Body() Alarm alarm);
}
