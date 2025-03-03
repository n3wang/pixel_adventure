import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/foundation.dart';
import 'package:pixel_adventure/components/background_tile.dart';
import 'package:pixel_adventure/components/checkpoint.dart';
import 'package:pixel_adventure/components/chicken.dart';
import 'package:pixel_adventure/components/fruit.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/collision_block.dart';
import 'package:pixel_adventure/components/saw.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Level extends World with HasGameRef<PixelAdventure> {
  late TiledComponent level;
  final Player player;
  final String levelName;
  final List<CollisionBlock> collisionBlocks = [];

  Level({this.levelName = 'level_1', required this.player});

  @override
  Future<void> onLoad() async {
    // Add your components here

    level = await TiledComponent.load('$levelName.tmx', Vector2.all(16));

    add(level);

    _scrollingBackground();
    _spawningObjects();
    _addCollisions();
    // _scaleLevelComponents();

    return super.onLoad();
  }

  void _scrollingBackground() {
    final backgroundLayer = level.tileMap.getLayer('Background');
    // const tileSize = 64.0; // Ensure tileSize is a double

    if (backgroundLayer != null) {
      final backgroundColor =
          backgroundLayer.properties.getValue("BackgroundColor");
      final backgroundTile = BackgroundTile(
          color: backgroundColor ?? 'Gray', position: Vector2(0, 0));
      add(backgroundTile);
    }
  }

  void _addCollisions() {
    final collisionLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');

    if (collisionLayer != null) {
      for (final collision in collisionLayer.objects) {
        switch (collision.class_) {
          case 'Platform':
            final platform = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
              isPlatform: true,
            );
            collisionBlocks.add(platform);
            add(platform);
            break;
          default:
            final block = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
            );
            collisionBlocks.add(block);
            add(block);
        }
      }
    }
    player.collisionBlocks = collisionBlocks;
  }

  void _spawningObjects() {
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('Spawnpoints');

    for (final spawnPoint in spawnPointsLayer!.objects) {
      // final spawnPoint = spawnPoint as TiledObject;
      switch (spawnPoint.class_) {
        case 'Player':
          print('Adding Player' + spawnPoint.name);
          player.position = Vector2(spawnPoint.x, spawnPoint.y);
          add(player);
          break;
        case 'Fruit':
          print('Adding Fruit' + spawnPoint.name);
          final fruit = Fruit(
            fruit: spawnPoint.name,
            position: Vector2(spawnPoint.x, spawnPoint.y),
            size: Vector2(spawnPoint.width, spawnPoint.height),
          );
          add(fruit);
          break;
        case 'Saw':
          final isVertical = spawnPoint.properties.getValue('isVertical');
          final offNeg = spawnPoint.properties.getValue('offNeg');
          final offPos = spawnPoint.properties.getValue('offPos');
          print("spawning saws at ${spawnPoint.x} and ${spawnPoint.y}");
          final saw = Saw(
              isVertical: isVertical,
              offNeg: offNeg,
              offPos: offPos,
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height));
          add(saw);
        case 'Checkpoint':
          final checkpoint = Checkpoint(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height));
          add(checkpoint);

        case 'Chicken':
          final offNeg = spawnPoint.properties.getValue('offNeg');
          final offPos = spawnPoint.properties.getValue('offPos');
          add(Chicken(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
              offNeg: offNeg,
              offPos: offPos));
          break;
        default:
          break;
      }
    }
  }
}
