import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nexasafety/core/services/auth_service.dart';
import 'package:nexasafety/core/services/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // breve pausa para splash
    await Future.delayed(const Duration(milliseconds: 600));
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('seen_onboarding') ?? false;

    if (!mounted) return;

    if (!seen) {
      Navigator.of(context).pushReplacementNamed('/onboarding');
      return;
    }

    // Se já viu onboarding, tenta autenticação
    try {
      final token = await ApiClient().getToken();
      if (token == null || token.isEmpty) {
        Navigator.of(context).pushReplacementNamed('/login');
        return;
      }

      // Valida token
      await AuthService().me();
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield, size: 72, color: color),
            const SizedBox(height: 16),
            const Text(
              'NexaSafety',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.6),
            ),
          ],
        ),
      ),
    );
  }
}
