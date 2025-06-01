// lib/domain/model/sensor_data.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'sensor_data.freezed.dart';
part 'sensor_data.g.dart';

@freezed
class SensorData with _$SensorData {
  factory SensorData({
    required double ekg,
    required double hum,
    required double temp,
    required int bpm,
  }) = _SensorData;

  factory SensorData.fromJson(Map<String, dynamic> json) =>
      _$SensorDataFromJson(json);
}

