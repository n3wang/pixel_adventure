import 'package:flame/components.dart';
import 'package:pixel_adventure/components/weapon.dart';

class Gun extends Weapon {
  Gun({
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    debugMode = true;
    sprite = await Sprite.load('Items/Misc/gun.png');
    return super.onLoad();
  }
}
