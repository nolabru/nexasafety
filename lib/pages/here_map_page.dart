import 'package:flutter/material.dart';

/// Placeholder page: HERE SDK integration will replace this file.
/// Not used in current navigation.
class HereMapPage extends StatelessWidget {
  const HereMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HERE Map (placeholder)')),
      body: const Center(
        child: Text(
          'HERE SDK integration in progress.\n'
          'This page is a placeholder and is not used in navigation.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
