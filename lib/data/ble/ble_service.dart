// lib/data/ble/ble_service.dart

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'dart:async';

class BleService {
  final FlutterReactiveBle _ble;
  StreamSubscription? _connection;

  BleService(this._ble);

  /// Începe un stream care scanează pentru un device cu serviceUuid, se conectează
  /// şi apoi returnează notificările de la characteristicUuid.
  Stream<List<int>> watchCharacteristic({
    required Uuid serviceUuid,
    required Uuid characteristicUuid,
  }) async* {
    print('[BleService] Starting full watch flow...');
    final device = await _scanForDevice(serviceUuid);
    print('[BleService] Device found: ${device.name} (${device.id})');
    yield* _connectAndSubscribe(device, serviceUuid, characteristicUuid);
  }

  Future<DiscoveredDevice> _scanForDevice(Uuid serviceUuid) async {
    print('[BleService] Scanning for devices with service $serviceUuid...');
    final device = await _ble.scanForDevices(
      withServices: [serviceUuid],
      scanMode: ScanMode.lowLatency,
    ).first;
    print('[BleService] scanForDevices() yielded ${device.name} (${device.id})');
    return device;
  }

  Stream<List<int>> _connectAndSubscribe(
      DiscoveredDevice device,
      Uuid serviceUuid,
      Uuid characteristicUuid,
      ) async* {
    print('[BleService] Connecting to ${device.name}...');
    await _connection?.cancel();

    final completer = Completer<void>();
    _connection = _ble.connectToDevice(
      id: device.id,
      connectionTimeout: const Duration(seconds: 10),
    ).listen((connectionState) {
      print('[BleService] Connection state: ${connectionState.connectionState}');
      if (connectionState.connectionState == DeviceConnectionState.connected) {
        if (!completer.isCompleted) {
          completer.complete();
        }
      }
    }, onError: (error) {
      print('[BleService] Connection error: $error');
      if (!completer.isCompleted) {
        completer.completeError(error);
      }
    });

    try {
      // Așteptăm să ne conectăm
      await completer.future;
      print('[BleService] Successfully connected to ${device.name}. Subscribing...');
    } catch (e) {
      print('[BleService] Could not connect: $e');
      rethrow;
    }

    // Ne abonăm la notificări
    yield* _ble.subscribeToCharacteristic(
      QualifiedCharacteristic(
        serviceId: serviceUuid,
        characteristicId: characteristicUuid,
        deviceId: device.id,
      ),
    ).map((bytes) {
      print('[BleService] Received raw bytes: '
          '${bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}');
      return bytes;
    });
  }

  void dispose() {
    _connection?.cancel();
  }
}