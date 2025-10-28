import 'package:flutter/material.dart';
import 'home_map_page.dart';
import 'pages/splash_page.dart';
import 'pages/onboarding_page.dart';
import 'pages/new_occurrence_page.dart';
import 'pages/my_occurrences_page.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/occurrence_detail_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NexaSafetyApp());
}

class NexaSafetyApp extends StatelessWidget {
  const NexaSafetyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NexaSafety',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (_) => const SplashPage(),
        '/onboarding': (_) => const OnboardingPage(),
        '/home': (_) => const HomeMapPage(),
        '/new': (_) => const NewOccurrencePage(),
        '/my': (_) => const MyOccurrencesPage(),
        '/login': (_) => const LoginPage(),
        '/signup': (_) => const SignupPage(),
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
