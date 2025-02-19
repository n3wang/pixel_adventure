import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/collision_block.dart';

class Level extends World {
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
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('SpawnPoints');

    for (final spawnPoint in spawnPointsLayer!.objects) {
      // final spawnPoint = spawnPoint as TiledObject;
      switch (spawnPoint.class_) {
        case 'Player':
          player.position = Vector2(spawnPoint.x, spawnPoint.y);
          add(player);
          break;
        default:
          break;
      }
    }

    final collisionLayer = level.tileMap.getLayer<ObjectGroup>('Collision');

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

    return super.onLoad();
  }
}
