// lib/presentation/screen/home_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:permission_handler/permission_handler.dart';

import '../state/ble_providers.dart';
import '../state/usecase_providers.dart';
import '../state/auth_provider.dart';
import 'recommendation_screen.dart';
import 'activities_screen.dart';
import 'alerts_screen.dart';
import '../../domain/model/ble_event.dart';
import '../../domain/model/burst_data.dart';
import '../../presentation/state/cloud_providers.dart';
import 'dart:convert';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Buffer pentru ultimele puncte ECG
  final List<FlSpot> _ecgBuffer = [];
  double _currentX = 0.0;

  // Ultimele valori lento (bpm, temp, hum), actualizate prin SensorEvent
  int _latestBpm = 0;
  double _latestTemp = 0.0;
  double _latestHum = 0.0;

  bool _permisiiCerute = false; // ca să nu cerem permisiile de două ori

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initBleAndBatch();
    });
  }

  Future<void> _initBleAndBatch() async {
    if (_permisiiCerute) return;
    _permisiiCerute = true;

    // 1) Cerem permisiuni BLE + Locație
    final status = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    if (status[Permission.bluetoothScan]   != PermissionStatus.granted ||
        status[Permission.bluetoothConnect] != PermissionStatus.granted ||
        status[Permission.locationWhenInUse] != PermissionStatus.granted)
    {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            'Aplicația are nevoie de permisiuni Bluetooth și Locație '
                'pentru a citi datele de la senzor. Te rugăm să le permiți.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
      return;
    }

    // 2) Reinițializăm stream-ul BLE
    ref.refresh(bleEventStreamProvider);

    // 3) Pornim use-case-ul care trimite automat la 30 s
    ref.read(sendBatchUseCaseProvider).start();
  }

  @override
  Widget build(BuildContext context) {
    final bleAsync = ref.watch(bleEventStreamProvider);

    // Preluăm userId din AuthState (pentru navigarea la Recomandări, etc.)
    final authState = ref.watch(authStateProvider);
    final userId = authState.maybeWhen(
      authenticated: (id) => id.toString(),
      orElse: () => '',
    );

    print('[HomeScreen] ℹ La initBleAndBatch, patientId = "$userId"');

    return Scaffold(
      // Nu mai există floatingActionButton de trimitere manuală
      drawer: _buildDrawer(userId),
      body: Stack(
        children: [
          // 1) Fundal gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFe8f1f8), Color(0xFFffffff)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // 2) Blur subtil deasupra fundalului
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(color: Colors.white.withOpacity(0.2)),
          ),
          // 3) Conținutul principal
          SafeArea(
            child: Column(
              children: [
                // --- AppBar customizat ---
                _buildAppBar(),

                // --- Conținut (grafic + carduri) ---
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: bleAsync.when(
                      data: (BleEvent event) {
                        // Procesăm evenimentele BLE
                        if (event is SensorEvent) {
                          _latestBpm  = event.bpm;
                          _latestTemp = event.temp;
                          _latestHum  = event.hum;
                        } else if (event is EkgEvent) {
                          final double ekgValue = event.ekg;
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
                              // Buton de reîncercare conexiune BLE
                              Material(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                shadowColor: Colors.blue.shade100,
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      ref.refresh(bleEventStreamProvider);
                                    },
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Reîncearcă conexiunea'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue.shade700,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
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
                            'Caut dispozitiv BLE…\n(Asigură-te că ESP32 este pornit și în rază)',
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
                            const Icon(Icons.error,
                                color: Colors.redAccent, size: 48),
                            const SizedBox(height: 12),
                            Text(
                              'Ne pare rău, nu am putut obține datele de la senzor:\n\n$err',
                              textAlign: TextAlign.center,
                              style:
                              const TextStyle(color: Colors.red, fontSize: 16),
                            ),
                            const SizedBox(height: 20),
                            Material(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              shadowColor: Colors.redAccent.shade100,
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    ref.refresh(bleEventStreamProvider);
                                  },
                                  icon: const Icon(Icons.refresh,
                                      color: Colors.white),
                                  label: const Text('Reîncearcă'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
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

  /// AppBar personalizat (fără buton de trimitere manuală)
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.blue[800],
      elevation: 4,
      title: const Text(
        'Sencare – Feel good, stay safe.',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      // Poți adăuga butoane în AppBar dacă mai vrei (ex.: logout)
    );
  }

  /// Drawer cu navigare spre Recomandări, Activități și Alerte
  Widget _buildDrawer(String userId) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 140,
            padding: const EdgeInsets.only(left: 16, bottom: 16),
            alignment: Alignment.bottomLeft,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[900]!, Colors.blue[700]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
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
            leading: const Icon(Icons.calendar_today, color: Colors.blue),
            title: const Text('Activități planificate'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ActivitiesScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.warning, color: Colors.blue),
            title: const Text('Alerte'),
            /*onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AlertsScreen()),
              );
            },*/
          ),
        ],
      ),
    );
  }

  /// Card pentru graficul ECG (linia roșie)
  Widget _buildEcgChartCard() {
    return SizedBox(
      height: 200,
      child: Card(
        elevation: 6,
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
                  ? _ecgBuffer.map((e) => e.y).reduce((a, b) => a < b ? a : b)
                  : 0,
              maxY: _ecgBuffer.isNotEmpty
                  ? _ecgBuffer.map((e) => e.y).reduce((a, b) => a > b ? a : b)
                  : 1,
            ),
          ),
        ),
      ),
    );
  }

  /// Card pentru fiecare valoare lento (Puls, Temperatură, Umiditate)
  Widget _buildSensorCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 6,
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