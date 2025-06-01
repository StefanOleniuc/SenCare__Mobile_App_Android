// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sensor_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SensorDataImpl _$$SensorDataImplFromJson(Map<String, dynamic> json) =>
    _$SensorDataImpl(
      ekg: (json['ekg'] as num).toDouble(),
      hum: (json['hum'] as num).toDouble(),
      temp: (json['temp'] as num).toDouble(),
      bpm: (json['bpm'] as num).toInt(),
    );

Map<String, dynamic> _$$SensorDataImplToJson(_$SensorDataImpl instance) =>
    <String, dynamic>{
      'ekg': instance.ekg,
      'hum': instance.hum,
      'temp': instance.temp,
      'bpm': instance.bpm,
    };
