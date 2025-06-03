// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RecommendationImpl _$$RecommendationImplFromJson(Map<String, dynamic> json) =>
    _$RecommendationImpl(
      RecomandareID: (json['RecomandareID'] as num).toInt(),
      PacientID: (json['PacientID'] as num).toInt(),
      TipRecomandare: json['TipRecomandare'] as String,
      DurataZilnica: json['DurataZilnica'] as String?,
      AlteIndicatii: json['AlteIndicatii'] as String?,
    );

Map<String, dynamic> _$$RecommendationImplToJson(
        _$RecommendationImpl instance) =>
    <String, dynamic>{
      'RecomandareID': instance.RecomandareID,
      'PacientID': instance.PacientID,
      'TipRecomandare': instance.TipRecomandare,
      'DurataZilnica': instance.DurataZilnica,
      'AlteIndicatii': instance.AlteIndicatii,
    };
