import 'package:flutter/material.dart';

import 'app/kids_land_app.dart';
import 'core/audio/letter_audio_cue.dart';
import 'features/tracing/data/hive_progress_repository.dart';
import 'features/tracing/data/progress_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final progressRepository = await _openProgressRepository();

  runApp(
    KidsLandApp(
      progressRepository: progressRepository,
      audioCue: SystemLetterAudioCue(
        isEnabled: () => progressRepository.soundEnabled,
      ),
    ),
  );
}

Future<ProgressRepository> _openProgressRepository() async {
  try {
    return await HiveProgressRepository.open();
  } on Object {
    // Local-storage failure must not lock a young child out of the activity.
    // This process-only fallback intentionally collects and transmits nothing.
    return MemoryProgressRepository();
  }
}
