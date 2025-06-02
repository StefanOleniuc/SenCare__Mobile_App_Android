// lib/data/cloud/api_service.dart

import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

import '../../domain/model/auth_token.dart';
import '../../domain/model/login_request.dart';
import '../../domain/model/patient.dart';
import '../../domain/model/burst_data.dart';
import '../../domain/model/recommendation.dart';
import '../../domain/model/alarm.dart';

part 'api_service.g.dart';

@RestApi(baseUrl: 'https://sencareapp-backend.azurewebsites.net')
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  // 1) LOGIN
  @POST('/api/login')
  Future<AuthToken> login(@Body() LoginRequest credentials);

  // 2) TRIMITERE BURST (sensor batch)
  @POST('/sensor/burst')
  Future<void> sendBurst(@Body() BurstData burst);

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
