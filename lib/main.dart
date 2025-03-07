import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pixel_adventure/components/level.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

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

  final level = Level(
    levelName: 'level_1',
    player1: player1,
    player2: player2,
  );

  runApp(GameWidget(game: PixelAdventure()));
}
