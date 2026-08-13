import '../models/challenge_step.dart';

class ChallengeCatalog {
  const ChallengeCatalog();

  static int get totalSteps => steps.length;

  static const steps = <ChallengeStep>[
    ChallengeStep(
      number: 1,
      title: 'First Dispatch',
      description: 'Reach a tiny route marker.',
      scoreTarget: 20,
    ),
    ChallengeStep(
      number: 2,
      title: 'Pad Practice',
      description: 'Land a short chain of pads.',
      landingTarget: 3,
    ),
    ChallengeStep(
      number: 3,
      title: 'Signal Check',
      description: 'Collect your first sky signal.',
      pickupTarget: 1,
    ),
    ChallengeStep(
      number: 4,
      title: 'Low Drift',
      description: 'Keep climbing through the lower clouds.',
      scoreTarget: 45,
      landingTarget: 4,
    ),
    ChallengeStep(
      number: 5,
      title: 'Courier Rhythm',
      description: 'Chain a few clean jumps.',
      landingTarget: 6,
    ),
    ChallengeStep(
      number: 6,
      title: 'Signal Pair',
      description: 'Collect two signals in one run.',
      pickupTarget: 2,
    ),
    ChallengeStep(
      number: 7,
      title: 'Amber Route',
      description: 'Reach the first amber marker.',
      scoreTarget: 75,
    ),
    ChallengeStep(
      number: 8,
      title: 'Steady Courier',
      description: 'Land eight pads before the route ends.',
      landingTarget: 8,
    ),
    ChallengeStep(
      number: 9,
      title: 'Signal Sweep',
      description: 'Collect three signals.',
      pickupTarget: 3,
    ),
    ChallengeStep(
      number: 10,
      title: 'Spark Awareness',
      description: 'Climb past the first warning sparks.',
      scoreTarget: 95,
      landingTarget: 8,
    ),
    ChallengeStep(
      number: 11,
      title: 'Cloud Relay',
      description: 'Reach a higher cloud route.',
      scoreTarget: 120,
    ),
    ChallengeStep(
      number: 12,
      title: 'Pad Chain',
      description: 'Land ten pads in one run.',
      landingTarget: 10,
    ),
    ChallengeStep(
      number: 13,
      title: 'Signal Thread',
      description: 'Gather four route signals.',
      pickupTarget: 4,
    ),
    ChallengeStep(
      number: 14,
      title: 'High Turn',
      description: 'Score 145 while staying on route.',
      scoreTarget: 145,
      landingTarget: 10,
    ),
    ChallengeStep(
      number: 15,
      title: 'Clean Delivery',
      description: 'Collect five signals.',
      pickupTarget: 5,
    ),
    ChallengeStep(
      number: 16,
      title: 'Weather Ladder',
      description: 'Reach score 170.',
      scoreTarget: 170,
    ),
    ChallengeStep(
      number: 17,
      title: 'Courier Footwork',
      description: 'Land thirteen pads.',
      landingTarget: 13,
    ),
    ChallengeStep(
      number: 18,
      title: 'Signal Arc',
      description: 'Collect six signals.',
      pickupTarget: 6,
    ),
    ChallengeStep(
      number: 19,
      title: 'Tall Route',
      description: 'Score 200 and keep landing.',
      scoreTarget: 200,
      landingTarget: 14,
    ),
    ChallengeStep(
      number: 20,
      title: 'Northbound Mail',
      description: 'Reach score 230.',
      scoreTarget: 230,
    ),
    ChallengeStep(
      number: 21,
      title: 'Signal Courier',
      description: 'Collect seven signals.',
      pickupTarget: 7,
    ),
    ChallengeStep(
      number: 22,
      title: 'Pad Survey',
      description: 'Land sixteen pads.',
      landingTarget: 16,
    ),
    ChallengeStep(
      number: 23,
      title: 'Bright Channel',
      description: 'Score 260.',
      scoreTarget: 260,
    ),
    ChallengeStep(
      number: 24,
      title: 'Cloud Cartographer',
      description: 'Score 275 and collect seven signals.',
      scoreTarget: 275,
      pickupTarget: 7,
    ),
    ChallengeStep(
      number: 25,
      title: 'Steady Altitude',
      description: 'Land eighteen pads.',
      landingTarget: 18,
    ),
    ChallengeStep(
      number: 26,
      title: 'Signal Route',
      description: 'Collect eight signals.',
      pickupTarget: 8,
    ),
    ChallengeStep(
      number: 27,
      title: 'Blue Marker',
      description: 'Reach score 310.',
      scoreTarget: 310,
    ),
    ChallengeStep(
      number: 28,
      title: 'Long Climb',
      description: 'Score 330 and land twenty pads.',
      scoreTarget: 330,
      landingTarget: 20,
    ),
    ChallengeStep(
      number: 29,
      title: 'Signal Line',
      description: 'Collect nine signals.',
      pickupTarget: 9,
    ),
    ChallengeStep(
      number: 30,
      title: 'Weather Runner',
      description: 'Reach score 360.',
      scoreTarget: 360,
    ),
    ChallengeStep(
      number: 31,
      title: 'Pad Specialist',
      description: 'Land twenty-two pads.',
      landingTarget: 22,
    ),
    ChallengeStep(
      number: 32,
      title: 'Signal Net',
      description: 'Collect ten signals.',
      pickupTarget: 10,
    ),
    ChallengeStep(
      number: 33,
      title: 'High Dispatch',
      description: 'Score 395.',
      scoreTarget: 395,
    ),
    ChallengeStep(
      number: 34,
      title: 'Cloud Runner',
      description: 'Score 420 with twenty-four landings.',
      scoreTarget: 420,
      landingTarget: 24,
    ),
    ChallengeStep(
      number: 35,
      title: 'Signal Stack',
      description: 'Collect eleven signals.',
      pickupTarget: 11,
    ),
    ChallengeStep(
      number: 36,
      title: 'Thin Air Route',
      description: 'Score 455.',
      scoreTarget: 455,
    ),
    ChallengeStep(
      number: 37,
      title: 'Landing Mastery',
      description: 'Land twenty-six pads.',
      landingTarget: 26,
    ),
    ChallengeStep(
      number: 38,
      title: 'Bright Delivery',
      description: 'Collect twelve signals.',
      pickupTarget: 12,
    ),
    ChallengeStep(
      number: 39,
      title: 'Upper Weather',
      description: 'Score 490 and collect twelve signals.',
      scoreTarget: 490,
      pickupTarget: 12,
    ),
    ChallengeStep(
      number: 40,
      title: 'Sky Courier',
      description: 'Complete the v1 route book.',
      scoreTarget: 525,
      landingTarget: 28,
      pickupTarget: 12,
    ),
  ];

  ChallengeStep stepForProgress(int completedSteps) {
    final index = completedSteps.clamp(0, steps.length - 1).toInt();
    return steps[index];
  }
}
