# chip8_core

A lightweight, performance-focused CHIP-8 emulator core written in Dart for Flutter applications.

## Features

- **Decoupled Logic**: The emulation core is pure Dart and independent of the UI.
- **Flutter Ready**: Includes a `Chip8` wrapper that integrates seamlessly with `ChangeNotifier` and `ListenableBuilder`.
- **Custom Painter**: Provides a `DisplayPainter` for high-performance rendering of the CHIP-8 display buffer.
- **Configurable Speed**: Easily adjust emulation frequency by changing the cycles per frame.
- **Audio Feedback**: Built-in support for detecting when the sound timer is active.
- **Robustness**: Includes memory wrapping and bounds checking to prevent crashes even with buggy ROMs.
- **Clean Architecture**: Organized as a standard Dart package for easy integration and maintenance.

## Architecture

The project follows a simplified package-centric architecture:
- `lib/chip8.dart`: Public API surface.
- `lib/src/emulator/`: Core `Processor` logic and the Flutter-ready `Chip8` engine.
- `lib/src/widgets/`: UI components like `DisplayPainter`.

## Usage

### 1. Initialization & Loading
```dart
import 'package:chip8_core/chip8.dart';

final chip8 = Chip8();

// Load your ROM bytes
chip8.loadRom(romBytes);

// Initialize fonts and start the internal timer
chip8.init();
```

### 2. Adjusting Speed & Resetting
```dart
// Increase speed (default is 10 cycles per frame)
chip8.cyclesPerFrame = 20;

// Reset the machine state (RAM, registers, display)
chip8.reset();
```

### 3. Rendering & Audio
```dart
ListenableBuilder(
  listenable: chip8,
  builder: (context, _) {
    // Check if the emulator is signaling for sound
    if (chip8.isSoundActive) {
      // Trigger your audio feedback here
    }

    return CustomPaint(
      painter: DisplayPainter(chip: chip8),
      size: const Size(640, 320),
    );
  },
)
```

### 4. Input Handling
```dart
// Map your UI buttons or keys to the 16 CHIP-8 keys (0x0 - 0xF)
chip8.keyPad[keyIndex] = 1; // Key down
chip8.keyPad[keyIndex] = 0; // Key up
```

## Technical Specifications

- **Display**: 64x32 monochrome resolution.
- **Memory**: 4KB RAM (Uint8List) with automatic address wrapping.
- **Stack**: 16 levels with overflow protection.
- **Timers**: 60Hz delay and sound timers.
- **Execution**: Configurable (default ~600Hz / 10 cycles per 16ms frame).
