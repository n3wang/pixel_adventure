import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Checkpoint extends SpriteAnimationComponent
    with HasGameRef<PixelAdventure>, CollisionCallbacks {
  Checkpoint({position, size}) : super(position: position, size: size);

  bool reachedcheckpoint = false;

  @override
  FutureOr<void> onLoad() {
    debugMode = true;
    add(RectangleHitbox(
        position: Vector2(18, 56),
        size: Vector2(12, 8),
        collisionType: CollisionType.passive));

    animation = SpriteAnimation.fromFrameData(
        game.images
            .fromCache('Items/Checkpoints/Checkpoint/Checkpoint (No Flag).png'),
        SpriteAnimationData.sequenced(
            amount: 1, stepTime: 1, textureSize: Vector2.all(64)));
    return super.onLoad();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player && !reachedcheckpoint) _reachedCheckpoint();

    super.onCollision(intersectionPoints, other);
  }

  void _reachedCheckpoint() {
    reachedcheckpoint = true;
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache(
          'Items/Checkpoints/Checkpoint/Checkpoint (Flag Out) (64x64).png'),
      SpriteAnimationData.sequenced(
        amount: 26,
        stepTime: 0.05, // Adjusted step time for smoother animation
        textureSize: Vector2.all(64),
        loop: false,
      ),
    );

    // const flagDuration = Duration(milliseconds: 1300);
    // Future.delayed(flagDuration, () {
    //   // Ensure the flag stays visible after the animation completes
    //   animation = SpriteAnimation.fromFrameData(
    //     game.images.fromCache(
    //         'Items/Checkpoints/Checkpoint/Checkpoint (Flag Out) (64x64).png'),
    //     SpriteAnimationData.sequenced(
    //       amount: 1,
    //       stepTime: 1,
    //       textureSize: Vector2.all(64),
    //     ),
    //   );
    // });

    const flagIdleDuration = Duration(milliseconds: 1500);
    Future.delayed(flagIdleDuration, () {
      animation = SpriteAnimation.fromFrameData(
        game.images.fromCache(
            "Items/Checkpoints/Checkpoint/Checkpoint (Flag Idle)(64x64).png"),
        SpriteAnimationData.sequenced(
            amount: 10,
            stepTime: 0.05,
            textureSize: Vector2.all(64),
            loop: true),
      );
    });
  }
}
