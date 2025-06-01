/*
// lib/presentation/state/alerts_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

// AlertModel este definit în domain/repository/cloud_repository.dart
import '../../domain/repository/cloud_repository.dart' show AlertModel;

// cloudRepositoryProvider este definit în presentation/state/cloud_providers.dart
import 'cloud_providers.dart';

/// FutureProvider.family care preia lista de alerte după patientId
final alertsProvider =
FutureProvider.family<List<AlertModel>, String>((ref, patientId) async {
  final repo = ref.read(cloudRepositoryProvider);
  return repo.fetchAlerts(patientId);
});
*/
