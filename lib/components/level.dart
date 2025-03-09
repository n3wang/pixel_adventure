import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_adventure/components/background_tile.dart';
import 'package:pixel_adventure/components/bullet.dart';
import 'package:pixel_adventure/components/checkpoint.dart';
import 'package:pixel_adventure/components/chicken.dart';
import 'package:pixel_adventure/components/fruit.dart';
import 'package:pixel_adventure/components/gun.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/collision_block.dart';
import 'package:pixel_adventure/components/saw.dart';
import 'package:pixel_adventure/components/ui_component.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Level extends World with HasGameRef<PixelAdventure> {
  late TiledComponent level;
  final Player player1;
  final Player player2;
  final String levelName;
  final List<CollisionBlock> collisionBlocks = [];
  late Gun gun;

  Level(
      {this.levelName = 'level_1',
      required this.player1,
      required this.player2});

  @override
  Future<void> onLoad() async {
    // Add your components here

    level = await TiledComponent.load('$levelName.tmx', Vector2.all(16));

    add(level);

    _scrollingBackground();
    _spawningObjects();
    _addCollisions();
    // _scaleLevelComponents();
    _initializePlayerInventory(player1);
    _initializePlayerInventory(player2);

    add(UIComponent(player1: player1));
    return super.onLoad();
  }

  void _initializePlayerInventory(Player player) {
    // Add a gun to the player's inventory in slot 1
    player.inventory[0] = Gun(
      position: player.position + Vector2(0, 0), // Adjust position as needed
      size: Vector2(32, 32),
    );
  }

  void shoot(Player player) {
    final direction = player.isFacingRight ? Vector2(1, 0) : Vector2(-1, 0);
    final bulletPosition = player.position +
        Vector2(
            player.isFacingRight ? player.hitbox.width : -player.hitbox.width,
            player.hitbox.height / 2);
    final bullet = Bullet(
      shooterId: player.id,
      position: bulletPosition,
      direction: direction,
      speed: 300,
      size: Vector2(16, 16),
    );
    add(bullet);
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
    player1.collisionBlocks = collisionBlocks;
    player2.collisionBlocks = collisionBlocks;
  }

  void _spawningObjects() {
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('Spawnpoints');

    for (final spawnPoint in spawnPointsLayer!.objects) {
      // final spawnPoint = spawnPoint as TiledObject;
      switch (spawnPoint.class_) {
        case 'Player1':
          player1.position = Vector2(spawnPoint.x, spawnPoint.y);
          player1.level = this;
          add(player1);
          break;
        case 'Player2':
          player2.position = Vector2(spawnPoint.x, spawnPoint.y);
          player2.level = this;
          add(player2);
          break;
        case 'Fruit':
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
