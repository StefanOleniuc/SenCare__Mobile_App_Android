// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alarm_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AlarmModelImpl _$$AlarmModelImplFromJson(Map<String, dynamic> json) =>
    _$AlarmModelImpl(
      alarmaId: (json['AlarmaID'] as num).toInt(),
      pacientId: (json['PacientID'] as num).toInt(),
      tipAlarma: json['TipAlarma'] as String,
      descriere: json['Descriere'] as String,
    );

Map<String, dynamic> _$$AlarmModelImplToJson(_$AlarmModelImpl instance) =>
    <String, dynamic>{
      'AlarmaID': instance.alarmaId,
      'PacientID': instance.pacientId,
      'TipAlarma': instance.tipAlarma,
      'Descriere': instance.descriere,
    };
