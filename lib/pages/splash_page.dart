import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/custom_button.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getString('auth_token') != null;

    // Wait a bit to show splash screen
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (isLoggedIn) {
      // User is logged in, go directly to home
      Navigator.of(context).pushReplacementNamed('/home');
    }
    // If not logged in, stay on splash and show continue button
  }

  Future<void> _onContinue() async {
    Navigator.of(context).pushReplacementNamed('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    // Set status bar to white
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.primary,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Map illustration
                Image.asset(
                  'assets/location.png',
                  width: 280,
                  height: 280,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.map_outlined,
                        size: 120,
                        color: Colors.white,
                      ),
                    );
                  },
                ),

                const SizedBox(height: 48),

                // Logo/Title
                Text(
                  'Nexasafety',
                  style: AppTextStyles.displayLarge.copyWith(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 16),

                // Description
                Text(
                  'A segurança começa com informação.\nDenuncie, acompanhe e receba alertas com\no Nexasafety, a rede que protege você e sua\ncidade.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),

                const Spacer(flex: 3),

                // Continue button
                CustomButton(
                  text: 'Continuar',
                  onPressed: _onContinue,
                  backgroundColor: Colors.white,
                  textColor: AppColors.primary,
                ),

                const SizedBox(height: 32),
                // Bottom safe area padding
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
