// lib/data/cloud/api_service.dart

import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

import '../../domain/model/auth_token.dart';
import '../../domain/model/login_request.dart';
import '../../domain/model/burst_data.dart';
import '../../domain/model/recommendation.dart';
import '../../domain/model/alarm_model.dart';
import '../../domain/model/normal_values.dart';
part 'api_service.g.dart';

@RestApi(baseUrl: 'https://sencareapp-backend.azurewebsites.net')
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  // 1) LOGIN
  @POST('/api/login')
  Future<AuthToken> login(@Body() LoginRequest credentials);

  // ### NOUL ENDPOINT PENTRU MOBILE
  @POST('/api/mobile/datefiziologice')
  Future<void> sendPhysioDataMobile(@Body() Map<String, dynamic> payload);

  // 4) RECOMANDĂRI
  @GET('/api/mobile/recomandari')
  Future<List<Recommendation>> fetchRecommendationsMobile(
      @Query('userId') String userId,
      );

  @POST('/api/recommendations')
  Future<void> postRecommendation(@Body() Recommendation recommendation);

  // 5) ALARME
  @GET('/api/alarms/{patientId}')
  Future<List<AlarmModel>> fetchAlarms(@Path('patientId') String patientId);

  @POST('/api/mobile/istoric-alarme')
  Future<void> sendAlarmHistoryMobile(@Body() Map<String, dynamic> payload);

  @POST('/api/alarms')
  Future<void> postAlarm(@Body() AlarmModel alarm);

  // 6) NORMAL VALUES
  @GET('/api/mobile/valorinormale')
  Future<NormalValues> fetchNormalValuesMobile(@Query('userId') String userId);
}
