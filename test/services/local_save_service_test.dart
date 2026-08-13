import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rapid_jump/game/world/world_config.dart';
import 'package:rapid_jump/services/local_save_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(WorldConfig.bestScoreChannel);
  const settingsChannel = MethodChannel(WorldConfig.settingsChannel);

  test('loads and saves best score through the platform channel', () async {
    var savedScore = 17;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
          switch (call.method) {
            case 'loadBestScore':
              return savedScore;
            case 'saveBestScore':
              final arguments = call.arguments as Map<Object?, Object?>;
              savedScore = arguments['score']! as int;
              return null;
          }

          return null;
        });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(settingsChannel, (MethodCall call) async {
          switch (call.method) {
            case 'loadSettings':
              return <String, Object?>{
                'completedChallengeSteps': 7,
                'soundEnabled': false,
                'hapticsEnabled': true,
              };
            case 'saveSettings':
              return null;
          }

          return null;
        });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(settingsChannel, null);
    });

    const service = LocalSaveService();

    final loaded = await service.load();
    expect(loaded.bestScore, 17);
    expect(loaded.completedChallengeSteps, 7);
    expect(loaded.soundEnabled, false);
    expect(loaded.hapticsEnabled, true);

    await service.saveBestScore(24);
    expect(savedScore, 24);
  });

  test('saves feedback settings through the platform channel', () async {
    var savedSound = true;
    var savedHaptics = true;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
          switch (call.method) {
            case 'loadBestScore':
              return 0;
            case 'saveBestScore':
              return null;
          }

          return null;
        });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(settingsChannel, (MethodCall call) async {
          switch (call.method) {
            case 'loadSettings':
              return <String, Object?>{
                'soundEnabled': savedSound,
                'hapticsEnabled': savedHaptics,
              };
            case 'saveSettings':
              final arguments = call.arguments as Map<Object?, Object?>;
              savedSound = arguments['soundEnabled']! as bool;
              savedHaptics = arguments['hapticsEnabled']! as bool;
              return null;
          }

          return null;
        });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(settingsChannel, null);
    });

    const service = LocalSaveService();

    await service.saveFeedbackSettings(
      soundEnabled: false,
      hapticsEnabled: false,
    );

    expect(savedSound, false);
    expect(savedHaptics, false);
  });

  test(
    'saves completed challenge progress through the settings channel',
    () async {
      var savedCompletedSteps = 0;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall call) async {
            switch (call.method) {
              case 'loadBestScore':
                return 0;
              case 'saveBestScore':
                return null;
            }

            return null;
          });
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(settingsChannel, (MethodCall call) async {
            switch (call.method) {
              case 'loadSettings':
                return <String, Object?>{
                  'completedChallengeSteps': savedCompletedSteps,
                  'soundEnabled': true,
                  'hapticsEnabled': true,
                };
              case 'saveSettings':
                final arguments = call.arguments as Map<Object?, Object?>;
                savedCompletedSteps =
                    arguments['completedChallengeSteps']! as int;
                return null;
            }

            return null;
          });
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null);
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(settingsChannel, null);
      });

      const service = LocalSaveService();

      await service.saveCompletedChallengeSteps(11);

      expect(savedCompletedSteps, 11);
    },
  );
}
