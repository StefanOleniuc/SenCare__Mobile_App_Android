/*
/// lib/presentation/screen/alerts_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/alerts_provider.dart'; // presupunem că există un provider pentru alerte

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(alertsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Alerte')),
      body: alertsAsync.when(
        data: (alertsList) {
          if (alertsList.isEmpty) {
            return const Center(child: Text('Nu există alerte active.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: alertsList.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (_, i) {
              final alert = alertsList[i];
              return ListTile(
                leading: const Icon(Icons.warning, color: Colors.redAccent),
                title: Text(alert.title),
                subtitle: Text(alert.timestamp.toLocal().toString()),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Eroare la încărcare: $e')),
      ),
    );
  }
}*/
