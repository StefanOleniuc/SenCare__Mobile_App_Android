// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'burst_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BurstData _$BurstDataFromJson(Map<String, dynamic> json) {
  return _BurstData.fromJson(json);
}

/// @nodoc
mixin _$BurstData {
  @JsonKey(name: 'Puls')
  int get bpmAvg => throw _privateConstructorUsedError;
  @JsonKey(name: 'Temperatura')
  double get tempAvg => throw _privateConstructorUsedError;
  @JsonKey(name: 'Umiditate')
  double get humAvg => throw _privateConstructorUsedError;
  @JsonKey(name: 'Data_timp')
  DateTime? get timestamp => throw _privateConstructorUsedError;
  @JsonKey(name: 'ECG')
  List<double> get ecgValues => throw _privateConstructorUsedError;

  /// Serializes this BurstData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BurstData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BurstDataCopyWith<BurstData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BurstDataCopyWith<$Res> {
  factory $BurstDataCopyWith(BurstData value, $Res Function(BurstData) then) =
      _$BurstDataCopyWithImpl<$Res, BurstData>;
  @useResult
  $Res call(
      {@JsonKey(name: 'Puls') int bpmAvg,
      @JsonKey(name: 'Temperatura') double tempAvg,
      @JsonKey(name: 'Umiditate') double humAvg,
      @JsonKey(name: 'Data_timp') DateTime? timestamp,
      @JsonKey(name: 'ECG') List<double> ecgValues});
}

/// @nodoc
class _$BurstDataCopyWithImpl<$Res, $Val extends BurstData>
    implements $BurstDataCopyWith<$Res> {
  _$BurstDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BurstData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bpmAvg = null,
    Object? tempAvg = null,
    Object? humAvg = null,
    Object? timestamp = freezed,
    Object? ecgValues = null,
  }) {
    return _then(_value.copyWith(
      bpmAvg: null == bpmAvg
          ? _value.bpmAvg
          : bpmAvg // ignore: cast_nullable_to_non_nullable
              as int,
      tempAvg: null == tempAvg
          ? _value.tempAvg
          : tempAvg // ignore: cast_nullable_to_non_nullable
              as double,
      humAvg: null == humAvg
          ? _value.humAvg
          : humAvg // ignore: cast_nullable_to_non_nullable
              as double,
      timestamp: freezed == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      ecgValues: null == ecgValues
          ? _value.ecgValues
          : ecgValues // ignore: cast_nullable_to_non_nullable
              as List<double>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BurstDataImplCopyWith<$Res>
    implements $BurstDataCopyWith<$Res> {
  factory _$$BurstDataImplCopyWith(
          _$BurstDataImpl value, $Res Function(_$BurstDataImpl) then) =
      __$$BurstDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'Puls') int bpmAvg,
      @JsonKey(name: 'Temperatura') double tempAvg,
      @JsonKey(name: 'Umiditate') double humAvg,
      @JsonKey(name: 'Data_timp') DateTime? timestamp,
      @JsonKey(name: 'ECG') List<double> ecgValues});
}

/// @nodoc
class __$$BurstDataImplCopyWithImpl<$Res>
    extends _$BurstDataCopyWithImpl<$Res, _$BurstDataImpl>
    implements _$$BurstDataImplCopyWith<$Res> {
  __$$BurstDataImplCopyWithImpl(
      _$BurstDataImpl _value, $Res Function(_$BurstDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of BurstData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bpmAvg = null,
    Object? tempAvg = null,
    Object? humAvg = null,
    Object? timestamp = freezed,
    Object? ecgValues = null,
  }) {
    return _then(_$BurstDataImpl(
      bpmAvg: null == bpmAvg
          ? _value.bpmAvg
          : bpmAvg // ignore: cast_nullable_to_non_nullable
              as int,
      tempAvg: null == tempAvg
          ? _value.tempAvg
          : tempAvg // ignore: cast_nullable_to_non_nullable
              as double,
      humAvg: null == humAvg
          ? _value.humAvg
          : humAvg // ignore: cast_nullable_to_non_nullable
              as double,
      timestamp: freezed == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      ecgValues: null == ecgValues
          ? _value._ecgValues
          : ecgValues // ignore: cast_nullable_to_non_nullable
              as List<double>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BurstDataImpl implements _BurstData {
  _$BurstDataImpl(
      {@JsonKey(name: 'Puls') required this.bpmAvg,
      @JsonKey(name: 'Temperatura') required this.tempAvg,
      @JsonKey(name: 'Umiditate') required this.humAvg,
      @JsonKey(name: 'Data_timp') this.timestamp,
      @JsonKey(name: 'ECG') required final List<double> ecgValues})
      : _ecgValues = ecgValues;

  factory _$BurstDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$BurstDataImplFromJson(json);

  @override
  @JsonKey(name: 'Puls')
  final int bpmAvg;
  @override
  @JsonKey(name: 'Temperatura')
  final double tempAvg;
  @override
  @JsonKey(name: 'Umiditate')
  final double humAvg;
  @override
  @JsonKey(name: 'Data_timp')
  final DateTime? timestamp;
  final List<double> _ecgValues;
  @override
  @JsonKey(name: 'ECG')
  List<double> get ecgValues {
    if (_ecgValues is EqualUnmodifiableListView) return _ecgValues;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_ecgValues);
  }

  @override
  String toString() {
    return 'BurstData(bpmAvg: $bpmAvg, tempAvg: $tempAvg, humAvg: $humAvg, timestamp: $timestamp, ecgValues: $ecgValues)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BurstDataImpl &&
            (identical(other.bpmAvg, bpmAvg) || other.bpmAvg == bpmAvg) &&
            (identical(other.tempAvg, tempAvg) || other.tempAvg == tempAvg) &&
            (identical(other.humAvg, humAvg) || other.humAvg == humAvg) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            const DeepCollectionEquality()
                .equals(other._ecgValues, _ecgValues));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, bpmAvg, tempAvg, humAvg,
      timestamp, const DeepCollectionEquality().hash(_ecgValues));

  /// Create a copy of BurstData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BurstDataImplCopyWith<_$BurstDataImpl> get copyWith =>
      __$$BurstDataImplCopyWithImpl<_$BurstDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BurstDataImplToJson(
      this,
    );
  }
}

abstract class _BurstData implements BurstData {
  factory _BurstData(
          {@JsonKey(name: 'Puls') required final int bpmAvg,
          @JsonKey(name: 'Temperatura') required final double tempAvg,
          @JsonKey(name: 'Umiditate') required final double humAvg,
          @JsonKey(name: 'Data_timp') final DateTime? timestamp,
          @JsonKey(name: 'ECG') required final List<double> ecgValues}) =
      _$BurstDataImpl;

  factory _BurstData.fromJson(Map<String, dynamic> json) =
      _$BurstDataImpl.fromJson;

  @override
  @JsonKey(name: 'Puls')
  int get bpmAvg;
  @override
  @JsonKey(name: 'Temperatura')
  double get tempAvg;
  @override
  @JsonKey(name: 'Umiditate')
  double get humAvg;
  @override
  @JsonKey(name: 'Data_timp')
  DateTime? get timestamp;
  @override
  @JsonKey(name: 'ECG')
  List<double> get ecgValues;

  /// Create a copy of BurstData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BurstDataImplCopyWith<_$BurstDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
