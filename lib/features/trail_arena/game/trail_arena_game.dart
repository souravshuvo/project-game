import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../domain/arena_food.dart';
import '../domain/food_type.dart';
import '../domain/run_state.dart';
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
  double elapsedSeconds = 0;
  double readyRemaining = readySeconds;
  int bestScore = 0;
  int gamesPlayed = 0;

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
    _analytics.log('run_started', {'bot_count': _bots.length});
    notifyListeners();
  }

  void pause() {
    if (phase == RunPhase.ready || phase == RunPhase.running) {
      phase = RunPhase.paused;
      _analytics.log('run_paused', {'duration': elapsedSeconds});
      notifyListeners();
    }
  }

  void resume() {
    if (phase == RunPhase.paused) {
      phase = RunPhase.ready;
      readyRemaining = 1;
      _analytics.log('run_resumed', {'duration': elapsedSeconds});
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
    _score.updateSurvival(step);
    player.updateMovement(step, speedScale: _speedScale);
    _updateBots(step);
    _collectFood();
    _resolveCollisions();
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
      bot.updateMovement(dt, speedScale: _speedScale);
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
          _analytics.log('food_collected', {
            'food_type': item.type.name,
            'score': score,
            'length': actor.targetLength,
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
        _analytics.log('bot_crashed', {'cause': 'player_trail'});
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
    phase = RunPhase.gameOver;
    deathCause = cause;
    if (score > bestScore) {
      bestScore = score;
    }
    gamesPlayed += 1;
    _analytics.log('run_ended', {
      'score': score,
      'duration': elapsedSeconds,
      'death_cause': cause.name,
      'length': player.targetLength,
    });
  }

  double get _speedScale => 1 + math.min(elapsedSeconds / 240, 0.18);
}
