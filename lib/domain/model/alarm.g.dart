// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alarm.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AlarmImpl _$$AlarmImplFromJson(Map<String, dynamic> json) => _$AlarmImpl(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: json['type'] as String,
      value: (json['value'] as num).toDouble(),
      note: json['note'] as String?,
    );

Map<String, dynamic> _$$AlarmImplToJson(_$AlarmImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'timestamp': instance.timestamp.toIso8601String(),
      'type': instance.type,
      'value': instance.value,
      'note': instance.note,
    };
