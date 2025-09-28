import 'package:flame/components.dart';
import 'package:pixel_adventure/components/weapon.dart';

class Sword extends Weapon {
  @override
  double onHitDamage = 3;

  Sword({
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('Items/Misc/sword.png');
    return super.onLoad();
  }

  @override
  void use() {
    if (canUse()) {
      hit();
    }
  }

  @override
  String messageInUI() {
    return 'Sword';
  }

  @override
  bool canUse() {
    return true;
  }

  void hit() {
    // Implement hit logic
  }
}
