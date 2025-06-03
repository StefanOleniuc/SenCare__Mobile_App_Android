// lib/presentation/state/recommendation_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/model/recommendation.dart';
import '../../domain/repository/cloud_repository.dart';
import 'cloud_providers.dart';

final recommendationProvider =
FutureProvider.autoDispose.family<List<Recommendation>, String>((ref, userId) {
  return ref.read(cloudRepositoryProvider).fetchRecommendations(userId);
});
