// lib/domain/model/auth_token.dart
import 'package:freezed_annotation/freezed_annotation.dart';
part 'auth_token.freezed.dart';
part 'auth_token.g.dart';

@freezed
class AuthToken with _$AuthToken {
  const factory AuthToken({
    required String message,
    required String userType,
    required int userId,
  }) = _AuthToken;

  factory AuthToken.fromJson(Map<String, dynamic> json) =>
      _$AuthTokenFromJson(json);
}
