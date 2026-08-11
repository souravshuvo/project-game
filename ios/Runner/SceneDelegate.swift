import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  private let bestScoreKey = "cloud_courier_climb_best_score"

  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)

    guard let controller = window?.rootViewController as? FlutterViewController else {
      return
    }

    let channel = FlutterMethodChannel(
      name: "cloud_courier_climb/best_score",
      binaryMessenger: controller.binaryMessenger
    )
    channel.setMethodCallHandler { [bestScoreKey] call, result in
      switch call.method {
      case "loadBestScore":
        result(UserDefaults.standard.integer(forKey: bestScoreKey))
      case "saveBestScore":
        var score = 0
        if let arguments = call.arguments as? [String: Any] {
          if let value = arguments["score"] as? Int {
            score = value
          } else if let value = arguments["score"] as? NSNumber {
            score = value.intValue
          }
        }
        UserDefaults.standard.set(score, forKey: bestScoreKey)
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
