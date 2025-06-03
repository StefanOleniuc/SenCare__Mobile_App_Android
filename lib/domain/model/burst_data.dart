// lib/domain/model/burst_data.dart

import 'package:freezed_annotation/freezed_annotation.dart';
part 'burst_data.freezed.dart';
part 'burst_data.g.dart';

@freezed
class BurstData with _$BurstData {
  factory BurstData({
    @JsonKey(name: 'Puls')       required int bpmAvg,
    @JsonKey(name: 'Temperatura') required double tempAvg,
    @JsonKey(name: 'Umiditate')  required double humAvg,
    @JsonKey(name: 'Data_timp')  required DateTime timestamp,
    @JsonKey(name: 'ECG')        required String ecgString,
  }) = _BurstData;

  factory BurstData.fromJson(Map<String, dynamic> json) =>
      _$BurstDataFromJson(json);
}