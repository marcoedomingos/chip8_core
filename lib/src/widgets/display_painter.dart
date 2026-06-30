import 'package:flutter/material.dart';
import '../emulator/chip8.dart';
import '../emulator/processor.dart';

class DisplayPainter extends CustomPainter {
  final Chip8 chip;

  DisplayPainter({required this.chip});

  @override
  void paint(Canvas canvas, Size size) {
    // Drwa the pixels in white
    final bgPaint = Paint()..color = const Color(0xFF000000);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final pixelPaint = Paint()..color = const Color(0xFFFFFFFF);

    final double pixelWidth = size.width / Processor.width;
    final double pixelHeight = size.height / Processor.height;

    // Go through the pixels
    for (int i = 0; i < chip.display.length; i++) {
      if (chip.display[i] == 1) {
        // Calculte the X and Y using the col as default
        final double x = (i % Processor.width) * pixelWidth;
        final double y = (i ~/ Processor.width) * pixelHeight;

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
