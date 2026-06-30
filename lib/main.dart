import 'package:chip8_core/features/display/display.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

import 'core/data/chip8.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Map<int, Timer?> _activeTimers = {};
  final FocusNode _focusNode = FocusNode();
  late final Chip8 chip8;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
    chip8 = Chip8();
    initApp().then((_) {
      chip8.init();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> initApp() async {
    // URL original do GitHub
    final url = Uri.parse(
      'https://github.com/kripod/chip8-roms/raw/refs/heads/master/games/Pong%20(1%20player).ch8',
    );

    try {
      // Faz a requisição dos bytes da ROM
      final resposta = await http.get(url);

      if (resposta.statusCode == 200) {
        // Como ROMs são binários, use resposta.bodyBytes (List<int>) em vez de texto (.body)
        final List<int> romBytes = resposta.bodyBytes;
        chip8.loadRom(romBytes);
      } else {
        print('Erro ao carregar: ${resposta.statusCode}');
      }
    } catch (e) {
      print('Erro na requisição: $e');
    }
  }

  void _pulseKey(int key) {
    chip8.keyPad[key] = 1;
    _activeTimers[key]?.cancel();
    _activeTimers[key] = Timer(const Duration(milliseconds: 80), () {
      chip8.keyPad[key] = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.red,
        body: Center(
          child: KeyboardListener(
            focusNode: _focusNode,
            onKeyEvent: (event) {
              Map<LogicalKeyboardKey, dynamic> keyMap = {
                LogicalKeyboardKey.digit1: 0x1,
                LogicalKeyboardKey.digit2: 0x2,
                LogicalKeyboardKey.digit3: 0x3,
                LogicalKeyboardKey.digit4: 0xC,
                LogicalKeyboardKey.keyQ: 0x4,
                LogicalKeyboardKey.keyW: 0x5,
                LogicalKeyboardKey.keyE: 0x6,
                LogicalKeyboardKey.keyR: 0xD,
                LogicalKeyboardKey.keyA: 0x7,
                LogicalKeyboardKey.keyS: 0x8,
                LogicalKeyboardKey.keyD: 0x9,
                LogicalKeyboardKey.keyF: 0xE,
                LogicalKeyboardKey.keyZ: 0xA,
                LogicalKeyboardKey.keyX: 0x0,
                LogicalKeyboardKey.keyC: 0xB,
                LogicalKeyboardKey.keyV: 0xF,
              };
              if (keyMap.containsKey(event.logicalKey)) {
                chip8.keyPad[keyMap[event.logicalKey]] = event is KeyDownEvent
                    ? 1
                    : 0;
              }
            },
            child: GestureDetector(
              behavior: HitTestBehavior.deferToChild,
              onPanUpdate: (details) {
                const deadzone = 1.0;
                if (details.delta.dy.abs() > deadzone) {
                  final key = details.delta.dy < 0 ? 0x1 : 0x4; // up / down
                  _pulseKey(key);
                }
              },
              child: SizedBox(
                width: 64 * 10, // Largura total escalada (640)
                height: 32 * 10, // Altura total escalada (320)
                child: ListenableBuilder(
                  listenable: chip8,
                  builder: (_, w) => SizedBox(
                    width: 64,
                    height: 32,
                    child: CustomPaint(painter: DisplayPainter(chip: chip8)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}