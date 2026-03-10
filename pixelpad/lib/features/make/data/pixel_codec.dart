import 'dart:convert';
import 'dart:typed_data';

Uint8List decodeRgbaU8(String base64Value) {
  if (base64Value.isEmpty) {
    return Uint8List(0);
  }
  return base64Decode(base64Value);
}

Uint16List decodeMappingU16le(String base64Value) {
  if (base64Value.isEmpty) {
    return Uint16List(0);
  }
  final Uint8List bytes = base64Decode(base64Value);
  final int valueCount = bytes.length ~/ 2;
  final Uint16List mapping = Uint16List(valueCount);
  final ByteData data = ByteData.sublistView(bytes);
  for (int i = 0; i < valueCount; i += 1) {
    mapping[i] = data.getUint16(i * 2, Endian.little);
  }
  return mapping;
}

Uint8List decodeRleMask(String rleBase64, bool startValue, int totalPixels) {
  if (totalPixels <= 0 || rleBase64.isEmpty) {
    return Uint8List(totalPixels > 0 ? totalPixels : 0);
  }

  final Uint8List bytes = base64Decode(rleBase64);
  final int runCount = bytes.length ~/ 4;
  final ByteData data = ByteData.sublistView(bytes);
  final Uint8List mask = Uint8List(totalPixels);

  int cursor = 0;
  bool current = startValue;
  for (int i = 0; i < runCount && cursor < totalPixels; i += 1) {
    int length = data.getUint32(i * 4, Endian.little);
    if (length <= 0) {
      current = !current;
      continue;
    }
    if (cursor + length > totalPixels) {
      length = totalPixels - cursor;
    }
    if (current) {
      mask.fillRange(cursor, cursor + length, 1);
    }
    cursor += length;
    current = !current;
  }

  return mask;
}

Uint8List alignMaskToExpectedOrZero({
  required Uint8List decodedMask,
  required int expectedPixels,
}) {
  if (expectedPixels <= 0) {
    return Uint8List(0);
  }
  if (decodedMask.length == expectedPixels) {
    return decodedMask;
  }
  return Uint8List(expectedPixels);
}
