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
  // -- Buffere pentru logica cerută --
  final List<SensorEvent> _sensorSnapshots = []; // ultimile 3 snapshoturi (la 10s)
  final List<double> _ecgBuffer = []; // ultimele 200 valori (10s la 50ms)
  final List<double> _accelBuffer = []; // pentru corelări locale

  SensorEvent? _lastSensorSnapshot;

  int _latestBpm = 0;
  double _latestTemp = 0;
  double _latestHum = 0;

  bool _permisiiCerute = false;
  late AccelerometerService _accelService;

  Timer? _batchTimer;
  Timer? _alarmTimer;
  bool _alarmDialogShown = false;
  String? _lastAlarmType;
  DateTime? _lastAlarmTime;

  NormalValues? _normalValues;
  List<AlarmModel> _alarme = [];

  @override
  void initState() {
    super.initState();

    _accelService = AccelerometerService();
    _accelService.start((event) {
      // Buffer accel local pentru corelare (ex: running)
      final magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      _accelBuffer.add(magnitude);
      if (_accelBuffer.length > 30) _accelBuffer.removeAt(0);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initBleAndFetchCloud();

      _alarmTimer = Timer.periodic(const Duration(seconds: 10), (_) {
        // NIMIC: alarma/avertizare se verifică la fiecare snapshot, nu la timer!
      });

      // Batch la 30s
      _batchTimer = Timer.periodic(const Duration(seconds: 30), (_) => _sendBatchToCloud());
      ref.read(sendBatchUseCaseProvider).start();
    });
  }

  Future<void> _initBleAndFetchCloud() async {
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

    // Fetch valori normale și alarme
    final authState = ref.read(authStateProvider);
    final userId = authState.maybeWhen(authenticated: (id) => id.toString(), orElse: () => '');
    if (userId.isNotEmpty) {
      try {
        _normalValues = await ref.read(normalValuesProvider(userId).future);
        debugPrint("🟢 Valorile normale preluate din cloud: $_normalValues");
      } catch (e) {
        debugPrint("🔴 Eroare la fetch valori normale: $e");
      }
      try {
        _alarme = await ref.read(alarmsProvider(userId).future);
        debugPrint("🟢 Alarme/avertizari preluate din cloud: $_alarme");
      } catch (e) {
        debugPrint("🔴 Eroare la fetch alarme: $e");
      }
      setState(() {});
    }
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
                          _onSensorEvent(event);
                        } else if (event is EkgEvent) {
                          _onEkgEvent(event);
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
                                value: '${_latestBpm} BPM',
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
    // Pentru UI: doar 200 de valori, ca înainte
    List<FlSpot> flspots = [];
    for (int i = 0; i < _ecgBuffer.length; i++) {
      flspots.add(FlSpot(i.toDouble(), _ecgBuffer[i]));
    }
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
                  spots: flspots,
                  isCurved: false,
                  color: Colors.redAccent,
                  barWidth: 2,
                  dotData: FlDotData(show: false),
                ),
              ],
              minX: flspots.isNotEmpty ? flspots.first.x : 0,
              maxX: flspots.isNotEmpty ? flspots.last.x : 0,
              minY: flspots.isNotEmpty
                  ? flspots.map((e) => e.y).reduce(min)
                  : 0,
              maxY: flspots.isNotEmpty
                  ? flspots.map((e) => e.y).reduce(max)
                  : 1,
            ),
          ),
        ),
      ),
    );
  }

  // ==== Buffer update la fiecare eveniment nou ====
  void _onSensorEvent(SensorEvent event) {
    _latestBpm = event.bpm;
    _latestTemp = event.temp;
    _latestHum = event.hum;

    _sensorSnapshots.add(event);
    if (_sensorSnapshots.length > 3) _sensorSnapshots.removeAt(0);

    _lastSensorSnapshot = event;

    _checkAlarmOrWarning(event);
  }

  void _onEkgEvent(EkgEvent event) {
    _ecgBuffer.add(event.ekg);
    if (_ecgBuffer.length > 200) _ecgBuffer.removeAt(0);
  }

  // ========== BATCH CLOUD ==========
  Future<void> _sendBatchToCloud() async {
    if (_sensorSnapshots.length < 3) return;

    final mediaPuls = _sensorSnapshots.map((e) => e.bpm).reduce((a, b) => a + b) / 3;
    final mediaTemp = _sensorSnapshots.map((e) => e.temp).reduce((a, b) => a + b) / 3;
    final mediaUmid = _sensorSnapshots.map((e) => e.hum).reduce((a, b) => a + b) / 3;
    final ecgBurst = List<double>.from(_ecgBuffer);

    final authState = ref.read(authStateProvider);
    final userId = authState.maybeWhen(authenticated: (id) => id.toString(), orElse: () => '');

    final data = {
      'userId': userId,
      'puls': mediaPuls,
      'temperatura': mediaTemp,
      'umiditate': mediaUmid,
      'ecgBurst': ecgBurst,
      'data_timp': DateTime.now().toIso8601String(),
    };
    try {
      debugPrint("🐞 [BATCH] 📤 Trimit batch la 30s: $data");
      await Dio().post('https://sencareapp-backend.azurewebsites.net/api/mobile/datefiziologice', data: data);
      debugPrint("🐞 [BATCH] ✅ Batch trimis!");
    } catch (e) {
      debugPrint("🐞 [BATCH] ❌ Eroare batch: $e");
    }
  }

  // ========== ALARMĂ/AVERTIZARE ==========
  void _checkAlarmOrWarning(SensorEvent event) async {
    if (_normalValues == null || _alarmDialogShown) return;

    final act = _analyzeEvent(event, _normalValues!, _accelBuffer);
    if (act == null) return;

    final now = DateTime.now();
    if (_lastAlarmType == act && _lastAlarmTime != null && now.difference(_lastAlarmTime!) < const Duration(seconds: 60)) {
      return;
    }
    _lastAlarmType = act;
    _lastAlarmTime = now;
    _alarmDialogShown = true;

    await _sendInstantToCloud(event, List<double>.from(_ecgBuffer));

    final tipAlarm = act;
    final foundAlarm = _alarme.firstWhere(
          (a) => a.tipAlarma == tipAlarm,
      orElse: () => AlarmModel(
        alarmaId: -1,
        pacientId: -1,
        tipAlarma: tipAlarm,
        descriere: "⚠️ Fără descriere!",
      ),
    );
    await _showAlarmDialog(
      tipAlarm,
      foundAlarm.descriere,
      foundAlarm,
      event,
    );
    _alarmDialogShown = false;
  }

  String? _analyzeEvent(SensorEvent event, NormalValues normal, List<double> accelBuffer) {
    bool running = _isRunning(accelBuffer);

    int pmin = normal.pulsMin;
    int pmax = running ? normal.pulsMax + 20 : normal.pulsMax;
    if (event.bpm < pmin || event.bpm > pmax) return 'Alarma Puls';
    if ((event.bpm - pmin).abs() <= 5 || (event.bpm - pmax).abs() <= 5) return 'Avertizare Puls';

    double tmin = normal.temperaturaMin;
    double tmax = normal.temperaturaMax;
    if (event.temp < tmin || event.temp > tmax) return 'Alarma Temperatura';
    if ((event.temp - tmin).abs() <= 0.5 || (event.temp - tmax).abs() <= 0.5) return 'Avertizare Temperatura';

    double umin = normal.umiditateMin;
    double umax = normal.umiditateMax;
    if (event.hum < umin || event.hum > umax) return 'Alarma Umiditate';
    if ((event.hum - umin).abs() <= 2 || (event.hum - umax).abs() <= 2) return 'Avertizare Umiditate';

    return null;
  }

  bool _isRunning(List<double> accelBuffer) {
    if (accelBuffer.isEmpty) return false;
    final mean = accelBuffer.reduce((a, b) => a + b) / accelBuffer.length;
    return mean > 8.0;
  }

  Future<void> _sendInstantToCloud(SensorEvent event, List<double> ecgBurst) async {
    final authState = ref.read(authStateProvider);
    final userId = authState.maybeWhen(authenticated: (id) => id.toString(), orElse: () => '');

    final data = {
      'userId': userId,
      'puls': event.bpm,
      'temperatura': event.temp,
      'umiditate': event.hum,
      'ecgBurst': ecgBurst,
      'data_timp': DateTime.now().toIso8601String(),
    };
    try {
      debugPrint("🐞 [INSTANT] 📤 Trimit date instant la alarmă: $data");
      await Dio().post('https://sencareapp-backend.azurewebsites.net/api/mobile/datefiziologice', data: data);
      debugPrint("🐞 [INSTANT] ✅ Date instant trimise!");
    } catch (e) {
      debugPrint("🐞 [INSTANT] ❌ Eroare la trimiterea datelor instant: $e");
    }
  }

  Future<void> _showAlarmDialog(
      String tipAlarm, String descriere, AlarmModel alarm, SensorEvent event) async {
    String userMessage = '';
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("🚨 $tipAlarm"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("📝 $descriere"),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Notează un mesaj suplimentar (opțional)',
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
              await _sendAlarmToCloud(tipAlarm, alarm, event, userMessage);
            },
            child: const Text('Trimite'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendAlarmToCloud(
      String tipAlarm, AlarmModel alarm, SensorEvent event, String userMessage) async {
    final authState = ref.read(authStateProvider);
    final userId = authState.maybeWhen(authenticated: (id) => id.toString(), orElse: () => '');

    final dataIstoric = {
      'userId': userId,
      'alarmaId': alarm.alarmaId,
      'tipAlarma': tipAlarm,
      'descriere': "${alarm.descriere}${userMessage.isNotEmpty ? '\n[Utilizator]: $userMessage' : ''}",
      'actiune': 'confirmata_de_utilizator',
      'data_timp': DateTime.now().toIso8601String(),
    };
    try {
      debugPrint("🐞 [ISTORIC] 📤 Trimit istoric alarmă: $dataIstoric");
      await Dio().post('https://sencareapp-backend.azurewebsites.net/api/mobile/istoric-alarme', data: dataIstoric);
      debugPrint("🐞 [ISTORIC] ✅ Istoric alarmă trimis!");
    } catch (e) {
      debugPrint("🐞 [ISTORIC] ❌ Eroare la trimiterea în istoric alarme: $e");
    }
  }

  @override
  void dispose() {
    _batchTimer?.cancel();
    _alarmTimer?.cancel();
    _accelService.stop();
    super.dispose();
  }
}

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