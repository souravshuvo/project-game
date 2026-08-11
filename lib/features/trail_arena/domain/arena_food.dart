import 'food_type.dart';
import 'vector2.dart';

class ArenaFood {
  const ArenaFood({required this.position, this.type = FoodType.seed});

  final Vec2 position;
  final FoodType type;
}
