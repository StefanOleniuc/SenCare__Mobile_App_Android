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
import 'package:dio/dio.dart';

class CloudRepositoryImpl implements CloudRepository {
  final ApiService _api;
  final Dio _dio; // vom folosi un Dio direct pentru debug

  CloudRepositoryImpl(ApiService api, Dio dio)
      : _api = api,
        _dio = dio;

  @override
  Future<AuthToken> login(LoginRequest credentials) {
    return _api.login(credentials);
  }

  @override
  Future<void> sendBurstData(String userId, BurstData burst) async {
    final Map<String, dynamic> payload = {
      'userId':       int.parse(userId),
      'Puls':         burst.bpmAvg,
      'Temperatura':  burst.tempAvg,
      'Umiditate':    burst.humAvg,
      'ECG':          burst.ecgString,
      'Data_timp':    burst.timestamp.toIso8601String(),
    };

    // 1) Printăm payload-ul complet
    print('🔴 [CloudRepositoryImpl] sendBurstData → payload: ${jsonEncode(payload)}');

    try {
      // 2) Folosim _dio.post direct, ca să putem vedea răspunsul detaliat
      final response = await _dio.post(
        '/api/mobile/datefiziologice',
        data: payload,
        options: Options(
          headers: {'Content-Type': 'application/json'},
          // Timeout de 15 secunde: dacă serverul nu răspunde, aruncă excepție
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      // 3) Printăm status-ul și corpul răspunsului
      print('✅ [CloudRepositoryImpl] sendBurstData HTTP status: ${response.statusCode}');
      print('✅ [CloudRepositoryImpl] sendBurstData HTTP body: ${response.data}');
    } on DioError catch (dioError) {
      // 4) Dacă a fost eroare, printăm tipul de eroare și cat mai multe detalii
      print('🔴 [CloudRepositoryImpl] 🚫 DioError la sendBurstData:');
      if (dioError.type == DioErrorType.connectionTimeout) {
        print('   • Timeout pe conexiune.');
      } else if (dioError.type == DioErrorType.receiveTimeout) {
        print('   • Timeout la primirea răspunsului.');
      } else if (dioError.type == DioErrorType.sendTimeout) {
        print('   • Timeout la trimiterea cererii.');
      } else if (dioError.type == DioErrorType.badResponse) {
        final status = dioError.response?.statusCode;
        final body   = dioError.response?.data;
        print('   • Bad response → status=$status, body=$body');
      } else if (dioError.type == DioErrorType.badCertificate) {
        print('   • Certificat SSL invalid.');
      } else if (dioError.type == DioErrorType.cancel) {
        print('   • Cererea a fost anulată de client.');
      } else if (dioError.type == DioErrorType.unknown) {
        print('   • Eroare necunoscută: ${dioError.message}');
      }
      // Afișăm detaliu complet, dacă există response
      if (dioError.response != null) {
        print('   • DioError response data: ${dioError.response?.data}');
      }
      rethrow;
    } catch (e) {
      // 5) Orice alt tip de excepție
      print('🔴 [CloudRepositoryImpl] ❌ Eroare neașteptată la sendBurstData: $e');
      rethrow;
    }
  }

  @override
  Future<List<Recommendation>> fetchRecommendations(String userId) {
    return _api.fetchRecommendationsMobile(userId);
  }

  @override
  Future<NormalValues> fetchNormalValues(String userId) {
    print('🟢 [CloudRepositoryImpl] fetchNormalValues for user: $userId');
    return _api.fetchNormalValuesMobile(userId);
  }

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
    print('🟠 [CloudRepositoryImpl] sendAlarmHistory payload: ${jsonEncode(payload)}');

    try {
      final response = await _dio.post(
        '/api/mobile/istoric-alarme',
        data: payload,
        options: Options(
          headers: {'Content-Type': 'application/json'},
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );
      print('✅ [CloudRepositoryImpl] sendAlarmHistory HTTP status: ${response.statusCode}');
      print('✅ [CloudRepositoryImpl] sendAlarmHistory HTTP body: ${response.data}');
    } on DioError catch (dioError) {
      print('🔴 [CloudRepositoryImpl] 🚫 DioError la sendAlarmHistory: ${dioError.message}');
      if (dioError.response != null) {
        print('   • status=${dioError.response?.statusCode}, body=${dioError.response?.data}');
      }
      rethrow;
    } catch (e) {
      print('🔴 [CloudRepositoryImpl] ❌ Eroare neașteptată la sendAlarmHistory: $e');
      rethrow;
    }
  }
}
