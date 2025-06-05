import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../domain/model/ble_event.dart';
import '../domain/model/alarm_model.dart';
import '../domain/model/burst_data.dart';
import '../domain/repository/cloud_repository.dart';

String _encodeEcgList(List<double> ecgList) => jsonEncode(ecgList);

class SendAlarmUseCase {
  final CloudRepository cloudRepo;
  SendAlarmUseCase(this.cloudRepo);

  Future<void> call({
    required String userId,
    required SensorEvent event,
    required List<double> ecg, // buffer de 200 valori din ultimele 10s
    required AlarmModel alarm,
    required String tipAlarma,
    String? userMessage,
  }) async {
    // --- 1) Pregătim ecgString ---
    String ecgString;
    if (ecg.isEmpty) {
      ecgString = '[]';
    } else {
      ecgString = await compute(_encodeEcgList, ecg);
    }

    final burst = BurstData(
      bpmAvg: event.bpm,
      tempAvg: event.temp,
      humAvg: event.hum,
      timestamp: DateTime.now(),
      ecgString: ecgString,
    );

    // --- 2) PRINT înainte de upload-ul instant în DateFiziologice ---
    print(
        '🚨 [SendAlarmUseCase] 📬 Trimit date fiziologice INSTANT (burst) → '
            'Puls=${burst.bpmAvg}, Temp=${burst.tempAvg}, Umid=${burst.humAvg}, '
            'ECG-len=${burst.ecgString.length}, Timp=${burst.timestamp.toIso8601String()}'
    );

    try {
      // 3) Upload în tabela DateFiziologice (API: /api/mobile/datefiziologice)
      await cloudRepo.sendBurstData(userId, burst);
      print('✅ [SendAlarmUseCase] sendBurstData instant OK');
    } catch (e) {
      print('🛑 [SendAlarmUseCase] sendBurstData ERROR: $e');
      rethrow;
    }

    // --- 4) Pregătim parametrii pentru istoricul de alarme ---

    // Trimitem un actiune scurtă (maxim lungimea admisă în col. Actiune)
    const String actiuneTrimisa = 'activata';

    // Pentru descriere, folosim doar mesajul utilizatorului (dacă există)
    final String descriereTrimisa = userMessage?.trim() ?? '';

    try {
      // 5) Upload în tabela IstoricAlarmeAvertizari
      await cloudRepo.sendAlarmHistory(
        userId: userId,
        alarmaId: alarm.alarmaId,
        tipAlarma: tipAlarma,
        descriere: descriereTrimisa,
        actiune: actiuneTrimisa,
      );
      print('✅ [SendAlarmUseCase] sendAlarmHistory OK');
    } catch (e) {
      print('🛑 [SendAlarmUseCase] sendAlarmHistory ERROR: $e');
      rethrow;
    }
  }
}
