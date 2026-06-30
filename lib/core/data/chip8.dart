import 'dart:async';
import 'package:chip8_core/core/data/processor.dart';
import 'package:flutter/material.dart';

class Chip8 extends Processor with ChangeNotifier {
  Timer? _timer;

  void parseRom(List<int> rom) {
    loadRom(rom);
    notifyListeners();
  }

  @override
  void init() {
    super.init();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 16), (t) {
      if (!isRunning) return;

      /// Chip8 runs at 500-700Hz.
      /// At 60fps (16ms), ~10 cycles per frame is a good baseline.
      for (int i = 0; i < 10; i++) {
        cycle();
      }
      updateTimers();
      notifyListeners();
    });
  }

  void stop() {
    isRunning = false;
    _timer?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
