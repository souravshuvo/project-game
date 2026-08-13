import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../domain/arena_food.dart';
import '../domain/arena_difficulty_phase.dart';
import '../domain/food_type.dart';
import '../domain/game_feedback_event.dart';
import '../domain/run_state.dart';
import '../domain/run_stats.dart';
import '../domain/vector2.dart';
import '../services/analytics_sink.dart';
import 'components/trail_actor_component.dart';
import 'systems/bot_ai_system.dart';
import 'systems/collision_system.dart';
import 'systems/score_system.dart';
import 'systems/spawn_system.dart';

class TrailArenaGame extends ChangeNotifier {
  TrailArenaGame({
    AnalyticsSink analytics = const NoOpAnalyticsSink(),
    math.Random? random,
  }) : _analytics = analytics,
       _random = random ?? math.Random() {
    _spawnSystem = SpawnSystem(
      random: _random,
      arenaWidth: arenaWidth,
      arenaHeight: arenaHeight,
      spawnMargin: spawnMargin,
      bodyRadius: bodyRadius,
    );
    _botAi = BotAiSystem(
      random: _random,
      arenaWidth: arenaWidth,
      arenaHeight: arenaHeight,
    );
  }

  static const arenaWidth = 720.0;
  static const arenaHeight = 960.0;
  static const targetFoodCount = 24;
  static const spawnMargin = 36.0;
  static const headRadius = 13.0;
  static const bodyRadius = 9.0;
  static const readySeconds = 2.0;
  static const botRespawnSeconds = 3.0;

  final AnalyticsSink _analytics;
  final math.Random _random;
  final _collision = const CollisionSystem(
    arenaWidth: arenaWidth,
    arenaHeight: arenaHeight,
    headRadius: headRadius,
    bodyRadius: bodyRadius,
  );
  final _score = ScoreSystem();
  late final SpawnSystem _spawnSystem;
  late final BotAiSystem _botAi;

  final List<ArenaFood> _food = <ArenaFood>[];
  final List<TrailActorComponent> _bots = <TrailActorComponent>[];

  RunPhase phase = RunPhase.menu;
  DeathCause? deathCause;
  GameFeedbackEvent? latestEvent;
  RunStats runStats = RunStats.empty;
  double elapsedSeconds = 0;
  double readyRemaining = readySeconds;
  int bestScore = 0;
  int gamesPlayed = 0;
  bool achievedBestThisRun = false;
  int _eventId = 0;
  ArenaDifficultyPhase? _lastLoggedDifficultyPhase;

  late TrailActorComponent player;

  int get score => _score.score;

  UnmodifiableListView<ArenaFood> get food => UnmodifiableListView(_food);

  UnmodifiableListView<TrailActorComponent> get bots =>
      UnmodifiableListView(_bots);

  List<TrailActorComponent> get actors => <TrailActorComponent>[
    player,
    ..._bots,
  ];

  bool get isGameOver => phase == RunPhase.gameOver;

  bool get isActive => phase == RunPhase.ready || phase == RunPhase.running;

  ArenaDifficultyPhase get difficultyPhase {
    return ArenaDifficultyPhaseRules.fromElapsed(elapsedSeconds);
  }

  void hydrateSave({required int bestScore, required int gamesPlayed}) {
    this.bestScore = bestScore;
    this.gamesPlayed = gamesPlayed;
    notifyListeners();
  }

  void showMenu() {
    phase = RunPhase.menu;
    notifyListeners();
  }

  void startRun() {
    _score.reset();
    deathCause = null;
    latestEvent = null;
    runStats = RunStats.empty;
    achievedBestThisRun = false;
    _lastLoggedDifficultyPhase = null;
    elapsedSeconds = 0;
    readyRemaining = readySeconds;
    phase = RunPhase.ready;
    player = TrailActorComponent(
      id: 0,
      kind: ActorKind.player,
      spawn: const Vec2(arenaWidth / 2, arenaHeight / 2),
      heading: -math.pi / 2,
      baseSpeed: 136,
      turnRate: 5.4,
      initialLength: 140,
    );
    _bots
      ..clear()
      ..addAll(_createInitialBots());
    _food.clear();
    _fillFood();
    _syncRunStats();
    _emitFeedback(GameFeedbackKind.runStarted, position: player.head);
    _analytics.log('game_run_start', {
      'bot_count': _bots.length,
      'goal_ready': 1,
    });
    _logDifficultyPhaseIfNeeded();
    notifyListeners();
  }

  void pause() {
    if (phase == RunPhase.ready || phase == RunPhase.running) {
      phase = RunPhase.paused;
      _analytics.log('game_pause', {
        'duration_seconds': elapsedSeconds.floor(),
        'score': score,
      });
      notifyListeners();
    }
  }

  void resume() {
    if (phase == RunPhase.paused) {
      phase = RunPhase.ready;
      readyRemaining = 1;
      _analytics.log('game_resume', {
        'duration_seconds': elapsedSeconds.floor(),
        'score': score,
      });
      notifyListeners();
    }
  }

  void steerPlayer(Vec2 direction) {
    if (phase == RunPhase.gameOver || phase == RunPhase.menu) {
      return;
    }
    player.steerWithDirection(direction);
  }

  @visibleForTesting
  void debugReplaceFood(List<ArenaFood> items) {
    _food
      ..clear()
      ..addAll(items);
  }

  void update(double dt) {
    if (!isActive || dt <= 0) {
      return;
    }

    final step = dt.clamp(0.0, 0.05).toDouble();
    if (phase == RunPhase.ready) {
      readyRemaining -= step;
      if (readyRemaining <= 0) {
        phase = RunPhase.running;
      }
      notifyListeners();
      return;
    }

    elapsedSeconds += step;
    _logDifficultyPhaseIfNeeded();
    _score.updateSurvival(step);
    player.updateMovement(step, speedScale: _playerSpeedScale);
    _updateBots(step);
    _syncRunStats();
    _collectFood();
    _resolveCollisions();
    _syncRunStats();
    _fillFood();
    notifyListeners();
  }

  Iterable<TrailActorComponent> _createInitialBots() sync* {
    final spawns = <Vec2>[
      const Vec2(150, 190),
      const Vec2(arenaWidth - 150, arenaHeight - 190),
    ];
    for (var i = 0; i < spawns.length; i++) {
      yield TrailActorComponent(
        id: i + 1,
        kind: ActorKind.bot,
        spawn: spawns[i],
        heading: i.isEven ? 0.7 : math.pi + 0.7,
        baseSpeed: 118 + (i * 4),
        turnRate: 4.3,
        initialLength: 112,
      );
    }
  }

  void _updateBots(double dt) {
    for (final bot in _bots) {
      if (!bot.alive) {
        bot.respawnTimer -= dt;
        if (bot.respawnTimer <= 0) {
          _respawnBot(bot);
        }
        continue;
      }
      _botAi.updateBot(bot: bot, food: _food, actors: actors, dt: dt);
      bot.updateMovement(dt, speedScale: _botSpeedScale);
    }
  }

  void _collectFood() {
    _collectForActor(player, isPlayer: true);
    for (final bot in _bots) {
      if (bot.alive) {
        _collectForActor(bot, isPlayer: false);
      }
    }
  }

  void _collectForActor(TrailActorComponent actor, {required bool isPlayer}) {
    for (var i = _food.length - 1; i >= 0; i--) {
      final item = _food[i];
      final pickupDistance = headRadius + item.type.radius;
      if (actor.head.distanceTo(item.position) <= pickupDistance) {
        actor.grow(isPlayer ? item.type.playerGrowth : item.type.botGrowth);
        if (isPlayer) {
          _score.addFoodScore(item.type.score);
          runStats = runStats.copyWith(
            score: score,
            foodCollected: runStats.foodCollected + 1,
            brightFoodCollected: item.type == FoodType.brightSeed
                ? runStats.brightFoodCollected + 1
                : runStats.brightFoodCollected,
            trailLength: actor.targetLength,
          );
          _emitFeedback(
            item.type == FoodType.brightSeed
                ? GameFeedbackKind.brightFoodCollected
                : GameFeedbackKind.foodCollected,
            position: item.position,
            scoreDelta: item.type.score,
          );
          _analytics.log('game_food_collect', {
            'food_type': item.type.name,
            'score': score,
            'length': actor.targetLength,
            'duration_seconds': elapsedSeconds.floor(),
          });
        }
        _food.removeAt(i);
      }
    }
  }

  void _resolveCollisions() {
    if (_collision.hitsBoundary(player.head)) {
      _endRun(DeathCause.boundary);
      return;
    }
    if (_collision.hitsTrail(player.head, player, skipHeadDistance: 76)) {
      _endRun(DeathCause.selfTrail);
      return;
    }

    for (final bot in _bots) {
      if (!bot.alive) {
        continue;
      }
      if (_collision.hitsHead(player.head, bot.head)) {
        _endRun(DeathCause.botHead);
        return;
      }
      if (_collision.hitsTrail(player.head, bot, skipHeadDistance: 0)) {
        _endRun(DeathCause.botTrail);
        return;
      }
    }

    for (final bot in _bots) {
      if (!bot.alive) {
        continue;
      }
      if (_collision.hitsBoundary(bot.head) ||
          _collision.hitsTrail(bot.head, bot, skipHeadDistance: 72)) {
        _killBot(bot);
        continue;
      }
      if (_collision.hitsTrail(bot.head, player, skipHeadDistance: 32)) {
        _score.addBotCrashBonus();
        runStats = runStats.copyWith(
          score: score,
          botCrashes: runStats.botCrashes + 1,
        );
        _emitFeedback(
          GameFeedbackKind.botCrashed,
          position: bot.head,
          scoreDelta: ScoreSystem.botCrashBonus,
        );
        _analytics.log('game_bot_crash', {
          'cause': 'player_trail',
          'score': score,
          'duration_seconds': elapsedSeconds.floor(),
        });
        _killBot(bot);
        continue;
      }
      for (final other in _bots) {
        if (identical(bot, other) || !other.alive) {
          continue;
        }
        if (_collision.hitsTrail(bot.head, other)) {
          _killBot(bot);
          break;
        }
      }
    }
  }

  void _killBot(TrailActorComponent bot) {
    bot.kill(respawnDelay: botRespawnSeconds);
  }

  void _respawnBot(TrailActorComponent bot) {
    final spawn = _spawnSystem.safeActorSpawn(
      actors: actors,
      food: _food,
      avoid: player.head,
    );
    if (spawn == null) {
      bot.respawnTimer = 1;
      return;
    }
    bot.reset(spawn: spawn, heading: _random.nextDouble() * math.pi * 2);
  }

  void _fillFood() {
    var spawnAttempts = 0;
    while (_food.length < targetFoodCount && spawnAttempts < targetFoodCount) {
      spawnAttempts += 1;
      final item = _spawnSystem.createFood(actors: actors, existingFood: _food);
      if (item == null) {
        return;
      }
      _food.add(item);
    }
  }

  void _endRun(DeathCause cause) {
    _syncRunStats();
    phase = RunPhase.gameOver;
    deathCause = cause;
    achievedBestThisRun = score > bestScore;
    if (score > bestScore) {
      bestScore = score;
    }
    gamesPlayed += 1;
    _emitFeedback(GameFeedbackKind.playerDied, position: player.head);
    _analytics.log('game_run_end', {
      'score': score,
      'duration_seconds': elapsedSeconds.floor(),
      'death_cause': cause.name,
      'length': player.targetLength,
      'difficulty_phase': difficultyPhase.name,
      'food_collected': runStats.foodCollected,
      'bright_food_collected': runStats.brightFoodCollected,
      'bot_crashes': runStats.botCrashes,
      'new_best': achievedBestThisRun,
    });
  }

  void _syncRunStats() {
    runStats = runStats.copyWith(
      score: score,
      survivalSeconds: elapsedSeconds,
      trailLength: player.targetLength,
    );
  }

  void _logDifficultyPhaseIfNeeded() {
    final phase = difficultyPhase;
    if (_lastLoggedDifficultyPhase == phase) {
      return;
    }
    _lastLoggedDifficultyPhase = phase;
    _analytics.log('game_difficulty_phase', {
      'phase': phase.name,
      'duration_seconds': elapsedSeconds.floor(),
      'score': score,
    });
  }

  void _emitFeedback(
    GameFeedbackKind kind, {
    required Vec2 position,
    int scoreDelta = 0,
  }) {
    latestEvent = GameFeedbackEvent(
      id: ++_eventId,
      kind: kind,
      position: position,
      scoreDelta: scoreDelta,
    );
  }

  double get _playerSpeedScale => 1 + math.min(elapsedSeconds / 300, 0.12);

  double get _botSpeedScale {
    return _playerSpeedScale * difficultyPhase.botSpeedScale;
  }
}
