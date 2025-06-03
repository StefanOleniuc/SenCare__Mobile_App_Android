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

  // Buffer pentru valorile EKG primite în ultimele 30 s
  final List<double> _ecgBuffer30s = [];

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
        _slowBuffer.add(bleEvent);

        // Dacă detectăm alarmă pe valorile curente, trimitem imediat un BurstData
        /*if (_isAlarm(bleEvent)) {
          _sendImmediateAlarm(bleEvent);
        }*/
      }else if (bleEvent is EkgEvent) {
        // Adaug fiecare valoare EKG la buffer‐ul de 30 s
        _ecgBuffer30s.add(bleEvent.ekg);
        print('[SendBatchUseCase] 🔄 EkgEvent primit: ${bleEvent.ekg}');
      }
    }, onError: (error) {
      print('[SendBatchUseCase] ❌ Eroare în fluxul BLE: $error');
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

  /// Calculează media, adună lista EKG și trimite la Cloud
  void _sendBufferedBatch() {
    if (_slowBuffer.isEmpty && _ecgBuffer30s.isEmpty) {
      print('[SendBatchUseCase] ℹ Ambele buffere goale – nu trimit.');
      return;
    }

    // 1) dacă avem măcar un SensorEvent, calculăm media
    int? bpmAvg;
    double? tempAvg, humAvg;

    if (_slowBuffer.isNotEmpty) {
      final int count = _slowBuffer.length;
      final int sumBpm = _slowBuffer.map((e) => e.bpm).reduce((a, b) => a + b);
      final double sumTemp =
      _slowBuffer.map((e) => e.temp).reduce((a, b) => a + b);
      final double sumHum =
      _slowBuffer.map((e) => e.hum).reduce((a, b) => a + b);

      bpmAvg = (sumBpm / count).round();
      tempAvg = sumTemp / count;
      humAvg = sumHum / count;
    } else {
      // dacă slowBuffer e gol, setăm valorile cu 0 sau null după cum preferi
      bpmAvg = 0;
      tempAvg = 0.0;
      humAvg = 0.0;
    }

    // 2) Preluăm lista EKG (poate fi goală, dacă n‐au venit EkgEvent în ultimele 30 s)
    final List<double> ecgList = List<double>.from(_ecgBuffer30s);

    // 3) Creăm BurstData
    final burst = BurstData(
      bpmAvg: bpmAvg!,
      tempAvg: tempAvg!,
      humAvg: humAvg!,
      timestamp: DateTime.now(),
      ecgValues: ecgList,
    );

    print('[SendBatchUseCase] 📦 Trimitem BurstData ('
        'countSensor=${_slowBuffer.length}, ecgCount=${ecgList.length}) → $burst');

    // Golește buffer-ul după ce am calculat mediile
    _slowBuffer.clear();
    _ecgBuffer30s.clear();

    // 5) Trimitem la cloud
    _cloudRepo.sendBurstData(patientId, burst).catchError((e) {
      print('[SendBatchUseCase] ❌ Eroare la trimiterea BurstData: $e');
    });
  }

  // Dacă detectăm alarmă pe valorile lente, trimitem imediat un BurstData
  void _sendImmediateAlarm(SensorEvent se) {
    // Într‐o alarmă, nu avem neapărat EKG buffer, dar trimitem media curentă
    final burst = BurstData(
      bpmAvg: se.bpm,
      tempAvg: se.temp,
      humAvg: se.hum,
      timestamp: DateTime.now(),
      ecgValues: List<double>.from(_ecgBuffer30s),
    );

    print('[SendBatchUseCase] 🚨 Alarmă! BurstData imediat → $burst');
    _cloudRepo.sendBurstData(patientId, burst).catchError((e) {
      print('[SendBatchUseCase] ❌ Eroare la trimiterea burstului de alarmă: $e');
    });

    // După alarmă, resetăm bufferele:
    _slowBuffer.clear();
    _ecgBuffer30s.clear();
  }

  /// Pragurile de alarmă (exemplu simplu)
  bool _isAlarm(SensorEvent se) {
    if (se.bpm < 40 || se.bpm > 150) return true;
    if (se.temp > 38.5) return true;
    return false;
  }
}
