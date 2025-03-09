import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:pixel_adventure/components/character.dart';
import 'package:pixel_adventure/components/character_mixin.dart';
import 'package:pixel_adventure/components/player.dart';

class Bullet extends SpriteComponent with HasGameRef, CollisionCallbacks {
  final Vector2 direction;
  final double speed;
  final double lifetime; // Lifetime of the bullet in seconds
  final int shooterId; // ID of the shooter to avoid self-collision
  late Timer _timer;

  Bullet({
    required Vector2 position,
    required this.direction,
    required this.speed,
    required Vector2 size,
    required this.shooterId,
    this.lifetime = 2.0, // Default lifetime of 2 seconds
  }) : super(position: position, size: size) {
    _timer = Timer(lifetime, onTick: () {
      removeFromParent();
    });
  }

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('Items/Misc/bullet.png');
    debugMode = true;
    add(RectangleHitbox());
    return super.onLoad();
  }

  @override
  void update(double dt) {
    position += direction * speed * dt;
    _timer.update(dt);
    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is CharacterComponent) {
      if (other.id == shooterId) {
        return; // Ignore collision with the shooter
      }
      other.reduceLife(1); // Reduce life by 1 or any other amount
      removeFromParent(); // Remove bullet after hitting a character
    }
    super.onCollision(intersectionPoints, other);
  }
}
