// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ble_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BleEvent _$BleEventFromJson(Map<String, dynamic> json) {
  switch (json['runtimeType']) {
    case 'sensor':
      return SensorEvent.fromJson(json);
    case 'ekg':
      return EkgEvent.fromJson(json);

    default:
      throw CheckedFromJsonException(json, 'runtimeType', 'BleEvent',
          'Invalid union type "${json['runtimeType']}"!');
  }
}

/// @nodoc
mixin _$BleEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int bpm, double temp, double hum) sensor,
    required TResult Function(double ekg) ekg,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int bpm, double temp, double hum)? sensor,
    TResult? Function(double ekg)? ekg,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int bpm, double temp, double hum)? sensor,
    TResult Function(double ekg)? ekg,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SensorEvent value) sensor,
    required TResult Function(EkgEvent value) ekg,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SensorEvent value)? sensor,
    TResult? Function(EkgEvent value)? ekg,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SensorEvent value)? sensor,
    TResult Function(EkgEvent value)? ekg,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Serializes this BleEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BleEventCopyWith<$Res> {
  factory $BleEventCopyWith(BleEvent value, $Res Function(BleEvent) then) =
      _$BleEventCopyWithImpl<$Res, BleEvent>;
}

/// @nodoc
class _$BleEventCopyWithImpl<$Res, $Val extends BleEvent>
    implements $BleEventCopyWith<$Res> {
  _$BleEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BleEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$SensorEventImplCopyWith<$Res> {
  factory _$$SensorEventImplCopyWith(
          _$SensorEventImpl value, $Res Function(_$SensorEventImpl) then) =
      __$$SensorEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int bpm, double temp, double hum});
}

/// @nodoc
class __$$SensorEventImplCopyWithImpl<$Res>
    extends _$BleEventCopyWithImpl<$Res, _$SensorEventImpl>
    implements _$$SensorEventImplCopyWith<$Res> {
  __$$SensorEventImplCopyWithImpl(
      _$SensorEventImpl _value, $Res Function(_$SensorEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of BleEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bpm = null,
    Object? temp = null,
    Object? hum = null,
  }) {
    return _then(_$SensorEventImpl(
      bpm: null == bpm
          ? _value.bpm
          : bpm // ignore: cast_nullable_to_non_nullable
              as int,
      temp: null == temp
          ? _value.temp
          : temp // ignore: cast_nullable_to_non_nullable
              as double,
      hum: null == hum
          ? _value.hum
          : hum // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SensorEventImpl implements SensorEvent {
  const _$SensorEventImpl(
      {required this.bpm,
      required this.temp,
      required this.hum,
      final String? $type})
      : $type = $type ?? 'sensor';

  factory _$SensorEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$SensorEventImplFromJson(json);

  @override
  final int bpm;
  @override
  final double temp;
  @override
  final double hum;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'BleEvent.sensor(bpm: $bpm, temp: $temp, hum: $hum)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SensorEventImpl &&
            (identical(other.bpm, bpm) || other.bpm == bpm) &&
            (identical(other.temp, temp) || other.temp == temp) &&
            (identical(other.hum, hum) || other.hum == hum));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, bpm, temp, hum);

  /// Create a copy of BleEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SensorEventImplCopyWith<_$SensorEventImpl> get copyWith =>
      __$$SensorEventImplCopyWithImpl<_$SensorEventImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int bpm, double temp, double hum) sensor,
    required TResult Function(double ekg) ekg,
  }) {
    return sensor(bpm, temp, hum);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int bpm, double temp, double hum)? sensor,
    TResult? Function(double ekg)? ekg,
  }) {
    return sensor?.call(bpm, temp, hum);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int bpm, double temp, double hum)? sensor,
    TResult Function(double ekg)? ekg,
    required TResult orElse(),
  }) {
    if (sensor != null) {
      return sensor(bpm, temp, hum);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SensorEvent value) sensor,
    required TResult Function(EkgEvent value) ekg,
  }) {
    return sensor(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SensorEvent value)? sensor,
    TResult? Function(EkgEvent value)? ekg,
  }) {
    return sensor?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SensorEvent value)? sensor,
    TResult Function(EkgEvent value)? ekg,
    required TResult orElse(),
  }) {
    if (sensor != null) {
      return sensor(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$SensorEventImplToJson(
      this,
    );
  }
}

abstract class SensorEvent implements BleEvent {
  const factory SensorEvent(
      {required final int bpm,
      required final double temp,
      required final double hum}) = _$SensorEventImpl;

  factory SensorEvent.fromJson(Map<String, dynamic> json) =
      _$SensorEventImpl.fromJson;

  int get bpm;
  double get temp;
  double get hum;

  /// Create a copy of BleEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SensorEventImplCopyWith<_$SensorEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$EkgEventImplCopyWith<$Res> {
  factory _$$EkgEventImplCopyWith(
          _$EkgEventImpl value, $Res Function(_$EkgEventImpl) then) =
      __$$EkgEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({double ekg});
}

/// @nodoc
class __$$EkgEventImplCopyWithImpl<$Res>
    extends _$BleEventCopyWithImpl<$Res, _$EkgEventImpl>
    implements _$$EkgEventImplCopyWith<$Res> {
  __$$EkgEventImplCopyWithImpl(
      _$EkgEventImpl _value, $Res Function(_$EkgEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of BleEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ekg = null,
  }) {
    return _then(_$EkgEventImpl(
      ekg: null == ekg
          ? _value.ekg
          : ekg // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EkgEventImpl implements EkgEvent {
  const _$EkgEventImpl({required this.ekg, final String? $type})
      : $type = $type ?? 'ekg';

  factory _$EkgEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$EkgEventImplFromJson(json);

  @override
  final double ekg;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'BleEvent.ekg(ekg: $ekg)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EkgEventImpl &&
            (identical(other.ekg, ekg) || other.ekg == ekg));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, ekg);

  /// Create a copy of BleEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EkgEventImplCopyWith<_$EkgEventImpl> get copyWith =>
      __$$EkgEventImplCopyWithImpl<_$EkgEventImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int bpm, double temp, double hum) sensor,
    required TResult Function(double ekg) ekg,
  }) {
    return ekg(this.ekg);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int bpm, double temp, double hum)? sensor,
    TResult? Function(double ekg)? ekg,
  }) {
    return ekg?.call(this.ekg);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int bpm, double temp, double hum)? sensor,
    TResult Function(double ekg)? ekg,
    required TResult orElse(),
  }) {
    if (ekg != null) {
      return ekg(this.ekg);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SensorEvent value) sensor,
    required TResult Function(EkgEvent value) ekg,
  }) {
    return ekg(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SensorEvent value)? sensor,
    TResult? Function(EkgEvent value)? ekg,
  }) {
    return ekg?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SensorEvent value)? sensor,
    TResult Function(EkgEvent value)? ekg,
    required TResult orElse(),
  }) {
    if (ekg != null) {
      return ekg(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$EkgEventImplToJson(
      this,
    );
  }
}

abstract class EkgEvent implements BleEvent {
  const factory EkgEvent({required final double ekg}) = _$EkgEventImpl;

  factory EkgEvent.fromJson(Map<String, dynamic> json) =
      _$EkgEventImpl.fromJson;

  double get ekg;

  /// Create a copy of BleEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EkgEventImplCopyWith<_$EkgEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
