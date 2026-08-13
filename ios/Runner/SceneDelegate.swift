import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  private let bestScoreKey = "cloud_courier_climb_best_score"
  private let soundEnabledKey = "cloud_courier_climb_sound_enabled"
  private let hapticsEnabledKey = "cloud_courier_climb_haptics_enabled"
  private let completedChallengeStepsKey = "cloud_courier_climb_completed_challenge_steps"

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

    let settingsChannel = FlutterMethodChannel(
      name: "cloud_courier_climb/settings",
      binaryMessenger: controller.binaryMessenger
    )
    settingsChannel.setMethodCallHandler { [soundEnabledKey, hapticsEnabledKey, completedChallengeStepsKey] call, result in
      switch call.method {
      case "loadSettings":
        let defaults = UserDefaults.standard
        result([
          "soundEnabled": defaults.object(forKey: soundEnabledKey) as? Bool ?? true,
          "hapticsEnabled": defaults.object(forKey: hapticsEnabledKey) as? Bool ?? true,
          "completedChallengeSteps": defaults.integer(forKey: completedChallengeStepsKey)
        ])
      case "saveSettings":
        if let arguments = call.arguments as? [String: Any] {
          if let soundEnabled = arguments["soundEnabled"] as? Bool {
            UserDefaults.standard.set(soundEnabled, forKey: soundEnabledKey)
          }
          if let hapticsEnabled = arguments["hapticsEnabled"] as? Bool {
            UserDefaults.standard.set(hapticsEnabled, forKey: hapticsEnabledKey)
          }
          var completedSteps: Int?
          if let value = arguments["completedChallengeSteps"] as? Int {
            completedSteps = value
          } else if let value = arguments["completedChallengeSteps"] as? NSNumber {
            completedSteps = value.intValue
          }
          if let completedSteps = completedSteps {
            let savedSteps = UserDefaults.standard.integer(forKey: completedChallengeStepsKey)
            if completedSteps > savedSteps {
              UserDefaults.standard.set(completedSteps, forKey: completedChallengeStepsKey)
            }
          }
        }
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
