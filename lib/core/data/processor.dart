import 'package:chip8_core/core/domain/hardware.dart';
import 'package:chip8_core/core/domain/software.dart';

class Processor extends Hardware with Software {
  bool isRunning = false;


  void init(){
    loadFonts();
    isRunning = true;
  }

  void loadFonts() {
    /// This will set the fonts to our memory
    for (int i = 0; i < fonts.length; i++) {
      ram[i] = fonts[i];
    }
  }

  void loadRom(List<int> data){
    /// Add each 16 bits into the memory
    for (int i = 0; i < data.length; i++) {
      ram[esp+i] = data[i];
    }
  }

  void cycle() {
    try {
      if (!isRunning) return;

      /// Chip8 opcode is a 16bits instruction, meaning the we need to 2 bytes
      /// from the memory to get full insctruction block.
      final byte1 = _readMem(executionPointer);
      final byte2 = _readMem(executionPointer + 1);
      final opcode = (byte1 << 8) | byte2;

      /// Now that we have our opcode, we can set our executionPointer into the next
      /// instruction
      executionPointer += 2;

      /// This will decode the full opcode by separating into small bits
      /// it will be niddles of 4 bits that are called niddles
      /// the F represent a bite to count
      final niddle12 = (opcode & 0x0FFF);
      final niddle8 = (opcode & 0x00FF);
      final niddle4 = opcode & 0x000F;
      final secondNiddle = (opcode & 0x0F00) >> 8;
      final thirdNiddle = (opcode & 0x00F0) >> 4;
      final firstNiddle = (opcode & 0xF000) >> 12;

      /// Since we have the opcode(instruction), we should be able to match it
      /// With the right exection

      switch (opcode) {
        case 0x00E0:
          display.fillRange(0, display.length, 0);
          break;
        case 0x00EE:
          stackPointer--;
          executionPointer = stack[stackPointer];
          break;

        default:
          switch (firstNiddle) {
            case 0x1:
              executionPointer = niddle12;
              break;
            case 0x2:
              stack[stackPointer] = executionPointer;
              stackPointer++;
              executionPointer = niddle12;
              break;
            case 0x3:
              if (flags[secondNiddle] == niddle8) {
                executionPointer += 2;
              }
              break;
            case 0x4:
              if (flags[secondNiddle] != niddle8) {
                executionPointer += 2;
              }
              break;
            case 0x5:
              if (flags[secondNiddle] == flags[thirdNiddle]) {
                executionPointer += 2;
              }
              break;
            case 0x6:
              flags[secondNiddle] = niddle8;
              break;
            case 0x7:
              flags[secondNiddle] =
              (flags[secondNiddle] + niddle8) & 0xFF;
              break;
            case 0x8:
              switch (niddle4) {
                case 0x0:
                  flags[secondNiddle] = flags[thirdNiddle];
                  break;
                case 0x1:
                  flags[secondNiddle] =
                  flags[secondNiddle] | flags[thirdNiddle];
                  break;
                case 0x2:
                  flags[secondNiddle] =
                  flags[secondNiddle] & flags[thirdNiddle];
                  break;
                case 0x3:
                  flags[secondNiddle] =
                  flags[secondNiddle] ^ flags[thirdNiddle];
                  break;
                case 0x4:
                  final result =
                      flags[secondNiddle] + flags[thirdNiddle];
                  final carry = result > 0xFF ? 1 : 0;

                  flags[secondNiddle] = result & 0xFF;
                  flags[0xF] = carry;
                  break;
                case 0x5:
                  final carry =
                  flags[secondNiddle] >= flags[thirdNiddle] ? 1 : 0;
                  flags[secondNiddle] =
                  (flags[secondNiddle] - flags[thirdNiddle]) & 0xFF;
                  flags[0xF] = carry;
                  break;
                case 0x6:
                  final carry = flags[secondNiddle] & 0x1;
                  flags[secondNiddle] =
                  (flags[secondNiddle] ~/ 2) & 0xFF;
                  flags[0xF] = carry;
                  break;
                case 0x7:
                  final carry =
                  flags[thirdNiddle] >= flags[secondNiddle] ? 1 : 0;
                  flags[secondNiddle] =
                  (flags[thirdNiddle] - flags[secondNiddle]) & 0xFF;
                  flags[0xF] = carry;
                  break;
                case 0xE:
                  final carry = (flags[secondNiddle] & 0x80) >> 7;
                  flags[secondNiddle] =
                  (flags[secondNiddle] * 2) & 0xFF;
                  flags[0xF] = carry;
                  break;
              }
              break;
            case 0x9: // 9XY0: Skip next instruction if VX != VY
              if (flags[secondNiddle] != flags[thirdNiddle]) {
                executionPointer += 2;
              }
              break;
            case 0xA:
              index = niddle12;
              break;
            case 0xB: // BNNN: Jump to V0 + NNN
              executionPointer = flags[0] + niddle12;
              break;
            case 0xC: // CXNN: VX = random byte AND NN
              final randomByte =
              DateTime.now().microsecondsSinceEpoch &
              0xFF; // Simple standard seed fallback
              flags[secondNiddle] = randomByte & niddle8;
              break;
            case 0xD: // DXYN: Draw sprite
              final x = flags[secondNiddle];
              final y = flags[thirdNiddle];
              final height = niddle4;
              flags[0xF] = 0;
              for (int row = 0; row < height; row++) {
                // PROTEÇÃO
                if (index + row >= ram.length) {
                  throw Exception(
                    'Sprite read out of bounds: I=$index row=$row',
                  );
                }

                final spriteByte = _readMem(index + row);

                for (int col = 0; col < 8; col++) {
                  if ((spriteByte & (0x80 >> col)) != 0) {
                    final pixelX = (x + col) % 64;
                    final pixelY = (y + row) % 32;
                    final pixelIndex = pixelX + pixelY * 64;

                    if (display[pixelIndex] == 1) {
                      flags[0xF] = 1;
                    }

                    display[pixelIndex] ^= 1;
                  }
                }
              }
              break;
            case 0xE:
              switch (niddle8) {
                case 0x9E: // EX9E: Skip next instruction if key in VX is pressed
                  if (keyPad[flags[secondNiddle]] == 1) {
                    executionPointer += 2;
                  }
                  break;
                case 0xA1: // EXA1: Skip next instruction if key in VX isn't pressed
                  if (keyPad[flags[secondNiddle]] == 0) {
                    executionPointer += 2;
                  }
                  break;
              }
              break;
            case 0xF:
              switch (niddle8) {
                case 0x07: // FX07: Set VX to current delay timer
                  flags[secondNiddle] = delayTimer;
                  break;
                case 0x0A: // FX0A: Await keypress (blocking)
                  bool keyPressed = false;
                  for (int i = 0; i < keyPad.length; i++) {
                    if (keyPad[i] == 1) {
                      flags[secondNiddle] = i;
                      keyPressed = true;
                      break;
                    }
                  }
                  if (!keyPressed) {
                    executionPointer -=
                    2; // Keep repeating this instruction until key is pressed
                  }
                  break;
                case 0x15: // FX15: Set delay timer to VX
                  delayTimer = flags[secondNiddle];
                  break;
                case 0x18: // FX18: Set sound timer to VX
                  soundTimer = flags[secondNiddle];
                  break;
                case 0x1E: // FX1E: Add VX to index
                  index = (index + flags[secondNiddle]) & 0xFFFF;
                  break;
                case 0x29: // FX29: Set index to character sprite location
                  flags[0xF] = 0;
                  index =
                      flags[secondNiddle] *
                          5; // Standard CHIP-8 font uses 5 bytes per char
                  break;
                case 0x33: // FX33: Store BCD representation of VX at Index
                  final value = flags[secondNiddle];
                  _writeMem(index, value ~/ 100);
                  _writeMem(index + 1, (value ~/ 10) % 10);
                  _writeMem(index + 2, value % 10);
                  break;
                case 0x55: // FX55: Dump V0 to VX flags into memory starting at index
                  for (int i = 0; i <= secondNiddle; i++) {
                    _writeMem(index + i, flags[i]);
                  }
                  break;
                case 0x65: // FX65: Load registers V0 to VX from memory starting at index
                  for (int i = 0; i <= secondNiddle; i++) {
                    flags[i] = _readMem(index + i);
                  }
                  break;
              }
              break;
          }
          break;
      }
    } catch (e) {
      isRunning = false;
    }
  }

  int _readMem(int addr) {
    return ram[addr];
  }

  void _writeMem(int addr, int value) {
    ram[addr] = value & 0xFF;
  }

  void updateTimers() {
    if (delayTimer > 0) {
      delayTimer--;
    }
    if (soundTimer > 0) {
      soundTimer--;
    }
  }
}