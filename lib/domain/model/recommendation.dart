//path: lib/domain/model/recommendation.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'recommendation.freezed.dart';
part 'recommendation.g.dart';

@freezed
class Recommendation with _$Recommendation {
  const factory Recommendation({
    required int RecomandareID,
    required int PacientID,
    required String TipRecomandare,
    String? DurataZilnica,
    String? AlteIndicatii,
  }) = _Recommendation;

  factory Recommendation.fromJson(Map<String, dynamic> json) =>
      _$RecommendationFromJson(json);
}