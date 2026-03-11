import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:pixelpad/features/make/data/pixelpad_api_service.dart';

Future<ui.Image> renderPixelImage({
  required int width,
  required int height,
  required Uint16List mapping,
  required List<PaletteColorEntry> palette,
  required Uint8List bgMask,
  Set<int>? selectedIndices,
}) {
  if (width <= 0 || height <= 0) {
    throw Exception('invalid_size');
  }
  final int total = width * height;
  if (mapping.length != total) {
    throw Exception('mapping_size_mismatch');
  }
  if (bgMask.length != total) {
    throw Exception('bg_mask_size_mismatch');
  }

  final bool hasSelection =
      selectedIndices != null && selectedIndices.isNotEmpty;
  final Map<int, List<int>> paletteByIdx = <int, List<int>>{
    for (final PaletteColorEntry entry in palette)
      if (entry.idx > 0) entry.idx: entry.rgba,
  };
  final Uint8List rgba = Uint8List(total * 4);

  for (int i = 0; i < total; i += 1) {
    final int out = i * 4;
    if (bgMask[i] != 0) {
      rgba[out + 0] = 0;
      rgba[out + 1] = 0;
      rgba[out + 2] = 0;
      rgba[out + 3] = 0;
      continue;
    }

    final int paletteIdx = mapping[i];
    if (paletteIdx <= 0) {
      rgba[out + 0] = 0;
      rgba[out + 1] = 0;
      rgba[out + 2] = 0;
      rgba[out + 3] = 0;
      continue;
    }

    final List<int>? color = paletteByIdx[paletteIdx];
    if (color == null) {
      rgba[out + 0] = 0;
      rgba[out + 1] = 0;
      rgba[out + 2] = 0;
      rgba[out + 3] = 0;
      continue;
    }
    if (hasSelection && !selectedIndices.contains(paletteIdx)) {
      rgba[out + 0] = 0;
      rgba[out + 1] = 0;
      rgba[out + 2] = 0;
      rgba[out + 3] = 255;
      continue;
    }

    rgba[out + 0] = color.isNotEmpty ? color[0].clamp(0, 255).toInt() : 0;
    rgba[out + 1] = color.length > 1 ? color[1].clamp(0, 255).toInt() : 0;
    rgba[out + 2] = color.length > 2 ? color[2].clamp(0, 255).toInt() : 0;
    rgba[out + 3] = color.length > 3 ? color[3].clamp(0, 255).toInt() : 255;
  }

  final Completer<ui.Image> completer = Completer<ui.Image>();
  ui.decodeImageFromPixels(
    rgba,
    width,
    height,
    ui.PixelFormat.rgba8888,
    (ui.Image image) => completer.complete(image),
  );
  return completer.future;
}

Future<Uint8List?> imageToPngBytes(ui.Image image) async {
  final ByteData? data = await image.toByteData(format: ui.ImageByteFormat.png);
  if (data == null) {
    return null;
  }
  return data.buffer.asUint8List();
}

Future<Uint8List?> renderPixelPng({
  required int width,
  required int height,
  required Uint16List mapping,
  required List<PaletteColorEntry> palette,
  required Uint8List bgMask,
  Set<int>? selectedIndices,
}) async {
  final ui.Image image = await renderPixelImage(
    width: width,
    height: height,
    mapping: mapping,
    palette: palette,
    bgMask: bgMask,
    selectedIndices: selectedIndices,
  );
  try {
    return await imageToPngBytes(image);
  } finally {
    image.dispose();
  }
}
