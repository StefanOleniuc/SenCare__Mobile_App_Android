import 'dart:ui';
import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../data/accelerometer/accelerometer_service.dart';
import '../state/ble_providers.dart';
import '../state/usecase_providers.dart';
import '../state/auth_provider.dart';
import '../state/normal_values_provider.dart';
import '../state/alarm_provider.dart';
import '../state/send_alarm_usecase_provider.dart'; // <--- NOU!
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
  final List<FlSpot> _ecgBuffer = [];
  double _currentX = 0.0;
  int _latestBpm = 0;
  double _latestTemp = 0;
  double _latestHum = 0;
  bool _permisiiCerute = false;
  late AccelerometerService _accelService;
  Timer? _alarmTimer;
  List<SensorEvent> _last10sEvents = [];
  bool _isRunning = false;
  bool _alarmShowing = false;
  NormalValues? _normalValues;
  List<AlarmModel> _alarme = [];

  @override
  void initState() {
    super.initState();
    _accelService = AccelerometerService();
    _accelService.start((event) {
      final magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      _isRunning = magnitude > 8.0;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initBleAndBatch();

      final authState = ref.read(authStateProvider);
      final userId = authState.maybeWhen(
        authenticated: (id) => id.toString(),
        orElse: () => '',
      );

      if (userId.isNotEmpty) {
        try {
          final normal = await ref.read(normalValuesProvider(userId).future);
          _normalValues = normal;
        } catch (_) {}
        try {
          final alarme = await ref.read(alarmsProvider(userId).future);
          _alarme = alarme;
        } catch (_) {}
        setState(() {});
      }

      _alarmTimer = Timer.periodic(const Duration(seconds: 10), (_) => _checkAlarms());
      // Batch la 30s orchestrat din provider/usecase
      ref.read(sendBatchUseCaseProvider).start();
    });
  }

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
                          _latestBpm = event.bpm;
                          _latestTemp = event.temp;
                          _latestHum = event.hum;
                          _last10sEvents.add(event);
                          if (_last10sEvents.length > 10) {
                            _last10sEvents.removeAt(0);
                          }
                        } else if (event is EkgEvent) {
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

  void _checkAlarms() async {
    if (_alarmShowing) return;
    if (_normalValues == null) return;
    if (_last10sEvents.isEmpty) return;

    final last = _last10sEvents.last;
    if (last.bpm == 0) {
      _last10sEvents.clear();
      return;
    }

    final int pulsMin = _normalValues!.pulsMin;
    final int pulsMax = _normalValues!.pulsMax;
    final int pulsMaxInMiscar = pulsMax + 20;

    if (_isRunning) {
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

    _last10sEvents.clear();
  }

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

  /// FOARTE IMPORTANT: doar apelează usecase-ul, nu implementa logică API aici!
  Future<void> _sendAlarmToCloud(
      String tip,
      SensorEvent? event,
      String userMessage,
      ) async {
    final authState = ref.read(authStateProvider);
    final userId = authState.maybeWhen(authenticated: (id) => id.toString(), orElse: () => '');

    if (event == null) return;

    // 1. Găsește modelul de alarmă după tip
    AlarmModel? foundModel;
    try {
      foundModel = _alarme.firstWhere((a) => a.tipAlarma == tip);
    } catch (_) {
      return;
    }

    // 2. Apelează usecase-ul de trimitere alarmă (care se ocupă de tot)
    await ref.read(sendAlarmUseCaseProvider).call(
      userId: userId,
      event: event,
      ecg: _ecgBuffer.map((f) => f.y).toList(),
      alarm: foundModel,
      tipAlarma: tip,
      userMessage: userMessage,
    );
  }

  @override
  void dispose() {
    _alarmTimer?.cancel();
    _accelService.stop();
    super.dispose();
  }
}

// Painter de fundal cu puncte subtile
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