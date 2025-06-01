// lib/presentation/screen/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../state/sensor_provider.dart';
import '../state/usecase_providers.dart';
import '../state/auth_provider.dart';
import 'recommendation_screen.dart';
import 'activities_screen.dart';
import '../../domain/model/sensor_data.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final List<double> ecgData = [];
  late ChartSeriesController _chartController;

  @override
  void initState() {
    super.initState();
    // după ce widget-ul e montat, cerem permisiuni și pornim BLE
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initBleAndBatch();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _initBleAndBatch() async {
    // Solicităm permisiuni BLE + location
    final status = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    if (status[Permission.bluetoothScan] != PermissionStatus.granted ||
        status[Permission.bluetoothConnect] != PermissionStatus.granted ||
        status[Permission.locationWhenInUse] != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permisiuni BLE/locație refuzate')),
      );
      return;
    }

    // Reinițializăm (refresh) stream-ul BLE o singură dată
    ref.refresh(sensorStreamProvider);

    // Pornim batch-ul de trimitere date către cloud (use case)
    ref.read(sendBatchUseCaseProvider).start();
  }

  @override
  Widget build(BuildContext context) {
    // Preluăm userId-ul pacientului din starea de autentificare
    final authState = ref.watch(authStateProvider);
    final userId = authState.maybeWhen(
      authenticated: (id) => id,
      orElse: () => '',
    );

    // Ascultăm o singură dată stream-ul de SensorData
    final sensorAsync = ref.watch(sensorStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SenCare Dashboard'),
        backgroundColor: Colors.blue[800],
        elevation: 4,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue[800],
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
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.list_alt, color: Colors.blue),
              title: const Text('Recomandări'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RecommendationScreen(patientId: userId),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.blue),
              title: const Text('Activități planificate'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ActivitiesScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // --- Grafic EKG ---
          Container(
            height: 200,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(12),
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              primaryXAxis: NumericAxis(
                isVisible: false,
                majorGridLines: const MajorGridLines(width: 0),
              ),
              primaryYAxis: NumericAxis(
                axisLine: const AxisLine(width: 0),
                majorTickLines: const MajorTickLines(size: 0),
                labelStyle: const TextStyle(color: Colors.blue),
              ),
              series: <LineSeries<double, int>>[
                LineSeries<double, int>(
                  dataSource: ecgData,
                  xValueMapper: (_, index) => index,
                  yValueMapper: (value, _) => value,
                  color: Colors.blue,
                  width: 2.5,
                  onRendererCreated: (ChartSeriesController controller) {
                    _chartController = controller;
                    // Dacă există deja date (după hot reload), le afișăm
                    if (ecgData.isNotEmpty) {
                      controller.updateDataSource(
                        addedDataIndex: ecgData.length - 1,
                        removedDataIndex: -1,
                      );
                    }
                  },
                ),
              ],
            ),
          ),

          // --- Afișare valorile senzorului și update grafic ---
          Expanded(
            child: Center(
              child: sensorAsync.when(
                data: (SensorData data) {
                  // La fiecare pachet nou de la senzor, adăugăm în ecgData și actualizăm graficul
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      ecgData.add(data.ekg);
                      if (ecgData.length > 100) {
                        ecgData.removeAt(0);
                      }
                      if (_chartController != null) {
                        _chartController.updateDataSource(
                          addedDataIndex: ecgData.length - 1,
                          removedDataIndex: ecgData.length > 100 ? 0 : -1,
                        );
                      }
                    });
                  });

                  // Afișăm patru carduri cu valorile curente
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildSensorCard(
                        icon: Icons.favorite,
                        title: 'ECG',
                        value: '${data.ekg.toStringAsFixed(2)} mV',
                      ),
                      const SizedBox(height: 12),
                      _buildSensorCard(
                        icon: Icons.thermostat,
                        title: 'Temperatură',
                        value: '${data.temp.toStringAsFixed(1)}°C',
                      ),
                      const SizedBox(height: 12),
                      _buildSensorCard(
                        icon: Icons.water_drop,
                        title: 'Umiditate',
                        value: '${data.hum.toStringAsFixed(1)}%',
                      ),
                      const SizedBox(height: 12),
                      _buildSensorCard(
                        icon: Icons.monitor_heart,
                        title: 'Puls',
                        value: '${data.bpm} BPM',
                      ),
                    ],
                  );
                },
                loading: () => const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
                error: (Object e, _) => Text(
                  'Eroare BLE: $e',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Butonul “Trimite acum” forțează trimiterea batch-ului către cloud
          ref.read(sendBatchUseCaseProvider).sendNow();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Trimitem datele către cloud...'),
              backgroundColor: Colors.blue,
            ),
          );
        },
        backgroundColor: Colors.blue[800],
        tooltip: 'Trimite acum',
        child: const Icon(Icons.send, color: Colors.white),
      ),
    );
  }

  Widget _buildSensorCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue[700], size: 32),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
