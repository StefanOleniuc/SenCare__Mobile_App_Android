// lib/presentation/screen/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/model/login_request.dart';
import '../state/cloud_providers.dart';
import 'home_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Preluăm tema curentă pentru a folosi culori din ThemeData dacă vrem
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ======== Logo-ul ========
                Image.asset(
                  'assets/images/Logo_noback.png',
                  width: 320,
                  height: 320,
                ),
                const SizedBox(height: 16),

                // ======== Subtitlu ========
                Text(
                  'Autentifică-te în cont',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.grey.shade700,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 32),

                // ======== Câmp Username ========
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.blue.shade700),
                    prefixIcon: Icon(Icons.person, color: Colors.blue.shade700),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue.shade700),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ======== Câmp Parolă ========
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Parolă',
                    labelStyle: TextStyle(color: Colors.blue.shade700),
                    prefixIcon: Icon(Icons.lock, color: Colors.blue.shade700),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue.shade700),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ======== Afișare eroare, dacă există ========
                if (_error != null) ...[
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 12),
                ],

                // ======== Buton Login ========
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _isLoading ? null : _doLogin,
                    child: _isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'Loghează-te',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ======== Opțional: Legătură "Ai uitat parola?" ========
                // GestureDetector(
                //   onTap: () {
                //     // Aici poți deschide ecranul "Recuperare parolă"
                //   },
                //   child: Text(
                //     'Ai uitat parola?',
                //     style: TextStyle(
                //       color: Colors.blue.shade700,
                //       decoration: TextDecoration.underline,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _doLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _error = 'Completează ambele câmpuri.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final loginReq = LoginRequest(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Apelează metoda de login din repository
      final authToken = await ref.read(cloudRepositoryProvider).login(loginReq);

      // Salvează token-ul în state provider
      ref.read(authTokenProvider.notifier).state = authToken;

      // După login, redirecționează către HomeScreen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      setState(() {
        _error = 'Login eșuat: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
