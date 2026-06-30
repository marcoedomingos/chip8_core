import 'package:chip8_core/core/data/chip8.dart';
import 'package:flutter/material.dart';

class DisplayPainter extends CustomPainter {
  final Chip8 chip;

  DisplayPainter({required this.chip});

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFF000000);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final pixelPaint = Paint()..color = const Color(0xFFFFFFFF);

    // Calculate pixel size based on the available canvas size
    final double pixelWidth = size.width / 64;
    final double pixelHeight = size.height / 32;

    // Go through the display pixels and draw them
    for (int i = 0; i < chip.display.length; i++) {
      if (chip.display[i] == 1) {
        // Calculate the X and Y using the col as default
        final double x = (i % 64) * pixelWidth;
        final double y = (i ~/ 64) * pixelHeight;

        // Draw the result in the display
        canvas.drawRect(
          Rect.fromLTWH(x, y, pixelWidth, pixelHeight),
          pixelPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant DisplayPainter oldDelegate) => true;
}
