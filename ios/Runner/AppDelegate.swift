import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let controller = window?.rootViewController as? FlutterViewController {
      FlutterMethodChannel(
        name: "softverse/app_settings",
        binaryMessenger: controller.binaryMessenger
      ).setMethodCallHandler { call, result in
        guard call.method == "openAppSettings" else {
          result(FlutterMethodNotImplemented)
          return
        }

        guard let url = URL(string: UIApplication.openSettingsURLString) else {
          result(false)
          return
        }

        UIApplication.shared.open(url)
        result(true)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
