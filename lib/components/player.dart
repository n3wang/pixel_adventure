import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';
import 'package:pixel_adventure/components/checkpoint.dart';
import 'package:pixel_adventure/components/chicken.dart';
import 'package:pixel_adventure/components/collision_block.dart';
import 'package:pixel_adventure/components/fruit.dart';
import 'package:pixel_adventure/components/gun.dart';
import 'package:pixel_adventure/components/saw.dart';
import 'package:pixel_adventure/components/utils.dart';
import 'package:pixel_adventure/components/weapon.dart';
import 'package:pixel_adventure/pixel_adventure.dart';
import 'package:pixel_adventure/components/custom_hitbox.dart';
import 'package:pixel_adventure/components/level.dart';

enum PlayerState {
  idle,
  running,
  jumping,
  falling,
  hit,
  appearing,
  dissapearing
}

enum PlayerDirection { left, right, none }

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, KeyboardHandler, CollisionCallbacks {
  late String character;
  Weapon? weapon;
  final LogicalKeyboardKey leftKey;
  final LogicalKeyboardKey rightKey;
  final LogicalKeyboardKey jumpKey;
  final LogicalKeyboardKey fireKey;
  Level? level;
  List<Weapon?> inventory = List.filled(10, null); // Inventory with 10 slots

  Player({
    required this.leftKey,
    required this.rightKey,
    required this.jumpKey,
    required this.fireKey,
    this.level,
    position,
    this.character = 'Ninja Frog',
  }) : super(position: position);

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runAnimation;
  late final SpriteAnimation jumpAnimation;
  late final SpriteAnimation fallAnimation;
  late final SpriteAnimation hitAnimation;
  late final SpriteAnimation appearingAnimation;
  late final SpriteAnimation dissapearingAnimation;

  bool isOnGround = false;
  bool hasJumped = false;
  bool gotHit = false;

  final double stepTime = 0.05;
  final double _gravity = 9.8;
  final double _jumpForce = 260;
  final double _terminalVelocity = 300;

  double horizontalMovement = 0.0;
  bool isFacingRight = true;
  bool reachedCheckpoint = false;
  List<CollisionBlock> collisionBlocks = [];
  CustomHitbox hitbox = CustomHitbox(
    offsetX: 10,
    offsetY: 4,
    width: 14,
    height: 28,
  );

  double fixedDeltaTime = 1 / 60;
  double accumulatedTime = 0;

  PlayerDirection playerDirection = PlayerDirection.none;
  double moveSpeed = 100.0;
  Vector2 startingPosition = Vector2.zero();
  Vector2 velocity = Vector2.zero();

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();

    inventory[0] = Gun(
      position: position + Vector2(0, 0), // Adjust position as needed
      size: Vector2(32, 32),
    );
    debugMode = true;

    startingPosition = Vector2(position.x, position.y);
    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(hitbox.width, hitbox.height),
    ));

    // Check inventory and attach weapon if in slot 1
    if (inventory[0] != null) {
      attachWeapon(inventory[0]!);
    }

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (!gotHit && !reachedCheckpoint) {
      _updatePlayerMovement(dt);
      _updatePlayerState();
      _checkHorizontalCollisions();
      _applyGravity(dt);
      _checkVerticalCollisions();
    }

    // Update weapon position
    if (weapon != null) {
      final weaponOffset = isFacingRight ? Vector2(10, 0) : Vector2(-10, 0);
      weapon!.position = position + weaponOffset; // Adjust position as needed
    }
    super.update(dt);
  }

  void attachWeapon(Weapon newWeapon) {
    if (weapon != null) {
      remove(weapon!);
    }
    weapon = newWeapon;
    // add(weapon!);
    level!.add(weapon!);
  }

  void detachWeapon() {
    if (weapon != null) {
      remove(weapon!);
      weapon = null;
    }
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;
    final isLeftKeyPressed = keysPressed.contains(leftKey);
    final isRightKeyPressed = keysPressed.contains(rightKey);
    final isShootKeyPressed = keysPressed.contains(fireKey);

    hasJumped = keysPressed.contains(jumpKey);

    horizontalMovement += isLeftKeyPressed ? -1 : 0;
    horizontalMovement += isRightKeyPressed ? 1 : 0;

    if (isLeftKeyPressed && isRightKeyPressed) {
      playerDirection = PlayerDirection.none;
    } else if (isLeftKeyPressed) {
      playerDirection = PlayerDirection.left;
    } else if (isRightKeyPressed) {
      playerDirection = PlayerDirection.right;
    }

    if (isShootKeyPressed) {
      level!.shoot(this);
    }
    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Fruit) {
      other.collidingWithPlayer();
    } else if (other is Saw) {
      this._respawn();
    }
    if (other is Chicken) {
      other.collidedWithPlayer();
    }
    if (other is Checkpoint && !reachedCheckpoint) _reachedCheckpoint();
    super.onCollisionStart(intersectionPoints, other);
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation('Idle', amount: 11);
    runAnimation = _spriteAnimation('Run', amount: 12);
    jumpAnimation = _spriteAnimation('Jump', amount: 1);
    fallAnimation = _spriteAnimation('Fall', amount: 1);
    hitAnimation = _spriteAnimation('Hit', amount: 7)..loop = false;
    appearingAnimation = _specialSpriteAnimation('Appearing', 7);
    dissapearingAnimation = _specialSpriteAnimation('Desappearing', 7);

    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runAnimation,
      PlayerState.jumping: jumpAnimation,
      PlayerState.falling: fallAnimation,
      PlayerState.hit: hitAnimation,
      PlayerState.appearing: appearingAnimation,
      PlayerState.dissapearing: dissapearingAnimation
    };

    // Set current animation to idle initially.
    current = PlayerState.idle;
  }

  SpriteAnimation _spriteAnimation(String state, {int amount = 11}) {
    return SpriteAnimation.fromFrameData(
        game.images.fromCache(
          'Main Characters/$character/$state (32x32).png',
        ),
        SpriteAnimationData.sequenced(
            amount: amount, stepTime: stepTime, textureSize: Vector2.all(32)));
  }

  SpriteAnimation _specialSpriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$state (96x96).png'),
      SpriteAnimationData.sequenced(
          amount: amount,
          stepTime: stepTime,
          textureSize: Vector2.all(32),
          loop: false),
    );
  }

  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;

    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
      isFacingRight = false;
      if (weapon != null) {
        weapon!.flipHorizontallyAroundCenter();
      }
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
      isFacingRight = true;
      if (weapon != null) {
        weapon!.flipHorizontallyAroundCenter();
      }
    }

    // Check if moving, set running
    if (velocity.x > 0 || velocity.x < 0) playerState = PlayerState.running;

    // // check if Falling set to falling
    if (velocity.y > 0) playerState = PlayerState.falling;

    // // Checks if jumping, set to jumping
    if (velocity.y < 0) playerState = PlayerState.jumping;

    current = playerState;
  }

  void _checkHorizontalCollisions() {
    for (final block in collisionBlocks) {
      if (!block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.x > 0) {
            position.x = block.position.x - width;
          } else if (velocity.x < 0) {
            velocity.x = 0;
            position.x = block.position.x + block.width + width;
          }
        }
      }
    }
  }

  void _updatePlayerMovement(double dt) {
    if (hasJumped && isOnGround) _playerJump(dt);

    if (velocity.y > _gravity) isOnGround = false;

    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;
  }

  void _applyGravity(double dt) {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_jumpForce, _terminalVelocity);
    position.y += velocity.y * dt;
  }

  void _playerJump(double dt) {
    if (game.playSounds)
      FlameAudio.play('jump.wav', volume: game.soundVolume * .5);

    velocity.y = -_jumpForce;
    position.y += velocity.y * dt;
    isOnGround = false;
    hasJumped = false;
  }

  void _checkVerticalCollisions() {
    for (final block in collisionBlocks) {
      if (block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
        }
      } else {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
          if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.y + block.height - hitbox.offsetY;
          }
        }
      }
    }
  }

  void _respawn() async {
    if (game.playSounds) FlameAudio.play('hit.wav', volume: game.soundVolume);
    const canMoveDuration = Duration(milliseconds: 350);
    gotHit = true;
    current = PlayerState.hit;

    await animationTicker?.completed;
    animationTicker?.reset();

    scale.x = 1;
    position = startingPosition - Vector2.all(32);
    current = PlayerState.appearing;

    await animationTicker?.completed;
    animationTicker?.reset();

    velocity = Vector2.zero();
    position = startingPosition;
    _updatePlayerState();
    Future.delayed(canMoveDuration, () => gotHit = false);
  }

  void _reachedCheckpoint() async {
    reachedCheckpoint = true;
    if (game.playSounds)
      FlameAudio.play('disappear.wav', volume: game.soundVolume);
    if (scale.x > 0) {
      position = position - Vector2.all(32);
    } else if (scale.x < 0) {
      position = position + Vector2(32, -32);
    }

    current = PlayerState.dissapearing;

    await animationTicker?.completed;
    animationTicker?.reset();

    reachedCheckpoint = false;
    position = Vector2.all(-640);

    const waitToChangeDuration = Duration(seconds: 3);
    Future.delayed(waitToChangeDuration, () {
      game.loadNextLevel();
    });
  }

  void collidedwithEnemy() {
    _respawn();
  }
}
