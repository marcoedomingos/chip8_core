import 'dart:math';
import 'dart:typed_data';

class Processor {
  static const int width = 64;
  static const int height = 32;
  static const int romStart = 0x200;

  final Random _random = Random();

  final Uint8List ram = Uint8List(4096);
  final Uint8List display = Uint8List(width * height);
  final Uint8List keyPad = Uint8List(16);

  final Uint8List flags = Uint8List(16);
  int index = 0;
  int executionPointer = romStart;
  int stackPointer = 0;
  final Uint16List stack = Uint16List(16);
  int delayTimer = 0;
  int soundTimer = 0;

  bool isRunning = false;

  /// Returns true if the sound timer is active.
  bool get isSoundActive => soundTimer > 0;

  static const List<int> fontSet = [
    0xF0, 0x90, 0x90, 0x90, 0xF0,
    0x20, 0x60, 0x20, 0x20, 0x70,
    0xF0, 0x10, 0xF0, 0x80, 0xF0,
    0xF0, 0x10, 0xF0, 0x10, 0xF0,
    0x90, 0x90, 0xF0, 0x10, 0x10,
    0xF0, 0x80, 0xF0, 0x10, 0xF0,
    0xF0, 0x80, 0xF0, 0x90, 0xF0,
    0xF0, 0x10, 0x20, 0x40, 0x40,
    0xF0, 0x90, 0xF0, 0x90, 0xF0,
    0xF0, 0x90, 0xF0, 0x10, 0xF0,
    0xF0, 0x90, 0xF0, 0x90, 0x90,
    0xE0, 0x90, 0xE0, 0x90, 0xE0,
    0xF0, 0x80, 0x80, 0x80, 0xF0,
    0xE0, 0x90, 0x90, 0x90, 0xE0,
    0xF0, 0x80, 0xF0, 0x80, 0xF0,
    0xF0, 0x80, 0xF0, 0x80, 0x80,
  ];

  void init() {
    reset();
    isRunning = true;
  }

  /// Resets the emulator state to default.
  void reset() {
    ram.fillRange(0, ram.length, 0);
    display.fillRange(0, display.length, 0);
    flags.fillRange(0, flags.length, 0);
    keyPad.fillRange(0, keyPad.length, 0);
    stack.fillRange(0, stack.length, 0);
    
    index = 0;
    executionPointer = romStart;
    stackPointer = 0;
    delayTimer = 0;
    soundTimer = 0;

    /// This will set the fonts to our memory
    for (int i = 0; i < fontSet.length; i++) {
      ram[i] = fontSet[i];
    }
  }

  void loadRom(List<int> data) {
    /// Add each 16 bits into the memory
    for (int i = 0; i < data.length; i++) {
      if (romStart + i >= ram.length) break;
      ram[romStart + i] = data[i];
    }
  }

  void cycle() {
    if (!isRunning) return;

    /// Chip8 opcode is a 16bits instruction, meaning the we need to 2 bytes
    /// from the memory to get full insctruction block.
    final opcode = (ram[executionPointer] << 8) | ram[executionPointer + 1];

    /// Now that we have our opcode, we can set our executionPointer into the next
    /// instruction
    executionPointer += 2;

    /// This will decode the full opcode by separating into small bits
    /// it will be nibbles of 4 bits that are called nibbles
    /// the F represent a bite to count
    final n12 = (opcode & 0x0FFF);
    final n8 = (opcode & 0x00FF);
    final n4 = opcode & 0x000F;
    final x = (opcode & 0x0F00) >> 8;
    final y = (opcode & 0x00F0) >> 4;
    final first = (opcode & 0xF000) >> 12;

    /// Since we have the opcode(instruction), we should be able to match it
    /// With the right exection
    switch (first) {
      case 0x0:
        if (opcode == 0x00E0) display.fillRange(0, display.length, 0);
        if (opcode == 0x00EE) executionPointer = stack[--stackPointer];
        break;
      case 0x1: executionPointer = n12; break;
      case 0x2:
        stack[stackPointer++] = executionPointer;
        executionPointer = n12;
        break;
      case 0x3: if (flags[x] == n8) executionPointer += 2; break;
      case 0x4: if (flags[x] != n8) executionPointer += 2; break;
      case 0x5: if (flags[x] == flags[y]) executionPointer += 2; break;
      case 0x6: flags[x] = n8; break;
      case 0x7: flags[x] = (flags[x] + n8) & 0xFF; break;
      case 0x8: _handleArithmetic(n4, x, y); break;
      case 0x9: if (flags[x] != flags[y]) executionPointer += 2; break;
      case 0xA: index = n12; break;
      case 0xB: executionPointer = flags[0] + n12; break;
      case 0xC: flags[x] = _random.nextInt(256) & n8; break;
      case 0xD: _drawSprite(flags[x], flags[y], n4); break;
      case 0xE:
        if (n8 == 0x9E && keyPad[flags[x]] == 1) executionPointer += 2;
        if (n8 == 0xA1 && keyPad[flags[x]] == 0) executionPointer += 2;
        break;
      case 0xF: _handleMisc(n8, x); break;
    }
  }

  void _handleArithmetic(int type, int x, int y) {
    switch (type) {
      case 0x0: flags[x] = flags[y]; break;
      case 0x1: flags[x] |= flags[y]; break;
      case 0x2: flags[x] &= flags[y]; break;
      case 0x3: flags[x] ^= flags[y]; break;
      case 0x4:
        final sum = flags[x] + flags[y];
        flags[0xF] = sum > 0xFF ? 1 : 0;
        flags[x] = sum & 0xFF;
        break;
      case 0x5:
        flags[0xF] = flags[x] >= flags[y] ? 1 : 0;
        flags[x] = (flags[x] - flags[y]) & 0xFF;
        break;
      case 0x6:
        flags[0xF] = flags[x] & 0x1;
        flags[x] >>= 1;
        break;
      case 0x7:
        flags[0xF] = flags[y] >= flags[x] ? 1 : 0;
        flags[x] = (flags[y] - flags[x]) & 0xFF;
        break;
      case 0xE:
        flags[0xF] = (flags[x] & 0x80) >> 7;
        flags[x] = (flags[x] << 1) & 0xFF;
        break;
    }
  }

  void _drawSprite(int xPos, int yPos, int h) {
    flags[0xF] = 0;
    for (int r = 0; r < h; r++) {
      final sprite = ram[index + r];
      for (int c = 0; c < 8; c++) {
        if ((sprite & (0x80 >> c)) != 0) {
          final px = (xPos + c) % width;
          final py = (yPos + h) % height;
          final idx = px + py * width;
          if (display[idx] == 1) flags[0xF] = 1;
          display[idx] ^= 1;
        }
      }
    }
  }

  void _handleMisc(int type, int x) {
    switch (type) {
      case 0x07: flags[x] = delayTimer; break;
      case 0x0A:
        int key = keyPad.indexOf(1);
        if (key == -1) executionPointer -= 2; else flags[x] = key;
        break;
      case 0x15: delayTimer = flags[x]; break;
      case 0x18: soundTimer = flags[x]; break;
      case 0x1E: index = (index + flags[x]) & 0xFFFF; break;
      case 0x29: index = flags[x] * 5; break;
      case 0x33:
        ram[index] = flags[x] ~/ 100;
        ram[index + 1] = (flags[x] ~/ 10) % 10;
        ram[index + 2] = flags[x] % 10;
        break;
      case 0x55: for (int i = 0; i <= x; i++) ram[index + i] = flags[i]; break;
      case 0x65: for (int i = 0; i <= x; i++) flags[i] = ram[index + i]; break;
    }
  }

  void updateTimers() {
    if (delayTimer > 0) delayTimer--;
    if (soundTimer > 0) soundTimer--;
  }
}
