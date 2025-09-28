import 'package:flame/components.dart';
import 'package:pixel_adventure/components/weapon.dart';

class Gun extends Weapon {
  int bulletCount = 10;

  int maxBullets;
  int magazinesCount = 0;
  bool isReloading = false;
  int reloadingTime = 2;

  @override
  // ignore: overridden_fields
  double onHitDamage = 2;

  Gun({
    required Vector2 position,
    required Vector2 size,
    this.maxBullets = 10,
    this.magazinesCount = 3,
    this.onHitDamage = 2,
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
    if (isReloading) {
      return 'Reloading.. | Mag: $magazinesCount';
    }
    return 'Bul: $bulletCount/$maxBullets | Mag: $magazinesCount';
  }

  @override
  bool canUse() {
    return bulletCount > 0;
  }

  @override
  void weaponSpecial() {
    reload(maxBullets);
  }

  void shoot() {
    if (bulletCount > 0 && !isReloading) {
      bulletCount--;
    }
  }

  void reload(int bullets) async {
    if (magazinesCount > 0) {
      isReloading = true;
      // Add a delay before reloading
      await Future.delayed(Duration(seconds: reloadingTime));
      isReloading = false;
      magazinesCount--;
      bulletCount = maxBullets;
    }
  }
}
