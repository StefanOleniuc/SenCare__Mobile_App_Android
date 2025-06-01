// lib/presentation/state/auth_provider.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'auth_provider.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.authenticated({ required String userId }) = Authenticated;
  const factory AuthState.unauthenticated() = Unauthenticated;
}

/// StateProvider care ține starea de autentificare (inițial Unauthenticated)
final authStateProvider = StateProvider<AuthState>((ref) {
  return const AuthState.unauthenticated();
});
