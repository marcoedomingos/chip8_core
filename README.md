# chip8_core

A lightweight, performance-focused CHIP-8 emulator core written in Dart for Flutter applications.

## Features

- **Decoupled Logic**: The emulation core is pure Dart and independent of the UI.
- **Flutter Ready**: Includes a `Chip8` wrapper that integrates seamlessly with `ChangeNotifier` and `ListenableBuilder`.
- **Custom Painter**: Provides a `DisplayPainter` for high-performance rendering of the CHIP-8 display buffer.
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

### 3. Rendering
```dart
ListenableBuilder(
  listenable: chip8,
  builder: (context, _) {
    return CustomPaint(
      painter: DisplayPainter(chip: chip8),
      size: const Size(640, 320),
    );
  },
)
```

### 4. Input Handling
```dart
// To press a key
chip8.keyPad[keyIndex] = 1;

// To release a key
chip8.keyPad[keyIndex] = 0;
```

## Technical Specifications

- **Display**: 64x32 monochrome resolution.
- **Memory**: 4KB RAM.
- **Stack**: 16 levels.
- **Timers**: 60Hz delay and sound timers.
- **Execution**: ~600Hz baseline (10 cycles per 16ms frame).
