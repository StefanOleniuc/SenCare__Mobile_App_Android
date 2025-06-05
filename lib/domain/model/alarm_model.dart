import 'package:freezed_annotation/freezed_annotation.dart';
part 'alarm_model.freezed.dart';
part 'alarm_model.g.dart';

@freezed
class AlarmModel with _$AlarmModel {
  const factory AlarmModel({
    @JsonKey(name: 'AlarmaID') required int alarmaId,
    @JsonKey(name: 'PacientID') required int pacientId,
    @JsonKey(name: 'TipAlarma') required String tipAlarma,
    @JsonKey(name: 'Descriere') required String descriere,
  }) = _AlarmModel;

  factory AlarmModel.fromJson(Map<String, dynamic> json) => _$AlarmModelFromJson(json);
}