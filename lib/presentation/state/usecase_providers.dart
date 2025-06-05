// lib/presentation/state/usecase_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/send_batch_usecase.dart';
import '../../domain/repository/cloud_repository.dart';
import '../../domain/repository/sensor_repository.dart';
import '../../data/ble/sensor_repository_impl.dart';
import 'ble_providers.dart';
import 'cloud_providers.dart';
import 'auth_provider.dart';

/// 1) SensorRepository Provider: implementarea concretă, bazată pe BleService.
final sensorRepoProvider = Provider<SensorRepository>((ref) {
  return SensorRepositoryImpl(ref.read(bleServiceProvider));
});

/// 2) SendBatchUseCase Provider: îl construim cu `userId` luat din AuthState.
final sendBatchUseCaseProvider = Provider<SendBatchUseCase>((ref) {
  final sensorRepo = ref.read(sensorRepoProvider);
  final cloudRepo  = ref.read(cloudRepositoryProvider);

  // Obținem AuthState (Authenticated sau Unauthenticated).
  final authState = ref.watch(authStateProvider);
  final userId = authState.maybeWhen(
    authenticated: (id) => id.toString(),
    orElse: () => '',
  );

  print('[usecase_providers] Folosesc userId="$userId" la creația SendBatchUseCase');
  return SendBatchUseCase(
    sensorRepo,
    cloudRepo,
    userId: userId,  // transmitem direct aici
  );
});
