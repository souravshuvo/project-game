class ChallengeStep {
  const ChallengeStep({
    required this.number,
    required this.title,
    required this.description,
    this.scoreTarget = 0,
    this.landingTarget = 0,
    this.pickupTarget = 0,
  });

  final int number;
  final String title;
  final String description;
  final int scoreTarget;
  final int landingTarget;
  final int pickupTarget;

  String get routeLabel => 'Route $number';

  String get goalLabel {
    final goals = <String>[];
    if (scoreTarget > 0) {
      goals.add('score $scoreTarget');
    }
    if (landingTarget > 0) {
      goals.add('land $landingTarget pads');
    }
    if (pickupTarget > 0) {
      goals.add('collect $pickupTarget signals');
    }

    return goals.join(' + ');
  }

  bool isComplete({
    required int score,
    required int landings,
    required int pickups,
  }) {
    return score >= scoreTarget &&
        landings >= landingTarget &&
        pickups >= pickupTarget;
  }

  String progressLabel({
    required int score,
    required int landings,
    required int pickups,
    required bool completed,
  }) {
    if (completed) {
      return 'Complete';
    }

    final progress = <String>[];
    if (scoreTarget > 0) {
      progress.add('${score.clamp(0, scoreTarget)}/$scoreTarget score');
    }
    if (landingTarget > 0) {
      progress.add('${landings.clamp(0, landingTarget)}/$landingTarget pads');
    }
    if (pickupTarget > 0) {
      progress.add('${pickups.clamp(0, pickupTarget)}/$pickupTarget signals');
    }

    return progress.join(' | ');
  }
}
