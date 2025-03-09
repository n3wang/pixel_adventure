import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:pixel_adventure/components/player.dart';

class UIComponent extends PositionComponent {
  final Player player1;

  UIComponent({required this.player1});

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw health points
    final paint = Paint()..color = Colors.red;
    final healthBarWidth = 100.0;
    final healthBarHeight = 10.0;
    final healthPercentage = player1.life / player1.maxLife;
    canvas.drawRect(
      Rect.fromLTWH(10, 10, healthBarWidth * healthPercentage, healthBarHeight),
      paint,
    );

    // Draw bullet count
    final textPainter = TextPainter(
      text: TextSpan(
        text: ' ${player1.weapon!.messageInUI()}',
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(10, 30));
  }
}
