// 📂 lib/presentation/screen/calendar_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../state/recommendation_provider.dart';
import '../state/auth_provider.dart';
import '../../domain/model/recommendation.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Map<String, Set<String>> _checkedPerDay = {};
  static const String _prefsKey = 'checkedRecsPerDay';

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadCheckedFromPrefs();
  }

  Future<void> _saveCheckedToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(_checkedPerDay.map((key, value) => MapEntry(key, value.toList())));
    await prefs.setString(_prefsKey, jsonString);
  }

  Future<void> _loadCheckedFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prefsKey);
    if (jsonString != null) {
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      setState(() {
        _checkedPerDay.clear();
        decoded.forEach((key, value) {
          _checkedPerDay[key] = Set<String>.from(value);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final userId = authState.maybeWhen(
      authenticated: (id) => id.toString(),
      orElse: () => null,
    );

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Nu sunteți autentificat.')),
      );
    }

    final recsAsync = ref.watch(recommendationProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activități zilnice'),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
      ),
      backgroundColor: Colors.blue.shade50,
      body: recsAsync.when(
        data: (recs) {
          final todayKey = _selectedDay != null
              ? _selectedDay!.toIso8601String().split('T').first
              : '';

          final checkedCount = _checkedPerDay[todayKey]?.length ?? 0;
          final totalCount = recs.length;
          final progress = totalCount > 0 ? checkedCount / totalCount : 0.0;

          return Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selected, focused) {
                  setState(() {
                    _selectedDay = selected;
                    _focusedDay = focused;
                  });
                },
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.deepOrange,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: recs.length,
                  itemBuilder: (context, index) {
                    final r = recs[index];
                    final isChecked = _checkedPerDay[todayKey]?.contains(r.TipRecomandare) ?? false;

                    return Card(
                      elevation: 8,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
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
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    r.TipRecomandare,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade800,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    r.AlteIndicatii ?? '',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.blueGrey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Checkbox(
                              value: isChecked,
                              activeColor: Colors.blue,
                              onChanged: (value) {
                                setState(() {
                                  final set = _checkedPerDay.putIfAbsent(todayKey, () => {});
                                  if (value == true) {
                                    set.add(r.TipRecomandare);
                                  } else {
                                    set.remove(r.TipRecomandare);
                                  }
                                });
                                _saveCheckedToPrefs();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Eroare: $err')),
      ),
    );
  }
}