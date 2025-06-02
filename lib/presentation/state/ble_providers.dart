// lib/presentation/state/ble_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/ble/ble_service.dart';
import '../../domain/model/ble_event.dart';

/// 1) Singleton BleService: o singură instanță pe toată durata aplicației.
final bleServiceProvider = Provider<BleService>((ref) {
  final bleService = BleService();
  ref.onDispose(() {
    print('[ble_providers] Disposing BleService...');
    bleService.dispose();
  });
  return bleService;
});

/// 2) StreamProvider care:
///    - apelează bleService.initAndStart() o singură dată
///    - apoi yield*uiește toate evenimentele BleEvent emise de BleService
final bleEventStreamProvider = StreamProvider<BleEvent>((ref) async* {
  final bleService = ref.read(bleServiceProvider);

  print('[ble_providers] ▶️ Pornesc initAndStart() BleService …');
  await bleService.initAndStart();
  print('[ble_providers] ✅ BleService initAndStart() s-a încheiat. Emit evenimente…');

  yield* bleService.bleEventStream;
});
