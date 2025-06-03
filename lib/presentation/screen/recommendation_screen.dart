import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/recommendation_provider.dart';
import '../state/auth_provider.dart';
import '../../domain/model/recommendation.dart';

class RecommendationScreen extends ConsumerWidget {
  final String userId;
  const RecommendationScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final userId = authState.maybeWhen(
      authenticated: (userId) => userId,
      orElse: () => null,
    );

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Nu sunteți autentificat.')),
      );
    }

    final recsAsync = ref.watch(recommendationProvider(userId.toString()));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        title: const Text('Recomandări'),
        elevation: 0,
      ),
      backgroundColor: Colors.blue.shade50,
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
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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

class RecommendationCard extends StatelessWidget {
  final Recommendation rec;

  const RecommendationCard({Key? key, required this.rec}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      shadowColor: Colors.blue.shade200,
      color: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              rec.TipRecomandare,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.timer, color: Colors.blue.shade400, size: 20),
                const SizedBox(width: 6),
                Text(
                  'Durata zilnică: ${rec.DurataZilnica ?? "N/A"}',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.blueGrey.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade400, size: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Alte indicații: ${rec.AlteIndicatii ?? "N/A"}',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.blueGrey.shade700,
                    ),
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