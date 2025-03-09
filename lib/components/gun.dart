import 'package:flame/components.dart';
import 'package:pixel_adventure/components/weapon.dart';

class Gun extends Weapon {
  int bulletCount = 10;
  int magazineCount;
  Gun({
    required Vector2 position,
    required Vector2 size,
    this.magazineCount = 10,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    debugMode = true;
    sprite = await Sprite.load('Items/Misc/gun.png');
    return super.onLoad();
  }

  @override
  void use() {
    if (canUse()) {
      shoot();
    }
  }

  @override
  String messageInUI() {
    return 'Bullets: $bulletCount/$magazineCount';
  }

  @override
  bool canUse() {
    return bulletCount > 0;
  }

  void shoot() {
    if (bulletCount > 0) {
      bulletCount--;
    }
  }

  void reload(int bullets) {
    bulletCount += bullets;
  }
}
