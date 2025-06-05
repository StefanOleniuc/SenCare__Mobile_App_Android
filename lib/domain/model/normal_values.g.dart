// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'normal_values.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NormalValuesImpl _$$NormalValuesImplFromJson(Map<String, dynamic> json) =>
    _$NormalValuesImpl(
      pulsMin: _parseInt(json['ValoarePulsMin']),
      pulsMax: _parseInt(json['ValoarePulsMax']),
      temperaturaMin: _parseDouble(json['ValoareTemperaturaMin']),
      temperaturaMax: _parseDouble(json['ValoareTemperaturaMax']),
      ecgMin: _parseDouble(json['ValoareECGMin']),
      ecgMax: _parseDouble(json['ValoareECGMax']),
      umiditateMin: _parseDouble(json['ValoareUmiditateMin']),
      umiditateMax: _parseDouble(json['ValoareUmiditateMax']),
    );

Map<String, dynamic> _$$NormalValuesImplToJson(_$NormalValuesImpl instance) =>
    <String, dynamic>{
      'ValoarePulsMin': instance.pulsMin,
      'ValoarePulsMax': instance.pulsMax,
      'ValoareTemperaturaMin': instance.temperaturaMin,
      'ValoareTemperaturaMax': instance.temperaturaMax,
      'ValoareECGMin': instance.ecgMin,
      'ValoareECGMax': instance.ecgMax,
      'ValoareUmiditateMin': instance.umiditateMin,
      'ValoareUmiditateMax': instance.umiditateMax,
    };
