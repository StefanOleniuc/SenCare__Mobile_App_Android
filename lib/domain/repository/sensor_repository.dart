// lib/domain/repository/sensor_repository.dart

import 'package:riverpod/riverpod.dart';
import '../model/ble_event.dart';

abstract class SensorRepository {
  Stream<BleEvent> watchBleEvents();
}
