import 'dart:math';

import 'package:flame/components.dart';

mixin CharacterMixin on Component {
  late int id;
  late int life;

  void initializeCharacter(int initialLife) {
    id = _generateRandomId();
    life = initialLife;
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
