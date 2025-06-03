import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'presentation/screen/login_screen.dart';
import 'presentation/screen/home_screen.dart';
import 'presentation/state/auth_provider.dart'; // <— importă provider-ul corect

void main() {
  runApp(const ProviderScope(child: SenCareApp()));
}

class SenCareApp extends ConsumerWidget {
  const SenCareApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Aici obținem starea de autentificare
    final authState = ref.watch(authStateProvider);

    // Dacă nu e autentificat, mergi la Login. Altfel la Home.
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SenCare',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: authState.maybeWhen(
        authenticated: (id) => const HomeScreen(),
        orElse: () => const LoginScreen(),
      ),
    );
  }
}
