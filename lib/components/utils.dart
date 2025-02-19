import 'package:pixel_adventure/components/player.dart';

// bool checkCollision(Player player, block) {
//   final playerX = player.position.x;
//   final playerY = player.position.y;
//   final playerWidth = player.width;
//   final playerHeight = player.height;

//   final blockX = block.x;
//   final blockY = block.y;
//   final blockWidth = block.width;
//   final blockHeight = block.height;

//   final fixeX = player.scale.x < 0 ? playerX - playerWidth : playerX;

//   return (playerY < blockY + blockHeight &&
//       playerY + playerHeight > blockY &&
//       playerX < blockX + blockWidth &&
//       playerX + playerWidth > blockX);
// }

bool checkCollision(Player player, block) {
  final hitbox = player.hitbox;
  final playerX = player.position.x + hitbox.offsetX;
  final playerY = player.position.y + hitbox.offsetY;
  final playerWidth = hitbox.width;
  final playerHeight = hitbox.height;

  final blockX = block.x;
  final blockY = block.y;
  final blockWidth = block.width;
  final blockHeight = block.height;

  // Fixing the mirror problems
  final fixedX = player.scale.x < 0
      ? playerX - (hitbox.offsetX * 2) - playerWidth
      : playerX;
  final fixedY = block.isPlatform ? playerY + playerHeight : playerY;

  return (fixedY < blockY + blockHeight &&
      playerY + playerHeight > blockY &&
      fixedX < blockX + blockWidth &&
      fixedX + playerWidth > blockX);
}
