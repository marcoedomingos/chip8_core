import 'package:chip8_core/core/data/chip8.dart';
import 'package:flutter/material.dart';

class DisplayPainter extends CustomPainter {
  final Chip8 chip;

  DisplayPainter({required this.chip});

  @override
  void paint(Canvas canvas, Size size) => chip.output(canvas, size);

  @override
  bool shouldRepaint(covariant DisplayPainter oldDelegate) => true;
}
