//lib/domain/model/normal_values.dart

import 'package:freezed_annotation/freezed_annotation.dart';
part 'normal_values.freezed.dart';
part 'normal_values.g.dart';

double _parseDouble(dynamic value) =>
    value == null ? 0.0 : value is String ? double.tryParse(value) ?? 0.0 : (value as num).toDouble();

int _parseInt(dynamic value) =>
    value == null ? 0 : value is String ? int.tryParse(value) ?? 0 : (value as num).toInt();

@freezed
class NormalValues with _$NormalValues {
  const factory NormalValues({
    @JsonKey(name: 'ValoarePulsMin', fromJson: _parseInt) required int pulsMin,
    @JsonKey(name: 'ValoarePulsMax', fromJson: _parseInt) required int pulsMax,
    @JsonKey(name: 'ValoareTemperaturaMin', fromJson: _parseDouble) required double temperaturaMin,
    @JsonKey(name: 'ValoareTemperaturaMax', fromJson: _parseDouble) required double temperaturaMax,
    @JsonKey(name: 'ValoareECGMin', fromJson: _parseDouble) required double ecgMin,
    @JsonKey(name: 'ValoareECGMax', fromJson: _parseDouble) required double ecgMax,
    @JsonKey(name: 'ValoareUmiditateMin', fromJson: _parseDouble) required double umiditateMin,
    @JsonKey(name: 'ValoareUmiditateMax', fromJson: _parseDouble) required double umiditateMax,
  }) = _NormalValues;

  factory NormalValues.fromJson(Map<String, dynamic> json) => _$NormalValuesFromJson(json);
}