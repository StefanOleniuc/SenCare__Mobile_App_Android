// lib/application/send_batch_usecase.dart

import 'dart:async';
import '../domain/model/ble_event.dart';
import '../domain/model/burst_data.dart';
import '../domain/repository/sensor_repository.dart';
import '../domain/repository/cloud_repository.dart';

class SendBatchUseCase {
  final SensorRepository _sensorRepo; // expune un Stream<BleEvent>
  final CloudRepository _cloudRepo;
  final String patientId;

  // Buffer pentru evenimente lente (SensorEvent) primite în ultimele 30 s
  final List<SensorEvent> _slowBuffer = [];
  Timer? _timer;

  SendBatchUseCase(this._sensorRepo, this._cloudRepo,
      {required this.patientId});

  /// Începe ascultarea evenimentelor BLE și programarea batch-urilor
  void start() {
    // 1) Ne abonăm la fluxul de BleEvent și filtrăm doar SensorEvent:
    _sensorRepo.watchBleEvents().listen((bleEvent) {
      if (bleEvent is SensorEvent) {
        // Adăugăm datele lente la buffer
        _slowBuffer.add(bleEvent);

        // Dacă detectăm alarmă pe valorile curente, trimitem imediat un BurstData
        if (_isAlarm(bleEvent)) {
          _sendImmediateAlarm(bleEvent);
        }
      }
      // Dacă e EkgEvent, nu facem nimic aici (Ekg nu contează pentru media de 30 s)
    });

    // 2) La fiecare 30 s, calculăm media pe buffer și trimitem un BurstData
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      _sendBufferedBatch();
    });
  }

  /// Trimite acum, on-demand, batch-ul curent (fără a aștepta următoarea oră rotundă)
  void sendNow() {
    _sendBufferedBatch();
  }

  /// Oprește timer-ul periodic (apelează la dispose)
  void dispose() {
    _timer?.cancel();
  }

  /// Calculează media pe tot ce e în _slowBuffer și trimite la cloud
  void _sendBufferedBatch() {
    if (_slowBuffer.isEmpty) return;

    final int count = _slowBuffer.length;
    final int sumBpm =
    _slowBuffer.map((e) => e.bpm).reduce((a, b) => a + b);
    final double sumTemp =
    _slowBuffer.map((e) => e.temp).reduce((a, b) => a + b);
    final double sumHum =
    _slowBuffer.map((e) => e.hum).reduce((a, b) => a + b);

    final int bpmAvg = (sumBpm / count).round();
    final double tempAvg = sumTemp / count;
    final double humAvg = sumHum / count;

    final burst = BurstData(
      bpmAvg: bpmAvg,
      tempAvg: tempAvg,
      humAvg: humAvg,
      timestamp: DateTime.now(),
    );

    // Golește buffer-ul
    _slowBuffer.clear();

    // Trimite la cloud
    _cloudRepo.sendBurst(burst).catchError((e) {
      print('[SendBatchUseCase] Eroare la trimiterea BurstData: $e');
      // Dacă vrei, poți reintroduce datele în buffer pentru retry
    });
  }

  /// În caz de alarmă, trimite imediat un BurstData cu valorile curente
  void _sendImmediateAlarm(SensorEvent se) {
    final burst = BurstData(
      bpmAvg: se.bpm,
      tempAvg: se.temp,
      humAvg: se.hum,
      timestamp: DateTime.now(),
    );
    _cloudRepo.sendBurst(burst).catchError((e) {
      print('[SendBatchUseCase] Eroare la trimiterea alarmei: $e');
    });
  }

  /// Praguri de alarmă: bpm < 40 sau > 150, temp > 38.5
  bool _isAlarm(SensorEvent se) {
    if (se.bpm < 40 || se.bpm > 150) return true;
    if (se.temp > 38.5) return true;
    return false;
  }
}
