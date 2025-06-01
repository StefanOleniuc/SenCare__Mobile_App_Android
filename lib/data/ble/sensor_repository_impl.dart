// lib/data/ble/sensor_repository_impl.dart

import 'dart:convert';                // pentru utf8.decode și jsonDecode
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import '../../domain/model/sensor_data.dart';
import '../../domain/repository/sensor_repository.dart';
import 'ble_service.dart';

class SensorRepositoryImpl implements SensorRepository {
  final BleService _bleService;

  SensorRepositoryImpl(this._bleService);

  // UUID-urile ESP32
  static final _serviceUuid = Uuid.parse('6e400001-b5a3-f393-e0a9-e50e24dcca9e');
  static final _charUuid    = Uuid.parse('6e400003-b5a3-f393-e0a9-e50e24dcca9e');

  @override
  Stream<SensorData> watchSensorData() {
    return _bleService
        .watchCharacteristic(
      serviceUuid: _serviceUuid,
      characteristicUuid: _charUuid,
    )
        .map((bytes) {
      // 1. Transformăm lista de octeți în String
      final jsonString = utf8.decode(bytes);
      print('[SensorRepository] Received JSON string: $jsonString');

      // 2. Decodăm JSON-ul într-un Map
      final Map<String, dynamic> map = jsonDecode(jsonString);

      // 3. Construim obiectul SensorData cu factory .fromJson
      final sensorData = SensorData.fromJson(map);
      print('[SensorRepository] Parsed SensorData: $sensorData');

      return sensorData;
    });
  }
}
