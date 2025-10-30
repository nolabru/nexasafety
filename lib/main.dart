import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'pages/home_page.dart';
import 'pages/splash_page.dart';
import 'pages/onboarding_page.dart';
import 'pages/new_occurrence_page.dart';
import 'pages/my_occurrences_page.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/occurrence_detail_page.dart';
import 'pages/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NexaSafetyApp());
}

class NexaSafetyApp extends StatelessWidget {
  const NexaSafetyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NexaSafety',
      theme: AppTheme.lightTheme,
      initialRoute: '/splash',
      routes: {
        '/splash': (_) => const SplashPage(),
        '/onboarding': (_) => const OnboardingPage(),
        '/home': (_) => const HomePage(),
        '/new': (_) => const NewOccurrencePage(),
        '/my': (_) => const MyOccurrencesPage(),
        '/login': (_) => const LoginPage(),
        '/signup': (_) => const SignupPage(),
        '/settings': (_) => const SettingsPage(),
      },
      onGenerateRoute: (settings) {
        // Handle /occurrence/:id route
        if (settings.name?.startsWith('/occurrence/') == true) {
          final occurrenceId = settings.name!.substring('/occurrence/'.length);
          return MaterialPageRoute(
            builder: (_) => OccurrenceDetailPage(occurrenceId: occurrenceId),
          );
        }
        return null;
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
