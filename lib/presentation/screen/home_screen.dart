// lib/presentation/screen/home_screen.dart

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
import '../state/send_alarm_usecase_provider.dart';
import '../../domain/model/ble_event.dart';
import '../../domain/model/normal_values.dart';
import '../../domain/model/alarm_model.dart';
import 'recommendation_screen.dart';
import 'calendar_activitati_screen.dart';

/// HomeScreen împărțit în mai multe părți pentru a minimiza rebuild‐urile.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // ************ ACCELEROMETRU ************
  late AccelerometerService _accelService;
  final List<Map<String, double>> _accelBuffer = [];
  bool _isRunning = false;

  // ************ BUFFER ECG și notifier ************
  // Vom păstra punctele ECG într-un buffer și vom notifica UI‐ul la intervale throttled.
  final List<double> _rawEcgBuffer = []; // buffer brut de dubluri (ultimele ~10s)
  late Timer _ecgThrottleTimer;
  final ValueNotifier<List<FlSpot>> ecgSpotsNotifier = ValueNotifier([]);

  // ************ STREAM SENSOR (puls, temp, hum) ************
  // Vom filtra doar evenimentele de tip SensorEvent.
  late final Stream<SensorEvent> _sensorStream;

  // ************ LOGICĂ DE ALARME ************
  List<SensorEvent> _last10sEvents = [];
  Timer? _alarmTimer;
  NormalValues? _normalValues;
  List<AlarmModel> _alarme = [];
  bool _alarmShowing = false;

  // ************ PERMISIUNI și BLE ************
  bool _permisiiCerute = false;

  @override
  void initState() {
    super.initState();

    // 1) Pornește accelerometru pentru detectare locală
    _accelService = AccelerometerService();
    _accelService.start((event) {
      _accelBuffer.add({'x': event.x, 'y': event.y, 'z': event.z});
      if (_accelBuffer.length > 30) _accelBuffer.removeAt(0);

      final magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      _isRunning = magnitude > 8.0;
    });

    // 2) Stream filtrat pentru SensorEvent (puls, temp, hum)
    //    Îl vom folosi într‐un StreamBuilder dedicat.
    _sensorStream = ref.read(bleEventStreamProvider.stream).where((evt) => evt is SensorEvent).cast<SensorEvent>();

    // 3) Pornim throttling‐ul pentru ECG
    //    Orice EkgEvent vine prin bleEventStreamProvider.stream (filtrat mai jos).
    //    Se adaugă în _rawEcgBuffer, iar timerul throttle actualizează notifier periodic.
    _ecgThrottleTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      final ecgCopy = List<double>.from(_rawEcgBuffer);
      final List<FlSpot> spots = [];
      for (var i = 0; i < ecgCopy.length; i++) {
        spots.add(FlSpot(i.toDouble(), ecgCopy[i]));
      }
      ecgSpotsNotifier.value = spots;
    });

    // 4) După primul frame, cerem permisiuni, inițiem BLE, preluăm normalValues și alarme:
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initBleAndBatch();

      final authState = ref.read(authStateProvider);
      final userId = authState.maybeWhen(
        authenticated: (id) => id.toString(),
        orElse: () => '',
      );

      if (userId.isNotEmpty) {
        // 4a) Preluăm valorile normale
        try {
          _normalValues = await ref.read(normalValuesProvider(userId).future);
          print('🟢 [HomeScreen] Valori normale încărcate: $_normalValues');
        } catch (e) {
          print('🔴 [HomeScreen] EROARE la încărcarea valorilor normale: $e');
        }
        // 4b) Preluăm lista de alarme
        try {
          _alarme = await ref.read(alarmsProvider(userId).future);
          print('🟢 [HomeScreen] Alarme încărcate: $_alarme');
        } catch (e) {
          print('🔴 [HomeScreen] EROARE la încărcarea alarmelor: $e');
        }

        // 4c) Pornim timer‐ul de verificare a alarmelor la 10 s
        _alarmTimer = Timer.periodic(const Duration(seconds: 10), (_) {
          _checkAlarms();
        });

        // 4d) Pornește SendBatchUseCase
        ref.read(sendBatchUseCaseProvider).start();
      }
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              'Aplicația are nevoie de permisiuni Bluetooth și Locație.',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }
      return;
    }

    if (!mounted) return;
    ref.refresh(bleEventStreamProvider);
  }

  @override
  Widget build(BuildContext context) {
    // 1) Observăm starea BLE (când apare eroare sau date)
    final bleState = ref.watch(bleEventStreamProvider);

    return Scaffold(
      drawer: _buildDrawer(ref.read(authStateProvider).maybeWhen(authenticated: (id) => id.toString(), orElse: () => '')),
      body: Stack(
        children: [
          // Fundal gradient + blur
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFe8f1f8), Color(0xFFffffff)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
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
                    child: bleState.when(
                      data: (event) {
                        // Orice BLE event ajunge aici: fie SensorEvent, fie EkgEvent.
                        // 2a) Dacă e SensorEvent, actualizăm doar _last10sEvents.
                        if (event is SensorEvent) {
                          _last10sEvents.add(event);
                          if (_last10sEvents.length > 5) {
                            _last10sEvents.removeAt(0);
                          }
                        }
                        // 2b) Dacă e EkgEvent, adăugăm în bufferul brut și el va fi
                        //     folosit de timerul _ecgThrottleTimer pentru a actualiza graficul.
                        else if (event is EkgEvent) {
                          _rawEcgBuffer.add(event.ekg);
                          if (_rawEcgBuffer.length > 200) {
                            _rawEcgBuffer.removeAt(0);
                          }
                        }

                        // NU reconstruim întreg HomeScreen aici, ci doar contextul bleState
                        // Afișăm sub‐widgeturile care folosesc Stream sau ValueNotifier.
                        return SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              const SizedBox(height: 12),
                              // GRAFIC ECG (ValueListenableBuilder pentru ecgSpotsNotifier)
                              SizedBox(
                                height: 200,
                                child: Card(
                                  elevation: 8,
                                  shadowColor: Colors.redAccent.withOpacity(0.4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: ValueListenableBuilder<List<FlSpot>>(
                                      valueListenable: ecgSpotsNotifier,
                                      builder: (context, spots, _) {
                                        return LineChart(
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
                                                spots: spots,
                                                isCurved: false,
                                                color: Colors.redAccent,
                                                barWidth: 2,
                                                dotData: FlDotData(show: false),
                                              ),
                                            ],
                                            minX: spots.isNotEmpty ? spots.first.x : 0,
                                            maxX: spots.isNotEmpty ? spots.last.x : 0,
                                            minY: spots.isNotEmpty
                                                ? spots.map((e) => e.y).reduce(min)
                                                : 0,
                                            maxY: spots.isNotEmpty
                                                ? spots.map((e) => e.y).reduce(max)
                                                : 1,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // CARDURILE Puls/Temperatură/Umiditate
                              // Acum le punem într‐un StreamBuilder separat ca să se
                              // reconstruiască doar când vine un SensorEvent (nu la fiecare Ekg).
                              SensorCardsWidget(sensorStream: _sensorStream),

                              const SizedBox(height: 24),
                              // În mod normal, nu mai afișăm butoane de retry aici,
                              // pentru că starea BLE e tratată separat când e eroare.
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
                            // Buton „Reîncearcă conexiunea” afișat DOAR la eroare BLE
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
                                  label: const Text(
                                    'Reîncearcă conexiunea',
                                    style: TextStyle(color: Colors.white),
                                  ),
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

  /// Verifică alarmele la 10s folosind _last10sEvents și _normalValues, _alarme
  void _checkAlarms() async {
    if (_alarmShowing) return;
    if (_normalValues == null) {
      print('🔴 [HomeScreen] Lipsesc valorile normale, nu pot verifica alarme.');
      return;
    }
    if (_last10sEvents.isEmpty) return;

    final last = _last10sEvents.last;
    _last10sEvents.clear();
    if (last.bpm == 0) return;

    final int pulsMin = _normalValues!.pulsMin;
    final int pulsMax = _normalValues!.pulsMax;
    final int pulsMaxInMiscare = pulsMax + 20;

    // --- PULS ---
    if (_isRunning) {
    if (last.bpm > pulsMaxInMiscare) {
    print('🚨 [HomeScreen] Puls ridicat în mișcare: ${last.bpm} > $pulsMaxÎnMișcare');
    await _showAlarmDialog(
    'Alarmă Puls',
    _getAlarmDescriere('Alarma Puls'),
    'Alarma Puls',
    last,
    );
    return;
    }
    } else {
    if (last.bpm < pulsMin || last.bpm > pulsMax) {
    print('🚨 [HomeScreen] Puls în afara limitelor: ${last.bpm} ($pulsMin-$pulsMax)');
    await _showAlarmDialog(
    'Alarmă Puls',
    _getAlarmDescriere('Alarma Puls'),
    'Alarma Puls',
    last,
    );
    return;
    } else if ((last.bpm - pulsMin).abs() <= 5 || (last.bpm - pulsMax).abs() <= 5) {
    print('⚠️ [HomeScreen] Puls aproape de limită: ${last.bpm}');
    await _showAlarmDialog(
    'Avertizare Puls',
    _getAlarmDescriere('Avertizare Puls'),
    'Avertizare Puls',
    last,
    );
    return;
    }
    }

    // --- TEMPERATURĂ ---
    final double tempMin = _normalValues!.temperaturaMin;
    final double tempMax = _normalValues!.temperaturaMax;
    if (last.temp < tempMin || last.temp > tempMax) {
    print('🚨 [HomeScreen] Temperatura în afara limitelor: ${last.temp} ($tempMin-$tempMax)');
    await _showAlarmDialog(
    'Alarmă Temperatura',
    _getAlarmDescriere('Alarma Temperatura'),
    'Alarma Temperatura',
    last,
    );
    return;
    } else if ((last.temp - tempMin).abs() <= 0.5 || (last.temp - tempMax).abs() <= 0.5) {
    print('⚠️ [HomeScreen] Temperatura aproape de limită: ${last.temp}');
    await _showAlarmDialog(
    'Avertizare Temperatura',
    _getAlarmDescriere('Avertizare Temperatura'),
    'Avertizare Temperatura',
    last,
    );
    return;
    }

    // --- UMIDITATE ---
    final double humMin = _normalValues!.umiditateMin;
    final double humMax = _normalValues!.umiditateMax;
    if (last.hum < humMin || last.hum > humMax) {
    print('🚨 [HomeScreen] Umiditate în afara limitelor: ${last.hum} ($humMin-$humMax)');
    await _showAlarmDialog(
    'Alarmă Umiditate',
    _getAlarmDescriere('Alarma Umiditate'),
    'Alarma Umiditate',
    last,
    );
    return;
    } else if ((last.hum - humMin).abs() <= 2 || (last.hum - humMax).abs() <= 2) {
    print('⚠️ [HomeScreen] Umiditate aproape de limită: ${last.hum}');
    await _showAlarmDialog(
    'Avertizare Umiditate',
    _getAlarmDescriere('Avertizare Umiditate'),
    'Avertizare Umiditate',
    last,
    );
    return;
    }
  }

  String _getAlarmDescriere(String tip) {
    final found = _alarme.firstWhere(
          (a) => a.tipAlarma == tip,
      orElse: () => AlarmModel(
        alarmaId: -1,
        pacientId: -1,
        tipAlarma: tip,
        descriere: '',
      ),
    );
    return found.descriere;
  }

  Future<void> _showAlarmDialog(
      String title,
      String descriere,
      String tip,
      SensorEvent event,
      ) async {
    if (!mounted) return;
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
            Text(descriere),
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
              await _sendAlarmToCloud(
                tip: tip,
                event: event,
                userMessage: userMessage,
              );
              _alarmShowing = false;
            },
            child: const Text('Trimite'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendAlarmToCloud({
    required String tip,
    required SensorEvent event,
    required String userMessage,
  }) async {
    final authState = ref.read(authStateProvider);
    final userId = authState.maybeWhen(
      authenticated: (id) => id.toString(),
      orElse: () => '',
    );
    if (userId.isEmpty) return;

    AlarmModel foundModel;
    try {
      foundModel = _alarme.firstWhere((a) => a.tipAlarma == tip);
    } catch (_) {
      foundModel = AlarmModel(
        alarmaId: -1,
        pacientId: -1,
        tipAlarma: tip,
        descriere: '',
      );
    }

    print(
        '🚀 [HomeScreen] TRIMIT ALARMĂ INSTANT: tip=$tip, '
            'bpm=${event.bpm}, temp=${event.temp}, hum=${event.hum}, '
            'UserMsg="$userMessage"'
    );

    try {
      await ref.read(sendAlarmUseCaseProvider).call(
        userId: userId,
        event: event,
        ecg: _rawEcgBuffer.length <= 200
            ? List<double>.from(_rawEcgBuffer)
            : List<double>.from(_rawEcgBuffer.sublist(_rawEcgBuffer.length - 200)),
        alarm: foundModel,
        tipAlarma: tip,
        userMessage: userMessage,
      );
      print('✅ [HomeScreen] Alarmă trimisă cu succes.');
    } catch (e) {
      print('🔴 [HomeScreen] Eroare la trimiterea alarmei: $e');
    }
  }

  @override
  void dispose() {
    _alarmTimer?.cancel();
    _ecgThrottleTimer.cancel();
    ecgSpotsNotifier.dispose();
    _accelService.stop();
    super.dispose();
  }
}

/// Widget separat care ascultă doar SensorEvent (puls, temp, hum) și afișează cardurile.
/// Astfel, nu reconstruim întreg HomeScreen când vine EkgEvent.
class SensorCardsWidget extends StatelessWidget {
  final Stream<SensorEvent> sensorStream;
  const SensorCardsWidget({Key? key, required this.sensorStream}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SensorEvent>(
      stream: sensorStream,
      builder: (context, snapshot) {
        int puls = 0;
        double temp = 0.0, hum = 0.0;

        if (snapshot.hasData) {
          puls = snapshot.data!.bpm;
          temp = snapshot.data!.temp;
          hum = snapshot.data!.hum;
        }

        return Column(
          children: [
            SensorCard(
              icon: Icons.monitor_heart,
              title: 'Puls',
              value: '$puls BPM',
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            SensorCard(
              icon: Icons.thermostat,
              title: 'Temperatură',
              value: '${temp.toStringAsFixed(1)} °C',
              color: Colors.orangeAccent,
            ),
            const SizedBox(height: 16),
            SensorCard(
              icon: Icons.water_drop,
              title: 'Umiditate',
              value: '${hum.toStringAsFixed(1)} %',
              color: Colors.lightBlueAccent,
            ),
          ],
        );
      },
    );
  }
}

/// Card simplu pentru afișarea unei metrici
class SensorCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const SensorCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
}
