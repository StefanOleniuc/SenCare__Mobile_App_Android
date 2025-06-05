// lib/presentation/state/send_alarm_usecase_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/send_alarm_usecase.dart';
import 'cloud_providers.dart';

final sendAlarmUseCaseProvider = Provider<SendAlarmUseCase>((ref) {
  return SendAlarmUseCase(ref.read(cloudRepositoryProvider));
});
