//lib/data/ble/sensor_repository_impl.dart

import '../../domain/model/ble_event.dart';
import '../../domain/repository/sensor_repository.dart';
import 'ble_service.dart';

class SensorRepositoryImpl implements SensorRepository {
  final BleService _bleService;
  SensorRepositoryImpl(this._bleService);

  @override
  Stream<BleEvent> watchBleEvents() {
    // Aici pur și simplu returnăm fluxul direct
    return _bleService.bleEventStream;
  }
}