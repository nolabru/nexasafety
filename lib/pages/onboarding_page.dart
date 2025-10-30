import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/onboarding_slide.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _slides = [
    {
      'icon': FontAwesomeIcons.camera,
      'title': 'Denuncie de forma anônima',
      'description': 'Registre ocorrências com ou sem identificação',
    },
    {
      'icon': FontAwesomeIcons.locationDot,
      'title': 'Torne sua cidade mais segura',
      'description': 'Registre e visualize ocorrências em tempo real na sua região.',
    },
    {
      'icon': FontAwesomeIcons.bell,
      'title': 'Receba alertas sobre sua região',
      'description': 'Fique informado sobre o que acontece perto de você',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Mark onboarding as completed
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFirstTime', false);
      
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  void _onSkip() async {
    // Mark onboarding as completed
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);
    
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
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
      body: Stack(
        children: [
          // PageView with slides
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _slides.length,
            itemBuilder: (context, index) {
              final slide = _slides[index];
              return OnboardingSlide(
                icon: slide['icon'],
                title: slide['title'],
                description: slide['description'],
              );
            },
          ),
          
          // Skip button
          if (_currentPage < _slides.length - 1)
            Positioned(
              top: 48,
              right: 24,
              child: TextButton(
                onPressed: _onSkip,
                child: Text(
                  'Pular',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          
          // Bottom section with indicators and button
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                32,
                32,
                32,
                32 + MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Colors.white
                              : Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Continue/Start button
                  CustomButton(
                    text: _currentPage == _slides.length - 1
                        ? 'Iniciar'
                        : 'Continuar',
                    onPressed: _onContinue,
                    backgroundColor: Colors.white,
                    textColor: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
