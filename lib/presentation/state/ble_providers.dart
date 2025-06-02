// lib/presentation/state/ble_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/ble/ble_service.dart';
import '../../domain/model/ble_event.dart';

/// 1) Singleton BleService: o singură instanță pe toată durata aplicației.
final bleServiceProvider = Provider<BleService>((ref) {
  final bleService = BleService();
  ref.onDispose(() => bleService.dispose());
  return bleService;
});

/// 2) StreamProvider care:
///    - apelează bleService.initAndStart() o singură dată
///    - apoi yield*uiește toate evenimentele BleEvent emise de BleService
final bleEventStreamProvider = StreamProvider<BleEvent>((ref) async* {
  final bleService = ref.read(bleServiceProvider);

  print('[Riverpod] Apelează initAndStart() BleService …');
  await bleService.initAndStart();

  print('[Riverpod] initAndStart() a terminat, așteptăm BleEvent-uri…');
  yield* bleService.bleEventStream;
});
