import 'level_definition.dart';

class PulseGameSnapshot {
  const PulseGameSnapshot({
    required this.sparkCount,
    required this.polarity,
    required this.status,
    required this.progress,
    required this.message,
    required this.deliveredCharge,
    required this.requiredCharge,
  });

  factory PulseGameSnapshot.initial(PulseParadeLevel level) {
    return PulseGameSnapshot(
      sparkCount: level.startingSparkCount,
      polarity: level.startingPolarity,
      status: PulseLevelStatus.ready,
      progress: 0,
      message: 'Guide the spark stream',
      deliveredCharge: 0,
      requiredCharge: level.powerNode.chargeRequired,
    );
  }

  final int sparkCount;
  final PulsePolarity polarity;
  final PulseLevelStatus status;
  final double progress;
  final String message;
  final int deliveredCharge;
  final int requiredCharge;

  bool get isFinished {
    return switch (status) {
      PulseLevelStatus.won ||
      PulseLevelStatus.failedDepleted ||
      PulseLevelStatus.failedUndercharged => true,
      PulseLevelStatus.ready || PulseLevelStatus.running => false,
    };
  }

  PulseGameSnapshot copyWith({
    int? sparkCount,
    PulsePolarity? polarity,
    PulseLevelStatus? status,
    double? progress,
    String? message,
    int? deliveredCharge,
    int? requiredCharge,
  }) {
    return PulseGameSnapshot(
      sparkCount: sparkCount ?? this.sparkCount,
      polarity: polarity ?? this.polarity,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      message: message ?? this.message,
      deliveredCharge: deliveredCharge ?? this.deliveredCharge,
      requiredCharge: requiredCharge ?? this.requiredCharge,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PulseGameSnapshot &&
        other.sparkCount == sparkCount &&
        other.polarity == polarity &&
        other.status == status &&
        other.progress == progress &&
        other.message == message &&
        other.deliveredCharge == deliveredCharge &&
        other.requiredCharge == requiredCharge;
  }

  @override
  int get hashCode {
    return Object.hash(
      sparkCount,
      polarity,
      status,
      progress,
      message,
      deliveredCharge,
      requiredCharge,
    );
  }
}
