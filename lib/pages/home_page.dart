import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../core/theme/app_colors.dart';
import 'here_sdk_map_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isHeatmapActive = false;

  void _onBottomNavTap(int index) {
    if (index == 0) {
      Navigator.of(context).pushNamed('/new');
    } else if (index == 1) {
      Navigator.of(context).pushNamed('/my');
    } else if (index == 2) {
      setState(() {
        _isHeatmapActive = !_isHeatmapActive;
      });
    } else if (index == 3) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SettingsPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const HereSdkMapPage(),
          
          // Floating Bottom Navigation - REDESENHADO
          Positioned(
            left: 0,
            right: 0,
            bottom: 80,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                      spreadRadius: 1,
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _NavButton(
                      icon: FontAwesomeIcons.flag,
                      isActive: false,
                      onTap: () => _onBottomNavTap(0),
                    ),
                    const SizedBox(width: 8),
                    _NavButton(
                      icon: FontAwesomeIcons.list,
                      isActive: false,
                      onTap: () => _onBottomNavTap(1),
                    ),
                    const SizedBox(width: 8),
                    _NavButton(
                      icon: _isHeatmapActive 
                          ? FontAwesomeIcons.fire 
                          : FontAwesomeIcons.fireFlameSimple,
                      isActive: _isHeatmapActive,
                      onTap: () => _onBottomNavTap(2),
                    ),
                    const SizedBox(width: 8),
                    _NavButton(
                      icon: FontAwesomeIcons.gear,
                      isActive: false,
                      onTap: () => _onBottomNavTap(3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isActive 
              ? AppColors.primary.withOpacity(0.15) 
              : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 3),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Center(
          child: FaIcon(
            icon,
            size: 18,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
