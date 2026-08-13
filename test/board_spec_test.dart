import 'package:flutter_test/flutter_test.dart';
import 'package:sixteen_breed/src/game/domain/board_spec.dart';
import 'package:sixteen_breed/src/game/domain/board_validator.dart';
import 'package:sixteen_breed/src/game/domain/models.dart';

void main() {
  test('approved board graph validates', () {
    final result = BoardValidator.validate();

    expect(result.errors, isEmpty);
    expect(result.isValid, isTrue);
  });

  test('board has the approved counts', () {
    expect(BoardSpec.nodes, hasLength(37));
    expect(BoardSpec.edges, hasLength(76));
    expect(BoardSpec.undirectedJumpPaths, hasLength(52));
    expect(BoardSpec.directionalJumpPaths, hasLength(104));
  });

  test('node coordinates match the approved production v1 graph', () {
    final actual = {
      for (final node in BoardSpec.nodes) node.id: [node.xRatio, node.yRatio],
    };

    expect(actual, {
      0: [0.25, 0.0],
      1: [0.5, 0.0],
      2: [0.75, 0.0],
      3: [0.375, 0.125],
      4: [0.5, 0.125],
      5: [0.625, 0.125],
      6: [0.0, 0.25],
      7: [0.25, 0.25],
      8: [0.5, 0.25],
      9: [0.75, 0.25],
      10: [1.0, 0.25],
      11: [0.0, 0.375],
      12: [0.25, 0.375],
      13: [0.5, 0.375],
      14: [0.75, 0.375],
      15: [1.0, 0.375],
      16: [0.0, 0.5],
      17: [0.25, 0.5],
      18: [0.5, 0.5],
      19: [0.75, 0.5],
      20: [1.0, 0.5],
      21: [0.0, 0.625],
      22: [0.25, 0.625],
      23: [0.5, 0.625],
      24: [0.75, 0.625],
      25: [1.0, 0.625],
      26: [0.0, 0.75],
      27: [0.25, 0.75],
      28: [0.5, 0.75],
      29: [0.75, 0.75],
      30: [1.0, 0.75],
      31: [0.375, 0.875],
      32: [0.5, 0.875],
      33: [0.625, 0.875],
      34: [0.25, 1.0],
      35: [0.5, 1.0],
      36: [0.75, 1.0],
    });
  });

  test('direct edges match the approved production v1 graph', () {
    expect(BoardSpec.edges.map((edge) => edge.key).toList(), [
      '0-1',
      '0-3',
      '1-2',
      '1-4',
      '2-5',
      '3-4',
      '3-8',
      '4-5',
      '4-8',
      '5-8',
      '6-7',
      '6-11',
      '6-12',
      '7-8',
      '7-12',
      '8-9',
      '8-12',
      '8-13',
      '8-14',
      '9-10',
      '9-14',
      '10-14',
      '10-15',
      '11-12',
      '11-16',
      '12-13',
      '12-16',
      '12-17',
      '12-18',
      '13-14',
      '13-18',
      '14-15',
      '14-18',
      '14-19',
      '14-20',
      '15-20',
      '16-17',
      '16-21',
      '16-22',
      '17-18',
      '17-22',
      '18-19',
      '18-22',
      '18-23',
      '18-24',
      '19-20',
      '19-24',
      '20-24',
      '20-25',
      '21-22',
      '21-26',
      '22-23',
      '22-26',
      '22-27',
      '22-28',
      '23-24',
      '23-28',
      '24-25',
      '24-28',
      '24-29',
      '24-30',
      '25-30',
      '26-27',
      '27-28',
      '28-29',
      '28-31',
      '28-32',
      '28-33',
      '29-30',
      '31-32',
      '31-34',
      '32-33',
      '32-35',
      '33-36',
      '34-35',
      '35-36',
    ]);
  });

  test('jump paths match the approved production v1 graph', () {
    expect(BoardSpec.undirectedJumpPaths.map((path) => path.key).toList(), [
      '0-1-2',
      '0-3-8',
      '1-4-8',
      '2-5-8',
      '3-4-5',
      '4-8-13',
      '6-7-8',
      '6-11-16',
      '6-12-18',
      '7-8-9',
      '7-12-17',
      '8-9-10',
      '8-12-16',
      '8-13-18',
      '8-14-20',
      '9-14-19',
      '10-14-18',
      '10-15-20',
      '11-12-13',
      '11-16-21',
      '12-13-14',
      '12-17-22',
      '12-18-24',
      '13-14-15',
      '13-18-23',
      '14-18-22',
      '14-19-24',
      '15-20-25',
      '16-17-18',
      '16-21-26',
      '16-22-28',
      '17-18-19',
      '17-22-27',
      '18-19-20',
      '18-22-26',
      '18-23-28',
      '18-24-30',
      '19-24-29',
      '20-24-28',
      '20-25-30',
      '21-22-23',
      '22-23-24',
      '23-24-25',
      '23-28-32',
      '26-27-28',
      '27-28-29',
      '28-29-30',
      '28-31-34',
      '28-32-35',
      '28-33-36',
      '31-32-33',
      '34-35-36',
    ]);
  });

  test('initial placement is 16 beads each with five empty center nodes', () {
    expect(BoardSpec.player1StartNodes, hasLength(16));
    expect(BoardSpec.player2StartNodes, hasLength(16));
    expect(BoardSpec.emptyStartNodes, [16, 17, 18, 19, 20]);

    final all = {
      ...BoardSpec.player1StartNodes,
      ...BoardSpec.player2StartNodes,
      ...BoardSpec.emptyStartNodes,
    };
    expect(all, hasLength(BoardSpec.nodeCount));
  });

  test('edges expand bidirectionally', () {
    for (final edge in BoardSpec.edges) {
      expect(BoardSpec.adjacency[edge.a], contains(edge.b));
      expect(BoardSpec.adjacency[edge.b], contains(edge.a));
    }
  });

  test('jump paths are collinear and made from direct edges', () {
    for (final path in BoardSpec.undirectedJumpPaths) {
      expect(_hasEdge(path.from, path.over), isTrue);
      expect(_hasEdge(path.over, path.to), isTrue);
      expect(_isCollinear(path), isTrue);
    }
  });
}

bool _hasEdge(int a, int b) {
  return BoardSpec.edgeKeys.contains(BoardEdge(a, b).key);
}

bool _isCollinear(JumpPath path) {
  final a = BoardSpec.nodesById[path.from]!;
  final b = BoardSpec.nodesById[path.over]!;
  final c = BoardSpec.nodesById[path.to]!;
  final abX = b.xRatio - a.xRatio;
  final abY = b.yRatio - a.yRatio;
  final bcX = c.xRatio - b.xRatio;
  final bcY = c.yRatio - b.yRatio;
  return (abX * bcY - abY * bcX).abs() < 0.000001;
}
