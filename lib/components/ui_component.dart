import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:pixel_adventure/components/player.dart';

class UIComponent extends PositionComponent {
  final Player player1;
  final Player? player2;

  // Constants
  static const double healthBarWidth = 80.0;
  static const double healthBarHeight = 5.0;
  static const double padding = 5.0;
  static const double textFontSize = 8.0;
  static const double spacing = 20.0;

  UIComponent({required this.player1, this.player2});

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw health points for player1
    final paint = Paint()..color = Colors.red;
    final healthPercentage1 = player1.life / player1.maxLife;
    canvas.drawRect(
      Rect.fromLTWH(padding, padding, healthBarWidth * healthPercentage1,
          healthBarHeight),
      paint,
    );

    // Draw bullet count for player1
    final textPainter1 = TextPainter(
      text: TextSpan(
        text: ' ${player1.weapon!.messageInUI()}',
        style: TextStyle(color: Colors.white, fontSize: textFontSize),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter1.layout();
    textPainter1.paint(
        canvas, Offset(padding, padding + healthBarHeight + spacing));

    // Draw health points and bullet count for player2 if available
    if (player2 != null) {
      final healthPercentage2 = player2!.life / player2!.maxLife;
      canvas.drawRect(
        Rect.fromLTWH(padding + healthBarWidth + spacing, padding,
            healthBarWidth * healthPercentage2, healthBarHeight),
        paint,
      );

      // Draw bullet count for player2
      final textPainter2 = TextPainter(
        text: TextSpan(
          text: ' ${player2!.weapon!.messageInUI()}',
          style: TextStyle(color: Colors.white, fontSize: textFontSize),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter2.layout();
      textPainter2.paint(
          canvas,
          Offset(padding + healthBarWidth + spacing,
              padding + healthBarHeight + spacing));
    }
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    size = gameSize;
  }
}
