// lib/presentation/state/sensor_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import '../../data/ble/ble_service.dart';
import '../../data/ble/sensor_repository_impl.dart';
import '../../domain/model/sensor_data.dart';
import '../../domain/repository/sensor_repository.dart';

/// Clientul BLE
final bleClientProvider = Provider<FlutterReactiveBle>((ref) {
  return FlutterReactiveBle();
});

/// Serviciul BLE
final bleServiceProvider = Provider<BleService>((ref) {
  return BleService(ref.read(bleClientProvider));
});

/// Repository-ul concret pentru senzori
final sensorRepoProvider = Provider<SensorRepository>((ref) {
  return SensorRepositoryImpl(ref.read(bleServiceProvider));
});

/// StreamProvider care emite SensorData
final sensorStreamProvider = StreamProvider<SensorData>((ref) {
  return ref.read(sensorRepoProvider).watchSensorData();
});