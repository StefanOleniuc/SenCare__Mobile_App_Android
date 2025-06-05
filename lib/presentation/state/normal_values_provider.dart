// lib/presentation/state/normal_values_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/model/normal_values.dart';
import 'package:dio/dio.dart';

final normalValuesProvider = FutureProvider.family<NormalValues, String>((ref, userId) async {
  final response = await Dio().get(
    'https://sencareapp-backend.azurewebsites.net/api/mobile/valorinormale',
    queryParameters: {'userId': userId},
  );
  return NormalValues.fromJson(response.data);
});