import 'dart:math';
import 'package:flame/components.dart';

class CharacterComponent extends SpriteAnimationGroupComponent {
  late int id;
  late double life;
  late double maxLife = 3;

  CharacterComponent({
    required Vector2 position,
    double initialLife = 1,
  }) : super(position: position) {
    initializeCharacter(initialLife);
  }

  void initializeCharacter(double initialLife) {
    id = _generateRandomId();
    life = initialLife;
    maxLife = initialLife;
  }

  int _generateRandomId() {
    final random = Random();
    return random.nextInt(1000000); // Generate a random ID between 0 and 999999
  }

  void reduceLife(int amount) {
    life -= amount;
    if (life <= 0) {
      removeFromParent();
    }
  }
}
