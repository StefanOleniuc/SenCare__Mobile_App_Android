import 'package:freezed_annotation/freezed_annotation.dart';

part 'recommendation.freezed.dart';
part 'recommendation.g.dart';

@freezed
class Recommendation with _$Recommendation {
  const factory Recommendation({
    required int RecomandareID,
    required int PacientID,
    required int MedicID,
    required String TipRecomandare,
    required String DurataZilnica,
    required String AlteIndicatii,
  }) = _Recommendation;

  factory Recommendation.fromJson(Map<String, dynamic> json) =>
      _$RecommendationFromJson(json);
}
