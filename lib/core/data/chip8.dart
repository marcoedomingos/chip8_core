import 'dart:async';

import 'package:chip8_core/core/data/processor.dart';
import 'package:flutter/material.dart';

class Chip8 extends Processor with ChangeNotifier {
  void parseRom(List<int> rom) {
    loadRom;
    notifyListeners();
  }

  @override
  void init() {
    super.init();
    Timer.periodic(Duration(milliseconds: 16), (t) {
      for (int i = 0; i < 10; i++) {
        cycle();
      }
      updateTimers();
      notifyListeners();
    });
  }

  void displayOutPut(Canvas canvas, Size size) => output;
}
