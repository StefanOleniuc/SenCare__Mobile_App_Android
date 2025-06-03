// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ble_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SensorEventImpl _$$SensorEventImplFromJson(Map<String, dynamic> json) =>
    _$SensorEventImpl(
      bpm: (json['bpm'] as num).toInt(),
      temp: (json['temp'] as num).toDouble(),
      hum: (json['hum'] as num).toDouble(),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$SensorEventImplToJson(_$SensorEventImpl instance) =>
    <String, dynamic>{
      'bpm': instance.bpm,
      'temp': instance.temp,
      'hum': instance.hum,
      'runtimeType': instance.$type,
    };

_$EkgEventImpl _$$EkgEventImplFromJson(Map<String, dynamic> json) =>
    _$EkgEventImpl(
      ekg: (json['ekg'] as num).toDouble(),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$EkgEventImplToJson(_$EkgEventImpl instance) =>
    <String, dynamic>{
      'ekg': instance.ekg,
      'runtimeType': instance.$type,
    };
