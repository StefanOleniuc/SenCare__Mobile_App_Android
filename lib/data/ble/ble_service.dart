// lib/data/ble/ble_service.dart

import 'dart:async';
import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../domain/model/ble_event.dart';

class BleService {
  // UUID‐urile ESP32 (în litere mici, pentru consistență)
  static const String SERVICE_UUID = "6e400001-b5a3-f393-e0a9-e50e24dcca9e";
  static const String CHAR_UUID    = "6e400003-b5a3-f393-e0a9-e50e24dcca9e";

  // Controller prin care vom emite BleEvent (SensorEvent & EkgEvent)
  final StreamController<BleEvent> _controller =
  StreamController<BleEvent>.broadcast();
  Stream<BleEvent> get bleEventStream => _controller.stream;

  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _notifyCharacteristic;

  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<List<int>>? _notificationSubscription;

  /// 1) Cere permisiunile BLE + Location și apoi pornește scanarea.
  Future<void> initAndStart() async {
    print('[BleService] ① Cerere permisiuni BLE + Locație...');
    final scanStatus     = await Permission.bluetoothScan.request();
    final connectStatus  = await Permission.bluetoothConnect.request();
    final locationStatus = await Permission.locationWhenInUse.request();

    if (scanStatus != PermissionStatus.granted ||
        connectStatus != PermissionStatus.granted ||
        locationStatus != PermissionStatus.granted) {
      print('[BleService] ❌ Permisiuni refuzate!');
      throw Exception("Permisiuni BLE/locație refuzate");
    }

    print('[BleService] ✅ Permisiuni OK. Pornim scanarea pe 5s...');
    _startScan();
  }

  /// 2) Pornește scanarea fără niciun filtru (timeout 5s).
  void _startScan() {
    _scanSubscription?.cancel();

    print('[BleService] ② startScan (fără filtre) pentru 5s');
    // Apel static la flutter_blue_plus
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    print('[BleService] Ascultăm scanResults (fără filtre)...');
    _scanSubscription =
        FlutterBluePlus.scanResults.listen((List<ScanResult> results) async {
          print('[BleService] 📶 scanResults: găsite ${results.length} device-uri');
          for (var result in results) {
            final device = result.device;
            final name = device.name.isNotEmpty ? device.name : '<no-name>';
            print('[BleService]   → Device: name="$name", id=${device.id}');

            // Dacă găsim ESP32_BLE_JSON în advertising → oprim scanarea și ne conectăm
            if (name == 'ESP32_BLE_JSON') {
              print(
                  '[BleService] 🚀 Găsit ESP32 în advertising (name="$name"). Oprire scan și conectare.');
              await FlutterBluePlus.stopScan();
              await _scanSubscription?.cancel();
              await _connectToDevice(device);
              return;
            }
          }
        }, onDone: () {
          print(
              '[BleService] 🛑 Scanare încheiată (5s) fără filtru, fără să găsim ESP32');
          if (_connectedDevice == null) {
            _controller.addError("Nu am găsit ESP32 în 5s (fără filtre).");
          }
        }, onError: (e) {
          print('[BleService] ❌ Eroare la scanResults: $e');
          _controller.addError("Eroare la scan BLE: $e");
        });
  }

  /// ③ Conectare la device‐ul găsit.
  Future<void> _connectToDevice(BluetoothDevice device) async {
    print(
        '[BleService] ③ Conectez la dispozitiv: name="${device.name}", id=${device.id} …');
    try {
      await device.connect(timeout: const Duration(seconds: 10));
      _connectedDevice = device;
      print('[BleService] 🔗 Conectare OK. Descoperim servicii…');
      await _discoverServices(device);
    } catch (e) {
      print('[BleService] ❌ Eroare la conectare: $e');
      _controller.addError("Nu s-a putut conecta: $e");
    }
  }

  /// ④ Descoperire servicii și caracteristică.
  Future<void> _discoverServices(BluetoothDevice device) async {
    print('[BleService] ④ Descoperire servicii pe "${device.name}" …');
    try {
      final services = await device.discoverServices();
      for (var svc in services) {
        print('[BleService]   → Service: ${svc.uuid.toString().toLowerCase()}');
        if (svc.uuid.toString().toLowerCase() == SERVICE_UUID) {
          print('[BleService]     … Găsit SERVICE_UUID=$SERVICE_UUID');
          for (var char in svc.characteristics) {
            print(
                '[BleService]       → Caracteristică: ${char.uuid.toString().toLowerCase()} (notify?=${char.properties.notify})');
            if (char.uuid.toString().toLowerCase() == CHAR_UUID) {
              print('[BleService]         … Găsit CHAR_UUID=$CHAR_UUID');
              _notifyCharacteristic = char;
              await _subscribeToCharacteristic(char);
              return;
            }
          }
        }
      }
      print('[BleService] ❌ Nu am găsit characteristic-ul $CHAR_UUID');
      _controller.addError("Characteristic $CHAR_UUID nu a fost găsit.");
    } catch (e) {
      print('[BleService] ❌ Eroare la discoverServices: $e');
      _controller.addError("Eroare la discoverServices: $e");
    }
  }

  /// ⑤ Subscriere la notificări și parsing JSON → BleEvent.
  Future<void> _subscribeToCharacteristic(
      BluetoothCharacteristic char) async {
    if (!char.properties.notify) {
      print(
          '[BleService] ❌ Characteristic $CHAR_UUID nu suportă notificări.');
      _controller.addError(
          "Characteristic $CHAR_UUID nu suportă notificări.");
      return;
    }
    try {
      print('[BleService] ⑤ Activăm notify pe caracteristică $CHAR_UUID …');
      await char.setNotifyValue(true);

      print('[BleService] Ascult transmisiunile de bytes…');
      // Folosim char.lastValueStream pentru a asculta noile date
      _notificationSubscription = char.lastValueStream.listen(
            (List<int> rawBytes) {
          // 1) Transform raw bytes în String
          final jsonString = utf8.decode(rawBytes).trim();
          print('[BleService]   🔄 Received raw bytes → JSON: $jsonString');

          // 2) Dacă mesajul nu începe cu '{', ignorăm (ex: "!")
          if (!jsonString.startsWith('{')) {
            print('[BleService]   ⚠ Ignor non-JSON: $jsonString');
            return;
          }

          // 3) Încercăm să decodăm JSON-ul
          try {
            final Map<String, dynamic> m = json.decode(jsonString);

            // 4) Dacă e {bpm, temp, hum} → SensorEvent
            if (m.containsKey('bpm') &&
                m.containsKey('temp') &&
                m.containsKey('hum')) {
              final rawBpm  = m['bpm'];
              final rawTemp = m['temp'];
              final rawHum  = m['hum'];

              final int bpmValue = rawBpm is int
                  ? rawBpm
                  : (rawBpm is String ? int.tryParse(rawBpm) ?? 0 : 0);
              final double tempValue = rawTemp is num
                  ? rawTemp.toDouble()
                  : (rawTemp is String ? double.tryParse(rawTemp) ?? 0.0 : 0.0);
              final double humValue = rawHum is num
                  ? rawHum.toDouble()
                  : (rawHum is String ? double.tryParse(rawHum) ?? 0.0 : 0.0);

              final sensorEvent = BleEvent.sensor(
                bpm: bpmValue,
                temp: tempValue,
                hum: humValue,
              );
              print('[BleService]   → Emitem SensorEvent: $sensorEvent');
              _controller.add(sensorEvent);
            }
            // 5) Dacă e {ekg} → EkgEvent
            else if (m.containsKey('ekg')) {
              final rawEkg = m['ekg'];
              final double ekgValue = rawEkg is num
                  ? rawEkg.toDouble()
                  : (rawEkg is String ? double.tryParse(rawEkg) ?? 0.0 : 0.0);

              final ekgEvent = BleEvent.ekg(ekg: ekgValue);
              print('[BleService]   → Emitem EkgEvent: $ekgEvent');
              _controller.add(ekgEvent);
            }
            // 6) Altfel, JSON cu câmpuri necunoscute → ignorăm/logăm
            else {
              print('[BleService]   ⚠ JSON necunoscut: $m');
            }
          } catch (e) {
            // 7) Dacă json.decode aruncă eroare, doar logăm și nu blocăm stream-ul
            print('[BleService] ❌ Parsing JSON BLE: $e');
            // Nu apelăm _controller.addError aici, doar continuăm
          }
        },
        onError: (e) {
          print('[BleService] ❌ Eroare la notifications: $e');
          _controller.addError("Eroare notificări BLE: $e");
        },
      );

      print('[BleService] 🛰 Subscriere finalizată – așteptăm datele …');
    } catch (e) {
      print('[BleService] ❌ Nu s-a putut activa notify: $e');
      _controller.addError("Nu s-a putut activa notify: $e");
    }
  }

  /// ⑥ Dispose: curățăm toate subscripțiile și deconectăm device-ul.
  Future<void> dispose() async {
    print('[BleService] dispose(): anulăm subscripțiile și deconectăm…');
    await _scanSubscription?.cancel();
    await _notificationSubscription?.cancel();

    if (_connectedDevice != null) {
      try {
        await _connectedDevice!.disconnect();
        print('[BleService] 🔗 Device BLE deconectat.');
      } catch (_) {}
    }

    _controller.close();
    print('[BleService] ✔ BleService dispose OK.');
  }

// Restul metodelor (initAndStart, _startScan, _connectToDevice, _discoverServices)
// rămân neschimbate, așa cum erau mai sus.
}