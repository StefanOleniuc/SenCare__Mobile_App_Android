// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'alarm_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AlarmModel _$AlarmModelFromJson(Map<String, dynamic> json) {
  return _AlarmModel.fromJson(json);
}

/// @nodoc
mixin _$AlarmModel {
  @JsonKey(name: 'AlarmaID')
  int get alarmaId => throw _privateConstructorUsedError;
  @JsonKey(name: 'PacientID')
  int get pacientId => throw _privateConstructorUsedError;
  @JsonKey(name: 'TipAlarma')
  String get tipAlarma => throw _privateConstructorUsedError;
  @JsonKey(name: 'Descriere')
  String get descriere => throw _privateConstructorUsedError;

  /// Serializes this AlarmModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AlarmModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AlarmModelCopyWith<AlarmModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AlarmModelCopyWith<$Res> {
  factory $AlarmModelCopyWith(
          AlarmModel value, $Res Function(AlarmModel) then) =
      _$AlarmModelCopyWithImpl<$Res, AlarmModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'AlarmaID') int alarmaId,
      @JsonKey(name: 'PacientID') int pacientId,
      @JsonKey(name: 'TipAlarma') String tipAlarma,
      @JsonKey(name: 'Descriere') String descriere});
}

/// @nodoc
class _$AlarmModelCopyWithImpl<$Res, $Val extends AlarmModel>
    implements $AlarmModelCopyWith<$Res> {
  _$AlarmModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AlarmModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? alarmaId = null,
    Object? pacientId = null,
    Object? tipAlarma = null,
    Object? descriere = null,
  }) {
    return _then(_value.copyWith(
      alarmaId: null == alarmaId
          ? _value.alarmaId
          : alarmaId // ignore: cast_nullable_to_non_nullable
              as int,
      pacientId: null == pacientId
          ? _value.pacientId
          : pacientId // ignore: cast_nullable_to_non_nullable
              as int,
      tipAlarma: null == tipAlarma
          ? _value.tipAlarma
          : tipAlarma // ignore: cast_nullable_to_non_nullable
              as String,
      descriere: null == descriere
          ? _value.descriere
          : descriere // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AlarmModelImplCopyWith<$Res>
    implements $AlarmModelCopyWith<$Res> {
  factory _$$AlarmModelImplCopyWith(
          _$AlarmModelImpl value, $Res Function(_$AlarmModelImpl) then) =
      __$$AlarmModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'AlarmaID') int alarmaId,
      @JsonKey(name: 'PacientID') int pacientId,
      @JsonKey(name: 'TipAlarma') String tipAlarma,
      @JsonKey(name: 'Descriere') String descriere});
}

/// @nodoc
class __$$AlarmModelImplCopyWithImpl<$Res>
    extends _$AlarmModelCopyWithImpl<$Res, _$AlarmModelImpl>
    implements _$$AlarmModelImplCopyWith<$Res> {
  __$$AlarmModelImplCopyWithImpl(
      _$AlarmModelImpl _value, $Res Function(_$AlarmModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of AlarmModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? alarmaId = null,
    Object? pacientId = null,
    Object? tipAlarma = null,
    Object? descriere = null,
  }) {
    return _then(_$AlarmModelImpl(
      alarmaId: null == alarmaId
          ? _value.alarmaId
          : alarmaId // ignore: cast_nullable_to_non_nullable
              as int,
      pacientId: null == pacientId
          ? _value.pacientId
          : pacientId // ignore: cast_nullable_to_non_nullable
              as int,
      tipAlarma: null == tipAlarma
          ? _value.tipAlarma
          : tipAlarma // ignore: cast_nullable_to_non_nullable
              as String,
      descriere: null == descriere
          ? _value.descriere
          : descriere // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AlarmModelImpl implements _AlarmModel {
  const _$AlarmModelImpl(
      {@JsonKey(name: 'AlarmaID') required this.alarmaId,
      @JsonKey(name: 'PacientID') required this.pacientId,
      @JsonKey(name: 'TipAlarma') required this.tipAlarma,
      @JsonKey(name: 'Descriere') required this.descriere});

  factory _$AlarmModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AlarmModelImplFromJson(json);

  @override
  @JsonKey(name: 'AlarmaID')
  final int alarmaId;
  @override
  @JsonKey(name: 'PacientID')
  final int pacientId;
  @override
  @JsonKey(name: 'TipAlarma')
  final String tipAlarma;
  @override
  @JsonKey(name: 'Descriere')
  final String descriere;

  @override
  String toString() {
    return 'AlarmModel(alarmaId: $alarmaId, pacientId: $pacientId, tipAlarma: $tipAlarma, descriere: $descriere)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AlarmModelImpl &&
            (identical(other.alarmaId, alarmaId) ||
                other.alarmaId == alarmaId) &&
            (identical(other.pacientId, pacientId) ||
                other.pacientId == pacientId) &&
            (identical(other.tipAlarma, tipAlarma) ||
                other.tipAlarma == tipAlarma) &&
            (identical(other.descriere, descriere) ||
                other.descriere == descriere));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, alarmaId, pacientId, tipAlarma, descriere);

  /// Create a copy of AlarmModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AlarmModelImplCopyWith<_$AlarmModelImpl> get copyWith =>
      __$$AlarmModelImplCopyWithImpl<_$AlarmModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AlarmModelImplToJson(
      this,
    );
  }
}

abstract class _AlarmModel implements AlarmModel {
  const factory _AlarmModel(
          {@JsonKey(name: 'AlarmaID') required final int alarmaId,
          @JsonKey(name: 'PacientID') required final int pacientId,
          @JsonKey(name: 'TipAlarma') required final String tipAlarma,
          @JsonKey(name: 'Descriere') required final String descriere}) =
      _$AlarmModelImpl;

  factory _AlarmModel.fromJson(Map<String, dynamic> json) =
      _$AlarmModelImpl.fromJson;

  @override
  @JsonKey(name: 'AlarmaID')
  int get alarmaId;
  @override
  @JsonKey(name: 'PacientID')
  int get pacientId;
  @override
  @JsonKey(name: 'TipAlarma')
  String get tipAlarma;
  @override
  @JsonKey(name: 'Descriere')
  String get descriere;

  /// Create a copy of AlarmModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AlarmModelImplCopyWith<_$AlarmModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
