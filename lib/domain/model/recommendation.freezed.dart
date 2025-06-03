// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recommendation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Recommendation _$RecommendationFromJson(Map<String, dynamic> json) {
  return _Recommendation.fromJson(json);
}

/// @nodoc
mixin _$Recommendation {
  int get RecomandareID => throw _privateConstructorUsedError;
  int get PacientID => throw _privateConstructorUsedError;
  String get TipRecomandare => throw _privateConstructorUsedError;
  String? get DurataZilnica => throw _privateConstructorUsedError;
  String? get AlteIndicatii => throw _privateConstructorUsedError;

  /// Serializes this Recommendation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Recommendation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecommendationCopyWith<Recommendation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecommendationCopyWith<$Res> {
  factory $RecommendationCopyWith(
          Recommendation value, $Res Function(Recommendation) then) =
      _$RecommendationCopyWithImpl<$Res, Recommendation>;
  @useResult
  $Res call(
      {int RecomandareID,
      int PacientID,
      String TipRecomandare,
      String? DurataZilnica,
      String? AlteIndicatii});
}

/// @nodoc
class _$RecommendationCopyWithImpl<$Res, $Val extends Recommendation>
    implements $RecommendationCopyWith<$Res> {
  _$RecommendationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Recommendation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? RecomandareID = null,
    Object? PacientID = null,
    Object? TipRecomandare = null,
    Object? DurataZilnica = freezed,
    Object? AlteIndicatii = freezed,
  }) {
    return _then(_value.copyWith(
      RecomandareID: null == RecomandareID
          ? _value.RecomandareID
          : RecomandareID // ignore: cast_nullable_to_non_nullable
              as int,
      PacientID: null == PacientID
          ? _value.PacientID
          : PacientID // ignore: cast_nullable_to_non_nullable
              as int,
      TipRecomandare: null == TipRecomandare
          ? _value.TipRecomandare
          : TipRecomandare // ignore: cast_nullable_to_non_nullable
              as String,
      DurataZilnica: freezed == DurataZilnica
          ? _value.DurataZilnica
          : DurataZilnica // ignore: cast_nullable_to_non_nullable
              as String?,
      AlteIndicatii: freezed == AlteIndicatii
          ? _value.AlteIndicatii
          : AlteIndicatii // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RecommendationImplCopyWith<$Res>
    implements $RecommendationCopyWith<$Res> {
  factory _$$RecommendationImplCopyWith(_$RecommendationImpl value,
          $Res Function(_$RecommendationImpl) then) =
      __$$RecommendationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int RecomandareID,
      int PacientID,
      String TipRecomandare,
      String? DurataZilnica,
      String? AlteIndicatii});
}

/// @nodoc
class __$$RecommendationImplCopyWithImpl<$Res>
    extends _$RecommendationCopyWithImpl<$Res, _$RecommendationImpl>
    implements _$$RecommendationImplCopyWith<$Res> {
  __$$RecommendationImplCopyWithImpl(
      _$RecommendationImpl _value, $Res Function(_$RecommendationImpl) _then)
      : super(_value, _then);

  /// Create a copy of Recommendation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? RecomandareID = null,
    Object? PacientID = null,
    Object? TipRecomandare = null,
    Object? DurataZilnica = freezed,
    Object? AlteIndicatii = freezed,
  }) {
    return _then(_$RecommendationImpl(
      RecomandareID: null == RecomandareID
          ? _value.RecomandareID
          : RecomandareID // ignore: cast_nullable_to_non_nullable
              as int,
      PacientID: null == PacientID
          ? _value.PacientID
          : PacientID // ignore: cast_nullable_to_non_nullable
              as int,
      TipRecomandare: null == TipRecomandare
          ? _value.TipRecomandare
          : TipRecomandare // ignore: cast_nullable_to_non_nullable
              as String,
      DurataZilnica: freezed == DurataZilnica
          ? _value.DurataZilnica
          : DurataZilnica // ignore: cast_nullable_to_non_nullable
              as String?,
      AlteIndicatii: freezed == AlteIndicatii
          ? _value.AlteIndicatii
          : AlteIndicatii // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RecommendationImpl implements _Recommendation {
  const _$RecommendationImpl(
      {required this.RecomandareID,
      required this.PacientID,
      required this.TipRecomandare,
      this.DurataZilnica,
      this.AlteIndicatii});

  factory _$RecommendationImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecommendationImplFromJson(json);

  @override
  final int RecomandareID;
  @override
  final int PacientID;
  @override
  final String TipRecomandare;
  @override
  final String? DurataZilnica;
  @override
  final String? AlteIndicatii;

  @override
  String toString() {
    return 'Recommendation(RecomandareID: $RecomandareID, PacientID: $PacientID, TipRecomandare: $TipRecomandare, DurataZilnica: $DurataZilnica, AlteIndicatii: $AlteIndicatii)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecommendationImpl &&
            (identical(other.RecomandareID, RecomandareID) ||
                other.RecomandareID == RecomandareID) &&
            (identical(other.PacientID, PacientID) ||
                other.PacientID == PacientID) &&
            (identical(other.TipRecomandare, TipRecomandare) ||
                other.TipRecomandare == TipRecomandare) &&
            (identical(other.DurataZilnica, DurataZilnica) ||
                other.DurataZilnica == DurataZilnica) &&
            (identical(other.AlteIndicatii, AlteIndicatii) ||
                other.AlteIndicatii == AlteIndicatii));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, RecomandareID, PacientID,
      TipRecomandare, DurataZilnica, AlteIndicatii);

  /// Create a copy of Recommendation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecommendationImplCopyWith<_$RecommendationImpl> get copyWith =>
      __$$RecommendationImplCopyWithImpl<_$RecommendationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecommendationImplToJson(
      this,
    );
  }
}

abstract class _Recommendation implements Recommendation {
  const factory _Recommendation(
      {required final int RecomandareID,
      required final int PacientID,
      required final String TipRecomandare,
      final String? DurataZilnica,
      final String? AlteIndicatii}) = _$RecommendationImpl;

  factory _Recommendation.fromJson(Map<String, dynamic> json) =
      _$RecommendationImpl.fromJson;

  @override
  int get RecomandareID;
  @override
  int get PacientID;
  @override
  String get TipRecomandare;
  @override
  String? get DurataZilnica;
  @override
  String? get AlteIndicatii;

  /// Create a copy of Recommendation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecommendationImplCopyWith<_$RecommendationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
