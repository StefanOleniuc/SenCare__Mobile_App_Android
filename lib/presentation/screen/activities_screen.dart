// lib/presentation/screen/activities_screen.dart

import 'package:flutter/material.dart';

/// Ecran simplu de afișare a activităților planificate.
/// În aplicația finală, vei înlocui lista mock cu un flux/Provider care citește activitățile din Cloud.
class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: înlocuiește cu un Provider/Riverpod care citește activitățile aferente pacientului
    final List<String> mockActivities = [
      'Plimbare 30 min',
      'Exerciții respiratorii',
      'Mers pe bicicletă – 15 min',
      'Ședință de fizioterapie',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Activități planificate')),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: mockActivities.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (_, i) {
          return ListTile(
            leading: const Icon(Icons.check_circle_outline),
            title: Text(mockActivities[i]),
          );
        },
      ),
    );
  }
}
