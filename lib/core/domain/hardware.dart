import 'dart:typed_data' show Uint8List, Uint16List;

int col = 64;
int row = 32;

abstract class Hardware {
  Uint16List ram = Uint16List(4096);
  Uint8List display = Uint8List(col*row);
  Uint8List keyPad = Uint8List(16);
}