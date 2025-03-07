import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:pixel_adventure/components/jump_button.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/level.dart';

class PixelAdventure extends FlameGame
    with HasKeyboardHandlerComponents, DragCallbacks, HasCollisionDetection {
  @override
  Color backgroundColor() => const Color(0xFF211F30);

  CameraComponent? cam;
  late JoystickComponent joystick;
  List<String> levelNames = ['level_1', 'level_2', 'level_3'];
  int currentLevelIndex = 0;

  bool showControls = false;
  bool playSounds = true;
  double soundVolume = 1.0;

  @override
  FutureOr<void> onLoad() async {
    // Load all images into cache
    await images.loadAllImages();
    _loadLevel();

    if (showControls) {
      addJoystick();
      add(JumpButton());
    }

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (showControls) {
      updateJoystick();
    }
    super.update(dt);
  }

  void addJoystick() {
    joystick = JoystickComponent(
      priority: 20,
      knob: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/Knob.png'),
        ),
      ),
      background: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/Joystick.png'),
        ),
      ),
      margin: const EdgeInsets.only(left: 32, bottom: 32),
    );

    add(joystick);
  }

  void updateJoystick() {
    switch (joystick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player1.horizontalMovement = -1;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player1.horizontalMovement = 1;
        break;
      default:
        player1.horizontalMovement = 0;
        break;
    }
  }

  void loadNextLevel() {
    removeWhere((component) => component is Level);

    if (currentLevelIndex < levelNames.length - 1) {
      currentLevelIndex++;
      _loadLevel();
    } else {
      // no more levels
      currentLevelIndex = 0;
      _loadLevel();
    }
  }

  final player1 = Player(
    leftKey: LogicalKeyboardKey.keyA,
    rightKey: LogicalKeyboardKey.keyD,
    jumpKey: LogicalKeyboardKey.space,
    position: Vector2(100, 100),
  );

  final player2 = Player(
    leftKey: LogicalKeyboardKey.arrowLeft,
    rightKey: LogicalKeyboardKey.arrowRight,
    jumpKey: LogicalKeyboardKey.arrowUp,
    position: Vector2(200, 100),
  );

  void _loadLevel() {
    Future.delayed(const Duration(seconds: 0), () {
      Level world = Level(
        player1: player1,
        player2: player2,
        levelName: levelNames[currentLevelIndex],
      );

      if (cam != null) {
        remove(cam!);
      }

      cam = CameraComponent.withFixedResolution(
        world: world,
        width: 640, // Adjust the width to fit the screen
        height: 280, // Adjust the height to fit the screen
      );
      cam!.viewfinder.anchor = Anchor.topLeft;

      add(world);
      add(cam!);
    });
  }
}
