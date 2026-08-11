import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rapid_jump/game/world/world_config.dart';
import 'package:rapid_jump/services/local_save_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(WorldConfig.bestScoreChannel);

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
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    const service = LocalSaveService();

    final loaded = await service.load();
    expect(loaded.bestScore, 17);

    await service.saveBestScore(24);
    expect(savedScore, 24);
  });
}
