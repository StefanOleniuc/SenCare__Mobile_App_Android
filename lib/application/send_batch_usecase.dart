//lib/application/send_batch_usecase.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart'; // <-- pentru compute()
import '../domain/model/ble_event.dart';
import '../domain/model/burst_data.dart';
import '../domain/repository/sensor_repository.dart';
import '../domain/repository/cloud_repository.dart';

/// Funcție pentru isolate: transformă lista de double în JSON
String _encodeEcgList(List<double> ecgList) {
  return jsonEncode(ecgList);
}

class SendBatchUseCase {
  final SensorRepository _sensorRepo;
  final CloudRepository  _cloudRepo;
  final String           userId;

  final List<SensorEvent> _slowBuffer  = [];
  final List<double>      _ecgBuffer30s = [];
  Timer? _timer;

  SendBatchUseCase(
      this._sensorRepo,
      this._cloudRepo, {
        required this.userId,
      });

  void start() {
    _sensorRepo.watchBleEvents().listen((bleEvent) {
      if (bleEvent is SensorEvent) {
        _slowBuffer.add(bleEvent);
      } else if (bleEvent is EkgEvent) {
        // Adăugăm punctul ECG
        _ecgBuffer30s.add(bleEvent.ekg);
        // Dacă sunt >200 puncte (ultimele ~10s), eliminăm primul
        if (_ecgBuffer30s.length > 200) {
          _ecgBuffer30s.removeAt(0);
        }
      }
    }, onError: (error) {
      print('[SendBatchUseCase] ❌ Eroare BLE: $error');
    });

    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      _sendBufferedBatch();
    });
  }

  void sendNow() {
    _sendBufferedBatch();
  }

  void dispose() {
    _timer?.cancel();
  }

  void _sendBufferedBatch() {
    if (_slowBuffer.isEmpty && _ecgBuffer30s.isEmpty) {
      print('[SendBatchUseCase] ℹ Buffere goale – nu trimit.');
      return;
    }

    // 1) Media pentru valorile lente
    int bpmAvg = 0;
    double tempAvg = 0.0, humAvg = 0.0;
    if (_slowBuffer.isNotEmpty) {
      final int count = _slowBuffer.length;
      final int sumBpm = _slowBuffer.map((e) => e.bpm).reduce((a, b) => a + b);
      final double sumTemp =
      _slowBuffer.map((e) => e.temp).reduce((a, b) => a + b);
      final double sumHum =
      _slowBuffer.map((e) => e.hum).reduce((a, b) => a + b);

      bpmAvg  = (sumBpm / count).round();
      tempAvg = sumTemp / count;
      humAvg  = sumHum / count;
    }

    // 2) Copiem buffer-ul ECG într-un snapshot și golim
    final List<double> ecgSnapshot = List<double>.from(_ecgBuffer30s);
    _ecgBuffer30s.clear();

    final DateTime now = DateTime.now();
    final BurstData burstIntermediar = BurstData(
      bpmAvg:    bpmAvg,
      tempAvg:   tempAvg,
      humAvg:    humAvg,
      timestamp: now,
      ecgString: '',
    );

    print('[SendBatchUseCase] 📦 BurstData (fără ECG): '
        'bpmAvg=$bpmAvg, tempAvg=$tempAvg, humAvg=$humAvg, '
        'ecgCount=${ecgSnapshot.length}');

    // 3) Dacă nu avem ECG, trimitem direct cu ecgString="[]"
    if (ecgSnapshot.isEmpty) {
      final burstGol = burstIntermediar.copyWith(ecgString: '[]');
      _uploadBurst(burstGol);
      _slowBuffer.clear();
      return;
    }

    // 4) Serializăm ecgSnapshot pe un isolate, apoi trimitem
    compute<List<double>, String>(
      _encodeEcgList,
      ecgSnapshot,
    ).then((encodedEcg) {
      final BurstData burstComplet =
      burstIntermediar.copyWith(ecgString: encodedEcg);
      _uploadBurst(burstComplet);
    }).catchError((err) {
      print('[SendBatchUseCase] ❌ Eroare la jsonEncode(ecg): $err');
    });

    _slowBuffer.clear();
  }

  void _uploadBurst(BurstData burst) {
    final payload = {
      'userId':      int.parse(userId),
      'Puls':        burst.bpmAvg,
      'Temperatura': burst.tempAvg,
      'Umiditate':   burst.humAvg,
      'ECG':         burst.ecgString,
      'Data_timp':   burst.timestamp.toIso8601String(),
    };

    print('[SendBatchUseCase] 📬 Upload → userId=$userId, '
        'Puls=${burst.bpmAvg}, Temperatura=${burst.tempAvg}, '
        'Umiditate=${burst.humAvg}, ECG-lungime=${burst.ecgString.length}');

    _cloudRepo.sendBurstData(userId, burst).then((_) {
      print('[SendBatchUseCase] ✅ Upload OK');
    }).catchError((e) {
      print('[SendBatchUseCase] ❌ Eroare la upload: $e');
    });
  }
}