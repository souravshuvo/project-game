import 'bubble_color.dart';
import 'bubble_grid.dart';

class BubbleLevel {
  const BubbleLevel({
    required this.id,
    required this.title,
    required this.shots,
    required this.layout,
    required this.bubbleQueue,
  });

  final String id;
  final String title;
  final int shots;
  final List<List<String?>> layout;
  final List<DewBubbleColor> bubbleQueue;

  BubbleGrid createGrid() => BubbleGrid.fromTokens(layout);
}
