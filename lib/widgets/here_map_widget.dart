import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/material.dart';

/// A thin wrapper that hosts the native HERE MapView via Platform Views.
/// - Android: expects a ViewFactory registered under viewType 'here_sdk/map_view'.
/// - iOS:     expects a ViewFactory registered under viewType 'here_sdk/map_view'.
/// - Web/others: shows an informative placeholder (no WebView is used).
///
/// After you add the HERE SDK to Android/iOS and register the factory in native code,
/// this widget will render the real HERE map on devices.
class HereMapWidget extends StatelessWidget {
  final bool showHeatmap;
  
  const HereMapWidget({
    super.key,
    this.showHeatmap = false,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return _placeholder('HERE SDK não disponível no Web.\nRode em Android/iOS.');
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // Requires a PlatformView registered by the HERE SDK Android integration.
        // Example (native): PlatformViewRegistry.registerViewFactory("here_sdk/map_view", ...)
        return const AndroidView(
          viewType: 'here_sdk/map_view',
          layoutDirection: TextDirection.ltr,
          // params can be passed using creationParams if needed
        );

      case TargetPlatform.iOS:
        // Requires a PlatformView registered by the HERE SDK iOS integration.
        // Example (native): registrar.register(<viewType>, factory: ...)
        return const UiKitView(
          viewType: 'here_sdk/map_view',
          layoutDirection: TextDirection.ltr,
        );

      // Desktop or others: placeholder
      default:
        return _placeholder('HERE SDK suportado apenas em Android/iOS.');
    }
  }

  Widget _placeholder(String message) {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ),
    );
  }
}
