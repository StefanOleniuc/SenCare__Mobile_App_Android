// lib/domain/model/ble_event.dart

import 'package:freezed_annotation/freezed_annotation.dart';
part 'ble_event.freezed.dart';
part 'ble_event.g.dart';

@freezed
class BleEvent with _$BleEvent {
  /// Măsurătoare normală la ~10s: contain {bpm, temp, hum}
  const factory BleEvent.sensor({
    required int bpm,
    required double temp,
    required double hum,
  }) = SensorEvent;

  /// Flux EKG la ~50ms: contains {ekg}
  const factory BleEvent.ekg({
    required double ekg,
  }) = EkgEvent;

  factory BleEvent.fromJson(Map<String, dynamic> json) => _$BleEventFromJson(json);
}
