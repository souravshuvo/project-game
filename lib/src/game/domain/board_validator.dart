import 'dart:math';

import 'board_spec.dart';
import 'models.dart';

class BoardValidationResult {
  const BoardValidationResult(this.errors);

  final List<String> errors;

  bool get isValid => errors.isEmpty;

  void throwIfInvalid() {
    if (isValid) {
      return;
    }
    throw StateError('Invalid Sholo Guti board:\n${errors.join('\n')}');
  }
}

class BoardValidator {
  const BoardValidator._();

  static BoardValidationResult validate() {
    final errors = <String>[];
    _validateNodes(errors);
    _validateEdges(errors);
    _validateJumps(errors);
    _validateInitialPlacement(errors);
    return BoardValidationResult(List.unmodifiable(errors));
  }

  static void _validateNodes(List<String> errors) {
    if (BoardSpec.nodes.length != BoardSpec.nodeCount) {
      errors.add('Expected ${BoardSpec.nodeCount} nodes.');
    }

    final ids = BoardSpec.nodes.map((node) => node.id).toSet();
    for (var id = 0; id < BoardSpec.nodeCount; id++) {
      if (!ids.contains(id)) {
        errors.add('Missing node $id.');
      }
    }
    if (ids.length != BoardSpec.nodes.length) {
      errors.add('Duplicate node ids found.');
    }

    final coordinateKeys = <String>{};
    for (final node in BoardSpec.nodes) {
      if (node.xRatio < 0 ||
          node.xRatio > 1 ||
          node.yRatio < 0 ||
          node.yRatio > 1) {
        errors.add('Node ${node.id} coordinate is outside 0..1.');
      }
      final key = '${node.xRatio}:${node.yRatio}';
      if (!coordinateKeys.add(key)) {
        errors.add('Duplicate coordinate $key.');
      }
    }
  }

  static void _validateEdges(List<String> errors) {
    if (BoardSpec.edges.length != BoardSpec.edgeCount) {
      errors.add('Expected ${BoardSpec.edgeCount} direct edges.');
    }

    final edgeKeys = <String>{};
    for (final edge in BoardSpec.edges) {
      if (edge.a == edge.b) {
        errors.add('Self edge at node ${edge.a}.');
      }
      if (!BoardSpec.nodesById.containsKey(edge.a) ||
          !BoardSpec.nodesById.containsKey(edge.b)) {
        errors.add('Edge ${edge.key} references a missing node.');
      }
      if (!edgeKeys.add(edge.key)) {
        errors.add('Duplicate edge ${edge.key}.');
      }
    }

    for (final edge in BoardSpec.edges) {
      if (!BoardSpec.adjacency[edge.a]!.contains(edge.b) ||
          !BoardSpec.adjacency[edge.b]!.contains(edge.a)) {
        errors.add('Edge ${edge.key} is not bidirectional in adjacency.');
      }
    }
  }

  static void _validateJumps(List<String> errors) {
    if (BoardSpec.undirectedJumpPaths.length !=
        BoardSpec.undirectedJumpPathCount) {
      errors.add(
        'Expected ${BoardSpec.undirectedJumpPathCount} undirected jump paths.',
      );
    }
    if (BoardSpec.directionalJumpPaths.length !=
        BoardSpec.undirectedJumpPathCount * 2) {
      errors.add('Directional jump paths should be exactly double.');
    }

    final jumpKeys = <String>{};
    for (final path in BoardSpec.undirectedJumpPaths) {
      if (!jumpKeys.add(path.key)) {
        errors.add('Duplicate jump path ${path.key}.');
      }
      if (!_nodeExists(path.from) ||
          !_nodeExists(path.over) ||
          !_nodeExists(path.to)) {
        errors.add('Jump path ${path.key} references a missing node.');
        continue;
      }
      if (!_hasEdge(path.from, path.over) || !_hasEdge(path.over, path.to)) {
        errors.add('Jump path ${path.key} is not built from direct edges.');
      }
      if (_hasEdge(path.from, path.to)) {
        errors.add('Jump path ${path.key} endpoints are directly connected.');
      }
      if (!_isCollinear(path)) {
        errors.add('Jump path ${path.key} is not collinear.');
      }
      if (!_isMiddleBetweenEndpoints(path)) {
        errors.add(
          'Jump path ${path.key} middle node is not between endpoints.',
        );
      }
    }
  }

  static void _validateInitialPlacement(List<String> errors) {
    final player1 = BoardSpec.player1StartNodes.toSet();
    final player2 = BoardSpec.player2StartNodes.toSet();
    final empty = BoardSpec.emptyStartNodes.toSet();
    final all = {...player1, ...player2, ...empty};

    if (player1.length != 16 || player2.length != 16 || empty.length != 5) {
      errors.add('Initial placement must be 16/16/5 nodes.');
    }
    if (all.length != BoardSpec.nodeCount) {
      errors.add('Initial placement sets overlap or do not cover the board.');
    }
    for (final node in all) {
      if (!_nodeExists(node)) {
        errors.add('Initial placement references missing node $node.');
      }
    }
  }

  static bool _nodeExists(int id) => BoardSpec.nodesById.containsKey(id);

  static bool _hasEdge(int a, int b) {
    final edge = BoardEdge(a, b);
    return BoardSpec.edgeKeys.contains(edge.key);
  }

  static bool _isCollinear(JumpPath path) {
    final a = BoardSpec.nodesById[path.from]!;
    final b = BoardSpec.nodesById[path.over]!;
    final c = BoardSpec.nodesById[path.to]!;
    final abX = b.xRatio - a.xRatio;
    final abY = b.yRatio - a.yRatio;
    final bcX = c.xRatio - b.xRatio;
    final bcY = c.yRatio - b.yRatio;
    return (abX * bcY - abY * bcX).abs() < 0.000001;
  }

  static bool _isMiddleBetweenEndpoints(JumpPath path) {
    final a = BoardSpec.nodesById[path.from]!;
    final b = BoardSpec.nodesById[path.over]!;
    final c = BoardSpec.nodesById[path.to]!;
    final minX = min(a.xRatio, c.xRatio);
    final maxX = max(a.xRatio, c.xRatio);
    final minY = min(a.yRatio, c.yRatio);
    final maxY = max(a.yRatio, c.yRatio);
    return b.xRatio >= minX &&
        b.xRatio <= maxX &&
        b.yRatio >= minY &&
        b.yRatio <= maxY;
  }
}
