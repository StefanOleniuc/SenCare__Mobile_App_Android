// lib/presentation/state/alarm_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/model/alarm_model.dart';
import 'package:dio/dio.dart';

final alarmsProvider = FutureProvider.family<List<AlarmModel>, String>((ref, userId) async {
  final response = await Dio().get(
    'https://sencareapp-backend.azurewebsites.net/api/mobile/alarme',
    queryParameters: {'userId': userId},
  );
  return (response.data as List).map((e) => AlarmModel.fromJson(e)).toList();
});
