// lib/presentation/screen/home_screen.dart

import 'dart:ui';
import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';

import '../../data/accelerometer/accelerometer_service.dart';
import '../state/ble_providers.dart';
import '../state/usecase_providers.dart';
import '../state/auth_provider.dart';
import '../state/normal_values_provider.dart';
import '../state/alarm_provider.dart';
import '../../domain/model/ble_event.dart';
import '../../domain/model/normal_values.dart';
import '../../domain/model/alarm_model.dart';
import 'recommendation_screen.dart';
import 'calendar_activitati_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // ────────────────────────────────────────────
  // Buffere și variabile pentru EKG și senzori
  // ────────────────────────────────────────────

  final List<FlSpot> _ecgBuffer = [];
  double _currentX = 0.0;

  int _latestBpm = 0;
  double _latestTemp = 0;
  double _latestHum = 0;

  bool _permisiiCerute = false;
  late AccelerometerService _accelService;

  Timer? _alarmTimer;
  List<SensorEvent> _last10sEvents = [];

  bool _isRunning = false;    // semnalează dacă utilizatorul e în mișcare
  bool _alarmShowing = false; // dacă un dialog de alarmă e deja afișat

  NormalValues? _normalValues;
  List<AlarmModel> _alarme = [];

  // ────────────────────────────────────────────
  // initState + configurare la montare
  // ────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    // 1) Pornim AccelerometerService
    _accelService = AccelerometerService();
    _accelService.start((event) {
      final magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      _isRunning = magnitude > 8.0;
      // Dacă s-ar dori alarmă cădere, se activează aici.
      // În BD nu există însă "Alarmă Cădere", deci nu declanșăm nimic.
    });

    // 2) După montare, cerem permisiuni BLE și preluăm date din cloud
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initBleAndBatch();

      final authState = ref.read(authStateProvider);
      final userId = authState.maybeWhen(
        authenticated: (id) => id.toString(),
        orElse: () => '',
      );

      if (userId.isNotEmpty) {
        // 2a) Preluăm valorile normale
        try {
          final normal = await ref.read(normalValuesProvider(userId).future);
          _normalValues = normal;
        } catch (_) {
          // dacă nu se încarcă, rămâne null
        }
        // 2b) Preluăm lista de alerte + avertizări
        try {
          final alarme = await ref.read(alarmsProvider(userId).future);
          _alarme = alarme;
        } catch (_) {}
        setState(() {});
      }

      // 3) Pornim timer-ul periodic la 10s
      _alarmTimer = Timer.periodic(const Duration(seconds: 10), (_) => _checkAlarms());

      // 4) Pornim SendBatchUseCase (trimite batch la 30s)
      ref.read(sendBatchUseCaseProvider).start();
    });
  }

  // ────────────────────────────────────────────
  // Solicită permisiunile Bluetooth + Location și pornește BLE
  // ────────────────────────────────────────────
  Future<void> _initBleAndBatch() async {
    if (_permisiiCerute) return;
    _permisiiCerute = true;

    final status = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    if (status[Permission.bluetoothScan] != PermissionStatus.granted ||
        status[Permission.bluetoothConnect] != PermissionStatus.granted ||
        status[Permission.locationWhenInUse] != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            'Aplicația are nevoie de permisiuni Bluetooth și Locație.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
      return;
    }

    ref.refresh(bleEventStreamProvider);
  }

  // ────────────────────────────────────────────
  // Construcția UI-ului
  // ────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bleAsync = ref.watch(bleEventStreamProvider);

    final authState = ref.watch(authStateProvider);
    final userId = authState.maybeWhen(
      authenticated: (id) => id.toString(),
      orElse: () => '',
    );

    return Scaffold(
      drawer: _buildDrawer(userId),

      body: Stack(
        children: [
          // Fundal gradient + puncte subtile
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFe8f1f8), Color(0xFFffffff)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: CustomPaint(
              painter: _BackgroundDotsPainter(),
              child: Container(),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(color: Colors.white.withOpacity(0.2)),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: bleAsync.when(
                      data: (BleEvent event) {
                        if (event is SensorEvent) {
                          // eveniment senzori (puls, temp, hum)
                          _latestBpm = event.bpm;
                          _latestTemp = event.temp;
                          _latestHum = event.hum;

                          _last10sEvents.add(event);
                          if (_last10sEvents.length > 10) {
                            _last10sEvents.removeAt(0);
                          }
                        } else if (event is EkgEvent) {
                          // eveniment EKG (~50ms)
                          final ekgValue = event.ekg;
                          _ecgBuffer.add(FlSpot(_currentX, ekgValue));
                          _currentX += 1.0;
                          if (_ecgBuffer.length > 200) {
                            _ecgBuffer.removeAt(0);
                          }
                        }

                        return SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              const SizedBox(height: 12),
                              _buildEcgChartCard(),
                              const SizedBox(height: 24),
                              _buildSensorCard(
                                icon: Icons.monitor_heart,
                                title: 'Puls',
                                value: '$_latestBpm BPM',
                                color: Colors.green,
                              ),
                              const SizedBox(height: 16),
                              _buildSensorCard(
                                icon: Icons.thermostat,
                                title: 'Temperatură',
                                value: '${_latestTemp.toStringAsFixed(1)} °C',
                                color: Colors.orangeAccent,
                              ),
                              const SizedBox(height: 16),
                              _buildSensorCard(
                                icon: Icons.water_drop,
                                title: 'Umiditate',
                                value: '${_latestHum.toStringAsFixed(1)} %',
                                color: Colors.lightBlueAccent,
                              ),
                              const SizedBox(height: 24),
                              Material(
                                elevation: 6,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                shadowColor: Colors.blue.shade300,
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      ref.refresh(bleEventStreamProvider);
                                    },
                                    icon: const Icon(Icons.refresh, color: Colors.white),
                                    label: const Text('Reîncearcă conexiunea'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue.shade700,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        );
                      },
                      loading: () => Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Caut dispozitiv BLE…\n(Asigură-te că ESP32 e pornit și în raza Bluetooth)',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      error: (err, _) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error, color: Colors.redAccent, size: 48),
                            const SizedBox(height: 12),
                            Text(
                              'Eroare BLE:\n$err',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red, fontSize: 16),
                            ),
                            const SizedBox(height: 20),
                            Material(
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              shadowColor: Colors.redAccent.shade200,
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    ref.refresh(bleEventStreamProvider);
                                  },
                                  icon: const Icon(Icons.refresh, color: Colors.white),
                                  label: const Text('Reîncearcă'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────
  // AppBar cu colțurile de jos rotunjite și umbrelă
  // ────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue.shade800,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: Builder(
            builder: (context) => GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.menu,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
          title: const Text(
            'Sencare – Feel good, stay safe.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: const [
            SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────
  // Drawer cu colțuri de jos rotunjite și umbrelă
  // ────────────────────────────────────────────
  Widget _buildDrawer(String userId) {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      elevation: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 140,
            padding: const EdgeInsets.only(left: 16, bottom: 16),
            alignment: Alignment.bottomLeft,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade900, Colors.blue.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Text(
              'Meniu pacient',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.list_alt, color: Colors.blue),
            title: const Text('Recomandări'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => RecommendationScreen(userId: userId),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month, color: Colors.blue),
            title: const Text('Calendar activități'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CalendarScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────
  // Card pentru afișare senzor (puls, temp, umiditate)
  // ────────────────────────────────────────────
  Widget _buildSensorCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 8,
      shadowColor: color.withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────
  // Card cu grafic EKG (LineChart), cu umbrelă
  // ────────────────────────────────────────────
  Widget _buildEcgChartCard() {
    return SizedBox(
      height: 200,
      child: Card(
        elevation: 8,
        shadowColor: Colors.redAccent.withOpacity(0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: Colors.grey.withOpacity(0.3),
                  strokeWidth: 0.5,
                ),
                getDrawingVerticalLine: (_) => FlLine(
                  color: Colors.grey.withOpacity(0.3),
                  strokeWidth: 0.5,
                ),
              ),
              titlesData: FlTitlesData(show: false),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.grey, width: 0.5),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: _ecgBuffer,
                  isCurved: false,
                  color: Colors.redAccent,
                  barWidth: 2,
                  dotData: FlDotData(show: false),
                ),
              ],
              minX: _ecgBuffer.isNotEmpty ? _ecgBuffer.first.x : 0,
              maxX: _ecgBuffer.isNotEmpty ? _ecgBuffer.last.x : 0,
              minY: _ecgBuffer.isNotEmpty
                  ? _ecgBuffer.map((e) => e.y).reduce(min)
                  : 0,
              maxY: _ecgBuffer.isNotEmpty
                  ? _ecgBuffer.map((e) => e.y).reduce(max)
                  : 1,
            ),
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────
  //  Verificarea alarmelor la fiecare 10s
  // ────────────────────────────────────────────
  void _checkAlarms() async {
    // Nu arătăm loguri inutile dacă dialogul e deja afișat
    if (_alarmShowing) return;

    if (_normalValues == null) return;
    if (_last10sEvents.isEmpty) return;

    final last = _last10sEvents.last;
    // Dacă bpm == 0, înseamnă date invalide
    if (last.bpm == 0) {
      _last10sEvents.clear();
      return;
    }

    final int pulsMin = _normalValues!.pulsMin;
    final int pulsMax = _normalValues!.pulsMax;
    final int pulsMaxInMiscar = pulsMax + 20;

    if (_isRunning) {
      // În mișcare: doar valori extreme > pulsMax + 20 declanșează alarmă
      if (last.bpm > pulsMaxInMiscar) {
        _alarmShowing = true;
        await _showAlarmDialog(
          'Alarmă Puls',
          'Pulsul e mult prea ridicat chiar și în mișcare!',
          'Alarma Puls',
          last,
        );
        _last10sEvents.clear();
        return;
      } else {
        _last10sEvents.clear();
        return;
      }
    } else {
      // Nu suntem în mișcare: analizăm puls normal
      if (last.bpm < pulsMin || last.bpm > pulsMax) {
        _alarmShowing = true;
        await _showAlarmDialog(
          'Alarmă Puls',
          'Pulsul este în afara limitelor!',
          'Alarma Puls',
          last,
        );
        _last10sEvents.clear();
        return;
      } else if ((last.bpm - pulsMin).abs() <= 5 || (last.bpm - pulsMax).abs() <= 5) {
        _alarmShowing = true;
        await _showAlarmDialog(
          'Avertizare Puls',
          'Pulsul este aproape de limită.',
          'Avertizare Puls',
          last,
        );
        _last10sEvents.clear();
        return;
      }
    }

    // Temperatură
    final double tempMin = _normalValues!.temperaturaMin;
    final double tempMax = _normalValues!.temperaturaMax;
    if (last.temp < tempMin || last.temp > tempMax) {
      _alarmShowing = true;
      await _showAlarmDialog(
        'Alarmă Temperatura',
        'Temperatura este în afara limitelor!',
        'Alarma Temperatura',
        last,
      );
      _last10sEvents.clear();
      return;
    } else if ((last.temp - tempMin).abs() <= 0.5 || (last.temp - tempMax).abs() <= 0.5) {
      _alarmShowing = true;
      await _showAlarmDialog(
        'Avertizare Temperatura',
        'Temperatura este aproape de limită.',
        'Avertizare Temperatura',
        last,
      );
      _last10sEvents.clear();
      return;
    }

    // Umiditate
    final double humMin = _normalValues!.umiditateMin;
    final double humMax = _normalValues!.umiditateMax;
    if (last.hum < humMin || last.hum > humMax) {
      _alarmShowing = true;
      await _showAlarmDialog(
        'Alarmă Umiditate',
        'Umiditatea este în afara limitelor!',
        'Alarma Umiditate',
        last,
      );
      _last10sEvents.clear();
      return;
    } else if ((last.hum - humMin).abs() <= 2 || (last.hum - humMax).abs() <= 2) {
      _alarmShowing = true;
      await _showAlarmDialog(
        'Avertizare Umiditate',
        'Umiditatea este aproape de limită.',
        'Avertizare Umiditate',
        last,
      );
      _last10sEvents.clear();
      return;
    }

    // (Opțional) ECG — rămâne neimplementat în acest exemplu
    _last10sEvents.clear();
  }

  // ────────────────────────────────────────────
  // Afișează dialog de alarmă/avertizare
  // ────────────────────────────────────────────
  Future<void> _showAlarmDialog(
      String title,
      String content,
      String tip,
      SensorEvent? event,
      ) async {
    _alarmShowing = true;
    String userMessage = '';

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(content),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Mesaj asociat (opțional)',
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => userMessage = val,
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _sendAlarmToCloud(tip, event, userMessage);
              _alarmShowing = false;
            },
            child: const Text('Trimite'),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────
  // Trimite alarma + datele fiziologice la cloud
  // ────────────────────────────────────────────
  Future<void> _sendAlarmToCloud(
      String tip,
      SensorEvent? event,
      String userMessage,
      ) async {
    final authState = ref.read(authStateProvider);
    final userId = authState.maybeWhen(
      authenticated: (id) => id.toString(),
      orElse: () => '',
    );

    // 1) Trimitem date fiziologice
    final dataFiziologice = {
      'userId': userId,
      'Puls': event?.bpm,
      'Temperatura': event?.temp,
      'Umiditate': event?.hum,
      'ECG': _ecgBuffer.isNotEmpty
          ? _ecgBuffer.map((e) => e.y).toList().toString()
          : null,
      'Data_timp': DateTime.now().toIso8601String(),
    };
    try {
      await Dio().post(
        'https://sencareapp-backend.azurewebsites.net/api/mobile/datefiziologice',
        data: dataFiziologice,
      );
    } catch (_) {}

    // 2) Găsim AlarmModel în lista _alarme (fără diacritice!)
    AlarmModel? foundModel;
    try {
      foundModel = _alarme.firstWhere((a) => a.tipAlarma == tip);
    } catch (_) {
      return; // dacă nu există tipul exact în BD, nu trimitem istoric
    }

    // 3) Trimitem în istoricul de alarme
    final dataIstoric = {
      'userId': userId,
      'alarmaId': foundModel.alarmaId,
      'tipAlarma': tip,
      'descriere': userMessage,
      'actiune': 'confirmata_de_utilizator',
    };
    try {
      await Dio().post(
        'https://sencareapp-backend.azurewebsites.net/api/mobile/istoric-alarme',
        data: dataIstoric,
      );
    } catch (_) {}
  }

  @override
  void dispose() {
    _alarmTimer?.cancel();
    _accelService.stop();
    super.dispose();
  }
}

// ────────────────────────────────────────────
// Painter-ul de fundal cu puncte subtile
// ────────────────────────────────────────────
class _BackgroundDotsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.grey.withOpacity(0.02);
    const double step = 20.0;
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 1.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
