// lib/domain/repository/sensor_repository.dart

import '../model/sensor_data.dart';

/// Un flux de date de la senzorul hardware.
abstract class SensorRepository {
  /// Returnează un stream care emite câte un [SensorData] pe măsură ce
  /// sunt citite de la modulul BLE.
  Stream<SensorData> watchSensorData();
}
