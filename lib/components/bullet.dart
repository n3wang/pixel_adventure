import 'package:flame/components.dart';
import 'package:flame/collisions.dart';

class Bullet extends SpriteComponent with HasGameRef, CollisionCallbacks {
  final Vector2 direction;
  final double speed;
  final double lifetime; // Lifetime of the bullet in seconds
  late Timer _timer;

  Bullet({
    required Vector2 position,
    required this.direction,
    required this.speed,
    required Vector2 size,
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
}
