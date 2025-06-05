// lib/data/accelerometer/accelerometer_service.dart
import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';

class AccelerometerService {
  final List<AccelerometerEvent> _buffer = [];
  StreamSubscription<AccelerometerEvent>? _subscription;
  Timer? _timer;

  /// Începe să asculte accelerometerEvents și apelează onAlarm când se detectează cădere
  void start(void Function(AccelerometerEvent) onAlarm) {
    _subscription = accelerometerEvents.listen((event) {
      _timer?.cancel();
      _timer = Timer(const Duration(seconds: 1), () {
        _buffer.add(event);
        if (_buffer.length > 30) _buffer.removeAt(0);
        if (_isFallDetected(event)) {
          onAlarm(event);
        }
      });
    });
  }

  bool _isFallDetected(AccelerometerEvent event) {
    const double prag = 15.0;
    return (event.x.abs() > prag || event.y.abs() > prag || event.z.abs() > prag);
  }

  /// Oprește listener-ul accelerometru
  void stop() {
    _subscription?.cancel();
    _timer?.cancel();
  }

  /// Întoarce ultimele date (max 30 de evenimente)
  List<AccelerometerEvent> get last30sData => List.unmodifiable(_buffer);
}
