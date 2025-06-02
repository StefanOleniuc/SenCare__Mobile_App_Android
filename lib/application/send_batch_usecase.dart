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
  final List<SensorEvent> _buffer = [];
  Timer? _timer;

  SendBatchUseCase(
      this._sensorRepo,
      this._cloudRepo, {
        required this.patientId,
      });

  /// Începe ascultarea evenimentelor BLE și programarea batch-urilor la 30 s
  void start() {
    // 1) Ne abonăm la fluxul de BleEvent și filtrăm doar SensorEvent
    _sensorRepo.watchBleEvents().listen((bleEvent) {
      if (bleEvent is SensorEvent) {
        // Adăugăm datele lente la buffer
        _buffer.add(bleEvent);

        // Dacă detectăm alarmă pe valorile curente, trimitem imediat un BurstData
        /*if (_isAlarm(bleEvent)) {
          _sendImmediateAlarm(bleEvent);
        }*/
      }
      // Dacă e EkgEvent, nu adăugăm în buffer (EKG nu contează pentru media de 30 s)
    });

    // 2) La fiecare 30 s, calculăm media pe buffer și trimitem un BurstData
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      _sendBufferedBatch();
    });
  }

  /// Trimite imediat, on-demand, batch-ul curent (fără a aștepta următoarea rulare)
  void sendNow() {
    _sendBufferedBatch();
  }

  /// Oprește timer-ul periodic (apelează la dispose)
  void dispose() {
    _timer?.cancel();
  }

  /// Calculează media pe tot ce e în _buffer și trimite la cloud
  void _sendBufferedBatch() {
    if (_buffer.isEmpty) return;

    final int count = _buffer.length;
    int sumBpm = 0;
    double sumTemp = 0.0;
    double sumHum = 0.0;

    for (var e in _buffer) {
      sumBpm += e.bpm;
      sumTemp += e.temp;
      sumHum += e.hum;
    }

    final int bpmAvg = (sumBpm / count).round();
    final double tempAvg = sumTemp / count;
    final double humAvg = sumHum / count;
    final DateTime now = DateTime.now();

    final burst = BurstData(
      patientId: patientId,
      bpmAvg: bpmAvg,
      tempAvg: tempAvg,
      humAvg: humAvg,
      timestamp: now,
    );

    // Golește buffer-ul după ce am calculat mediile
    _buffer.clear();

    // Trimite la cloud și adaugă debug‐prints:
    _cloudRepo
        .sendBurstData(patientId, [burst])
        .then((_) {
      print(
        '[SendBatchUseCase] ✅ BurstData trimis cu succes la ${now.toIso8601String()}. '
            'patientId=$patientId, bpmAvg=$bpmAvg, tempAvg=$tempAvg, humAvg=$humAvg',
      );
    })
        .catchError((error) {
      print('[SendBatchUseCase] ❌ Eroare la trimiterea BurstData: $error');
    });
  }

  void _sendImmediateAlarm(SensorEvent se) {
    final burst = BurstData(
      patientId: patientId,
      bpmAvg: se.bpm,
      tempAvg: se.temp,
      humAvg: se.hum,
      timestamp: DateTime.now(),
    );

    _cloudRepo
        .sendBurstData(patientId, [burst])
        .then((_) {
      print(
        '[SendBatchUseCase] 🚨 Alarmă imediată trimisă cu succes! '
            'patientId=$patientId, bpm=${se.bpm}, temp=${se.temp}, hum=${se.hum}',
      );
    })
        .catchError((error) {
      print('[SendBatchUseCase] ❌ Eroare la trimiterea alarmei: $error');
    });
  }
}
