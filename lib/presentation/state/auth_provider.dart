import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'auth_provider.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.authenticated({ required int userId }) = Authenticated;
  const factory AuthState.unauthenticated() = Unauthenticated;
}

final authStateProvider = StateProvider<AuthState>((ref) {
  return const AuthState.unauthenticated();
});
