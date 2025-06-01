// lib/application/send_batch_usecase.dart

import 'dart:async';
import '../domain/model/sensor_data.dart';
import '../domain/repository/sensor_repository.dart';
import '../domain/repository/cloud_repository.dart';

class SendBatchUseCase {
  final SensorRepository _sensorRepo;
  final CloudRepository _cloudRepo;
  final String patientId;
  final List<SensorData> _buffer = [];
  Timer? _timer;

  SendBatchUseCase(this._sensorRepo, this._cloudRepo, {required this.patientId});

  void start() {
    _sensorRepo.watchSensorData().listen((data) {
      _buffer.add(data);
      if (_isAlarm(data)) {
        _postImmediateAlert(data);
      }
    });

    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      _sendBufferedBatch();
    });
  }

  void sendNow() {
    _sendBufferedBatch();
  }

  void _sendBufferedBatch() {
    if (_buffer.isEmpty) return;
    final batchToSend = List<SensorData>.from(_buffer);
    _buffer.clear();
    _cloudRepo.sendSensorBatch(batchToSend);
  }

  void _postImmediateAlert(SensorData data) {
    // Avem nevoie de un model Alert =>
    // _cloudRepo.postAlert(Alert(...));
    // Dar dacă nu ai Alert definit încă, poți lăsa vid sau un print simplu:
    // print('Alertă imediată: date anormale pentru pacient $patientId');
  }

  bool _isAlarm(SensorData data) {
    // Simplificare: trend example hr > 150 sau hr < 40 generează alarmă
    if (data.bpm > 150 || data.bpm < 40) return true;
    if (data.ekg > 1.5) return true;
    if (data.temp > 38.5) return true;
    return false;
  }

  void dispose() {
    _timer?.cancel();
  }
}