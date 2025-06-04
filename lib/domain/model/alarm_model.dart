// lib/domain/model/alarm_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';
part 'alarm_model.freezed.dart';
part 'alarm_model.g.dart';

@freezed
class AlarmModel with _$AlarmModel {
  const factory AlarmModel({
    required int alarmaId,
    required int pacientId,
    required String tipAlarma,
    required String descriere,
  }) = _AlarmModel;

  factory AlarmModel.fromJson(Map<String, dynamic> json) => _$AlarmModelFromJson(json);
}