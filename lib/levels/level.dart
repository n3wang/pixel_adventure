import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_adventure/components/player.dart';

class Level extends World {
  late TiledComponent level;
  final Player player;
  final String levelName;

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

    // add(Player(
    //     // character: 'Ninja Frog',
    //     character: 'Pink Man'));

    return super.onLoad();
  }
}
