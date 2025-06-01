// lib/presentation/state/usecase_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/send_batch_usecase.dart';
import '../../domain/repository/cloud_repository.dart';
import '../../domain/repository/sensor_repository.dart';
import 'sensor_provider.dart';
import 'cloud_providers.dart';

/// Provider pentru SendBatchUseCase
final sendBatchUseCaseProvider = Provider<SendBatchUseCase>((ref) {
  final sensorRepo = ref.read(sensorRepoProvider);
  final cloudRepo  = ref.read(cloudRepositoryProvider);
  return SendBatchUseCase(sensorRepo, cloudRepo, patientId: 'test_patient',);
});
