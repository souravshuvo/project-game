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

  static BoardValidationResult validate({
    List<BoardNode> nodes = BoardSpec.nodes,
    List<BoardEdge> edges = BoardSpec.edges,
    List<JumpPath> jumpPaths = BoardSpec.undirectedJumpPaths,
  }) {
    final errors = <String>[];
    final nodeIds = nodes.map((node) => node.id).toSet();

    if (nodes.length != BoardSpec.nodeCount) {
      errors.add('Expected 37 nodes, found ${nodes.length}.');
    }
    for (var id = 0; id < BoardSpec.nodeCount; id++) {
      if (!nodeIds.contains(id)) {
        errors.add('Missing node id $id.');
      }
    }
    for (final node in nodes) {
      if (node.xRatio < 0 ||
          node.xRatio > 1 ||
          node.yRatio < 0 ||
          node.yRatio > 1) {
        errors.add('Node ${node.id} has coordinates outside 0..1.');
      }
    }

    if (edges.length != BoardSpec.edgeCount) {
      errors.add('Expected 76 edges, found ${edges.length}.');
    }

    final edgeKeys = <String>{};
    for (final edge in edges) {
      if (!nodeIds.contains(edge.a) || !nodeIds.contains(edge.b)) {
        errors.add('Edge ${edge.a}-${edge.b} references an unknown node.');
        continue;
      }
      if (edge.a == edge.b) {
        errors.add('Edge ${edge.a}-${edge.b} connects a node to itself.');
      }
      final key = _edgeKey(edge.a, edge.b);
      if (!edgeKeys.add(key)) {
        errors.add('Duplicate edge $key.');
      }
    }

    final adjacency = <int, Set<int>>{
      for (final node in nodes) node.id: <int>{},
    };
    for (final edge in edges) {
      if (adjacency.containsKey(edge.a) && adjacency.containsKey(edge.b)) {
        adjacency[edge.a]!.add(edge.b);
        adjacency[edge.b]!.add(edge.a);
      }
    }
    for (final edge in edges) {
      if (adjacency[edge.a]?.contains(edge.b) != true ||
          adjacency[edge.b]?.contains(edge.a) != true) {
        errors.add('Edge ${edge.a}-${edge.b} is not bidirectional.');
      }
    }

    if (jumpPaths.length != BoardSpec.undirectedJumpPathCount) {
      errors.add(
        'Expected 56 undirected jump paths, found ${jumpPaths.length}.',
      );
    }

    final nodeById = {for (final node in nodes) node.id: node};
    final jumpKeys = <String>{};
    for (final path in jumpPaths) {
      if (!nodeIds.contains(path.from) ||
          !nodeIds.contains(path.over) ||
          !nodeIds.contains(path.to)) {
        errors.add(
          'Jump ${path.from}-${path.over}-${path.to} references an unknown node.',
        );
        continue;
      }
      if (!_hasEdge(edgeKeys, path.from, path.over) ||
          !_hasEdge(edgeKeys, path.over, path.to)) {
        errors.add(
          'Jump ${path.from}-${path.over}-${path.to} is not made of direct edges.',
        );
      }
      if (!_isCollinear(
        nodeById[path.from]!,
        nodeById[path.over]!,
        nodeById[path.to]!,
      )) {
        errors.add(
          'Jump ${path.from}-${path.over}-${path.to} is not collinear.',
        );
      }
      final key = _jumpKey(path.from, path.over, path.to);
      final reverseKey = _jumpKey(path.to, path.over, path.from);
      if (jumpKeys.contains(reverseKey)) {
        errors.add(
          'Jump ${path.from}-${path.over}-${path.to} duplicates a reversed path.',
        );
      }
      if (!jumpKeys.add(key)) {
        errors.add('Duplicate jump ${path.from}-${path.over}-${path.to}.');
      }
    }

    final directionalKeys = {
      for (final path in [
        for (final path in jumpPaths) ...[path, path.reversed],
      ])
        _jumpKey(path.from, path.over, path.to),
    };
    if (directionalKeys.length != jumpPaths.length * 2) {
      errors.add(
        'Directional jump expansion did not produce matching reverses.',
      );
    }

    return BoardValidationResult(List.unmodifiable(errors));
  }

  static bool _hasEdge(Set<String> edgeKeys, int a, int b) {
    return edgeKeys.contains(_edgeKey(a, b));
  }

  static String _edgeKey(int a, int b) {
    final min = a < b ? a : b;
    final max = a < b ? b : a;
    return '$min-$max';
  }

  static String _jumpKey(int from, int over, int to) => '$from-$over-$to';

  static bool _isCollinear(BoardNode a, BoardNode b, BoardNode c) {
    final cross =
        (b.xRatio - a.xRatio) * (c.yRatio - a.yRatio) -
        (b.yRatio - a.yRatio) * (c.xRatio - a.xRatio);
    return cross.abs() < 0.000001;
  }
}
