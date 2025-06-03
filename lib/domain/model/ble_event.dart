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

  /// (Nu ne vom mai folosi de BurstEvent, pentru că acum facem noi agregarea)
  // const factory BleEvent.burst({ required int bpmAvg, required double tempAvg, required double humAvg, }) = BurstEvent;

  /// Alerta asincronă (se va face în pasul 2, dacă vei face alerte)
  /*const factory BleEvent.alert({
    required bool alert,
    required Map<String, bool> alertSources,
  }) = AlertEvent;*/

  factory BleEvent.fromJson(Map<String, dynamic> json) => _$BleEventFromJson(json);
}
