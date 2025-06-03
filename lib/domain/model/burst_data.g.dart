// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'burst_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BurstDataImpl _$$BurstDataImplFromJson(Map<String, dynamic> json) =>
    _$BurstDataImpl(
      bpmAvg: (json['Puls'] as num).toInt(),
      tempAvg: (json['Temperatura'] as num).toDouble(),
      humAvg: (json['Umiditate'] as num).toDouble(),
      timestamp: json['Data_timp'] == null
          ? null
          : DateTime.parse(json['Data_timp'] as String),
      ecgValues: (json['ECG'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
    );

Map<String, dynamic> _$$BurstDataImplToJson(_$BurstDataImpl instance) =>
    <String, dynamic>{
      'Puls': instance.bpmAvg,
      'Temperatura': instance.tempAvg,
      'Umiditate': instance.humAvg,
      'Data_timp': instance.timestamp?.toIso8601String(),
      'ECG': instance.ecgValues,
    };
