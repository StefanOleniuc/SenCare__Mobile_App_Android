// lib/domain/model/alarm.dart
import 'package:freezed_annotation/freezed_annotation.dart';
part 'alarm.freezed.dart';
part 'alarm.g.dart';

@freezed
class Alarm with _$Alarm {
  const factory Alarm({
    required String id,
    required String patientId,
    required DateTime timestamp,
    required String type,   // ex: "ecg_out_of_range"
    required double value,  // valoarea senzorului care a declanșat alarma
    String? note,           // text opțional introdus de utilizator
  }) = _Alarm;

  factory Alarm.fromJson(Map<String, dynamic> json) =>
      _$AlarmFromJson(json);
}
