// lib/presentation/state/auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/model/auth_token.dart';
import '../../domain/model/login_request.dart';
import '../../domain/repository/cloud_repository.dart';
import 'cloud_providers.dart';

part 'auth_provider.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = AuthStateInitial;
  const factory AuthState.authenticated({
    required String userId,
    required String userType, // "doctor" sau "pacient"
  }) = AuthStateAuthenticated;
  const factory AuthState.unauthenticated() = AuthStateUnauthenticated;
  const factory AuthState.error(String message) = AuthStateError;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final CloudRepository _cloudRepo;
  AuthNotifier(this._cloudRepo) : super(const AuthState.initial());

  Future<void> login(String email, String password) async {
    try {
      final credentials = LoginRequest(email: email, password: password);
      final authToken = await _cloudRepo.login(credentials);
      final userIdString = authToken.userId.toString();
      state = AuthState.authenticated(
        userId: userIdString,
        userType: authToken.userType,
      );
    } catch (e) {
      state = AuthState.error('Login eșuat: ${e.toString()}');
    }
  }

  void logout() {
    state = const AuthState.unauthenticated();
  }
}

// Provider pentru CloudRepository
final authRepositoryProvider = Provider<CloudRepository>((ref) {
  return ref.read(cloudRepositoryProvider);
});

// Provider pentru AuthNotifier
final authNotifierProvider =
StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});

// Provider doar pentru AuthState (simplifică citirea stării)
final authStateProvider = Provider<AuthState>((ref) {
  return ref.watch(authNotifierProvider);
});
