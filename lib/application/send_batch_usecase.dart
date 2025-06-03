// lib/application/send_batch_usecase.dart

import 'dart:async';
import '../domain/model/ble_event.dart';
import '../domain/model/burst_data.dart';
import '../domain/repository/sensor_repository.dart';
import '../domain/repository/cloud_repository.dart';

class SendBatchUseCase {
  final SensorRepository _sensorRepo;
  final CloudRepository _cloudRepo;
  final String patientId;

  final List<SensorEvent> _slowBuffer = [];
  final List<double> _ecgBuffer30s = [];
  Timer? _timer;

  SendBatchUseCase(
      this._sensorRepo,
      this._cloudRepo, {
        required this.patientId,
      }) {
    print('[SendBatchUseCase] 🚀 Creat cu patientId="$patientId"');
  }

  void start() {
    print('[SendBatchUseCase] ▶ start() apelat');
    // Ascult BLE-ul:
    _sensorRepo.watchBleEvents().listen((bleEvent) {
      if (bleEvent is SensorEvent) {
        print('[SendBatchUseCase] 🤖 SensorEvent primit: bpm=${bleEvent.bpm}, temp=${bleEvent.temp}, hum=${bleEvent.hum}');
        _slowBuffer.add(bleEvent);
      } else if (bleEvent is EkgEvent) {
        print('[SendBatchUseCase] 🔄 EkgEvent primit: ekg=${bleEvent.ekg}');
        _ecgBuffer30s.add(bleEvent.ekg);
      }
    }, onError: (e) {
      print('[SendBatchUseCase] ❌ Eroare în fluxul BLE: $e');
    });

    // Timer periodic (temporar, 5s pentru test – mai târziu schimbi în 30s):
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      print('[SendBatchUseCase] ⏰ Timer 5s s-a declanșat → apel _sendBufferedBatch()');
      _sendBufferedBatch();
    });
  }

  /// Apelează manual, on-demand (_sendBufferedBatch) fără să aștepți timer-ul.
  void sendNow() {
    print('[SendBatchUseCase] ℹ sendNow() apelat → apel _sendBufferedBatch()');
    _sendBufferedBatch();
  }

  void dispose() {
    _timer?.cancel();
  }

  void _sendBufferedBatch() {
    print('[SendBatchUseCase] 📤 Încep _sendBufferedBatch()');

    // 1) Verific dacă am patientId
    if (patientId.isEmpty) {
      print('[SendBatchUseCase] ❌ patientId este gol (""), nu trimit.');
      return;
    }

    // 2) Verific dacă bufferele sunt goale
    if (_slowBuffer.isEmpty && _ecgBuffer30s.isEmpty) {
      print('[SendBatchUseCase] ℹ Bufferele (sensor+ekg) sunt goale – nu trimit.');
      return;
    }

    // 3) Dacă avem măcar un SensorEvent, calculez media
    int bpmAvg;
    double tempAvg, humAvg;

    if (_slowBuffer.isNotEmpty) {
      final int count = _slowBuffer.length;
      final sumBpm = _slowBuffer.map((e) => e.bpm).reduce((a, b) => a + b);
      final sumTemp = _slowBuffer.map((e) => e.temp).reduce((a, b) => a + b);
      final sumHum  = _slowBuffer.map((e) => e.hum).reduce((a, b) => a + b);

      bpmAvg  = (sumBpm / count).round();
      tempAvg = sumTemp / count;
      humAvg  = sumHum / count;
    } else {
      bpmAvg  = 0;
      tempAvg = 0.0;
      humAvg  = 0.0;
    }

    // 4) Preiau lista de EKG
    final ecgList = List<double>.from(_ecgBuffer30s);

    // 5) Construiesc BurstData
    final burst = BurstData(
      bpmAvg: bpmAvg,
      tempAvg: tempAvg,
      humAvg: humAvg,
      timestamp: DateTime.now(),
      ecgValues: ecgList,
    );

    print('[SendBatchUseCase] 📦 BurstData creat: $burst');
    print('[SendBatchUseCase]    → număr SensorEvent în buffer: ${_slowBuffer.length}');
    print('[SendBatchUseCase]    → număr EkgEvent în buffer: ${ecgList.length}');

    // 6) Golesc bufferele
    _slowBuffer.clear();
    _ecgBuffer30s.clear();

    // 7) Trimit către cloud
    print('[SendBatchUseCase] 📬 Trimit burst la cloud: patientId="$patientId", payload=${burst.toJson()}');
    _cloudRepo.sendBurstData(patientId, burst).then((_) {
      print('[SendBatchUseCase] ✅ BurstData trimis cu succes la cloud.');
    }).catchError((e) {
      print('[SendBatchUseCase] ❌ Eroare la upload către cloud: $e');
    });
  }
}
