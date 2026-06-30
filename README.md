# chip8_core

A lightweight, performance-focused CHIP-8 emulator core written in Dart for Flutter applications.

## Features

- **Decoupled Logic**: The emulation core is pure Dart and independent of the UI.
- **Flutter Ready**: Includes a `Chip8` wrapper that integrates seamlessly with `ChangeNotifier` and `ListenableBuilder`.
- **Custom Painter**: Provides a `DisplayPainter` for high-performance rendering of the CHIP-8 display buffer.
- **Configurable Speed**: Easily adjust emulation frequency by changing the cycles per frame.
- **Audio Feedback**: Built-in support for detecting when the sound timer is active.
- **Clean Architecture**: Organized as a standard Dart package for easy integration and maintenance.

## Architecture

The project follows a simplified package-centric architecture:
- `lib/chip8.dart`: Public API surface.
- `lib/src/emulator/`: Core `Processor` logic and the Flutter-ready `Chip8` engine.
- `lib/src/widgets/`: UI components like `DisplayPainter`.

## Usage

### 1. Initialization
```dart
import 'package:chip8_core/chip8.dart';

final chip8 = Chip8();
chip8.init();
```

### 2. Loading a ROM
```dart
List<int> romBytes = ... // Fetch your ROM bytes
chip8.loadRom(romBytes);
```

### 3. Adjusting Speed & Resetting
```dart
// Increase speed (default is 10)
chip8.cyclesPerFrame = 20;

// Reset the machine state
chip8.reset();
```

### 4. Rendering & Audio
```dart
ListenableBuilder(
  listenable: chip8,
  builder: (context, _) {
    // Check if we should play a beep sound
    if (chip8.isSoundActive) {
      // Trigger your audio plugin here
    }

    return CustomPaint(
      painter: DisplayPainter(chip: chip8),
      size: const Size(640, 320),
    );
  },
)
```

### 5. Input Handling
```dart
// To press a key
chip8.keyPad[keyIndex] = 1;

// To release a key
chip8.keyPad[keyIndex] = 0;
```

## Technical Specifications

- **Display**: 64x32 monochrome resolution.
- **Memory**: 4KB RAM (Uint8List).
- **Stack**: 16 levels.
- **Timers**: 60Hz delay and sound timers.
- **Execution**: Configurable (default ~600Hz / 10 cycles per 16ms frame).
