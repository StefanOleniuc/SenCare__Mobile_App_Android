// lib/presentation/screen/recommendation_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/model/recommendation.dart';
import '../state/recommendation_provider.dart';

class RecommendationScreen extends ConsumerWidget {
  final String patientId;

  const RecommendationScreen({
    Key? key,
    required this.patientId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recsAsync = ref.watch(recommendationProvider(patientId));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        title: const Text('Recomandări'),
      ),
      body: recsAsync.when(
        data: (recs) {
          if (recs.isEmpty) {
            return const Center(
              child: Text(
                'Nu există recomandări pentru moment.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: recs.length,
            itemBuilder: (context, index) {
              final r = recs[index];
              return RecommendationCard(rec: r);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text(
            'Eroare la încărcarea recomandărilor:\n$err',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}

/// Un card stilizat care afișează datele unei recomandări
class RecommendationCard extends StatelessWidget {
  final Recommendation rec;

  const RecommendationCard({Key? key, required this.rec}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dacă aveți nevoie să afișați un format de dată, îl puteți converti aici:
    // (Presupunând că rec.createdAt e de tip DateTime. Dacă nu, omiteți)
    // final dateText = DateFormat('yyyy-MM-dd – kk:mm').format(rec.createdAt);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ----- Titlu recomandare -----
            Text(
              rec.TipRecomandare,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),

            const SizedBox(height: 6),

            // ----- Durată zilnică -----
            Text(
              'Durata zilnică: ${rec.DurataZilnica}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 6),

            // ----- Alte indicații -----
            Text(
              'Alte indicații: ${rec.AlteIndicatii}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),

            // Dacă aveți câmp createdAt (DateTime), puteți afișa data la final:
            // const SizedBox(height: 8),
            // Text(
            //   'Creată la: $dateText',
            //   style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            // ),
          ],
        ),
      ),
    );
  }
}
