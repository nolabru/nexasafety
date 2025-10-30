import Flutter
import UIKit
import heresdk

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Initialize HERE SDK Native Engine once for the app lifecycle.
    if let info = Bundle.main.infoDictionary,
       let accessKeyId = info["HEREAccessKeyId"] as? String,
       let accessKeySecret = info["HEREAccessKeySecret"] as? String {
      // New API (4.24+): initialize via authenticationMode
      // Use HERE SDK 4.24 AuthenticationMode factory: withKeySecret(accessKeyId:..., accessKeySecret:...)
      let authMode = AuthenticationMode.withKeySecret(
        accessKeyId: accessKeyId,
        accessKeySecret: accessKeySecret
      )
      let options = SDKOptions(authenticationMode: authMode)
      do {
        try SDKNativeEngine.makeSharedInstance(options: options)
      } catch {
        fatalError("HERE SDK initialization failed: \\(error)")
      }
    } else {
      fatalError("HEREAccessKeyId / HEREAccessKeySecret not found in Info.plist")
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
