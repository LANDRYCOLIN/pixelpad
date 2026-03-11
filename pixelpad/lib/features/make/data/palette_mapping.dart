import 'dart:math' as math;
import 'dart:typed_data';

enum PaletteIndexBase { zeroBased, oneBased }

PaletteIndexBase resolvePaletteIndexBase({
  required Uint16List mapping,
  required int paletteLength,
  Uint8List? bgMask,
}) {
  if (paletteLength <= 0 || mapping.isEmpty) {
    return PaletteIndexBase.oneBased;
  }

  final bool hasAlignedMask = bgMask != null && bgMask.length == mapping.length;
  int visiblePixels = 0;
  int validZeroBased = 0;
  int validOneBased = 0;
  bool sawPaletteLength = false;

  for (int i = 0; i < mapping.length; i += 1) {
    if (hasAlignedMask && bgMask[i] != 0) {
      continue;
    }
    visiblePixels += 1;
    final int value = mapping[i];
    if (value >= 0 && value < paletteLength) {
      validZeroBased += 1;
    }
    if (value > 0 && value <= paletteLength) {
      validOneBased += 1;
    }
    if (value == paletteLength) {
      sawPaletteLength = true;
    }
  }

  if (validZeroBased == 0 && validOneBased > 0) {
    return PaletteIndexBase.oneBased;
  }
  if (validOneBased == 0 && validZeroBased > 0) {
    return PaletteIndexBase.zeroBased;
  }
  if (sawPaletteLength) {
    return PaletteIndexBase.oneBased;
  }
  if (visiblePixels <= 0) {
    return PaletteIndexBase.oneBased;
  }

  final double zeroRatio = validZeroBased / visiblePixels;
  final double oneRatio = validOneBased / visiblePixels;
  if (zeroRatio >= 0.95 && zeroRatio >= oneRatio + 0.08) {
    return PaletteIndexBase.zeroBased;
  }
  return PaletteIndexBase.oneBased;
}

int resolvePaletteIndex({
  required int mappingValue,
  required int paletteLength,
  required PaletteIndexBase indexBase,
}) {
  if (paletteLength <= 0) {
    return -1;
  }
  return switch (indexBase) {
    PaletteIndexBase.zeroBased =>
      (mappingValue >= 0 && mappingValue < paletteLength) ? mappingValue : -1,
    PaletteIndexBase.oneBased =>
      (mappingValue > 0 && mappingValue <= paletteLength)
          ? mappingValue - 1
          : -1,
  };
}

class PreviewInsets {
  final int left;
  final int top;
  final int right;
  final int bottom;

  const PreviewInsets({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });
}

List<PreviewInsets> matchingPreviewInsets({
  required List<int>? rawPadding,
  required int innerWidth,
  required int innerHeight,
  required int canvasWidth,
  required int canvasHeight,
}) {
  if (rawPadding == null || rawPadding.length < 4) {
    return const <PreviewInsets>[];
  }

  final List<int> values = rawPadding
      .take(4)
      .map((int value) => math.max(0, value))
      .toList(growable: false);

  final List<PreviewInsets> candidates = <PreviewInsets>[
    PreviewInsets(
      left: values[0],
      top: values[1],
      right: values[2],
      bottom: values[3],
    ),
    PreviewInsets(
      left: values[3],
      top: values[0],
      right: values[1],
      bottom: values[2],
    ),
  ];

  final List<PreviewInsets> matches = <PreviewInsets>[];
  for (final PreviewInsets candidate in candidates) {
    final bool matched =
        innerWidth + candidate.left + candidate.right == canvasWidth &&
        innerHeight + candidate.top + candidate.bottom == canvasHeight;
    final bool duplicate = matches.any(
      (PreviewInsets existing) =>
          existing.left == candidate.left &&
          existing.top == candidate.top &&
          existing.right == candidate.right &&
          existing.bottom == candidate.bottom,
    );
    if (matched && !duplicate) {
      matches.add(candidate);
    }
  }
  return matches;
}

PreviewInsets? resolvePreviewInsets({
  required List<int>? rawPadding,
  required int innerWidth,
  required int innerHeight,
  required int canvasWidth,
  required int canvasHeight,
}) {
  final List<PreviewInsets> matches = matchingPreviewInsets(
    rawPadding: rawPadding,
    innerWidth: innerWidth,
    innerHeight: innerHeight,
    canvasWidth: canvasWidth,
    canvasHeight: canvasHeight,
  );
  if (matches.isEmpty) {
    return null;
  }
  return matches.first;
}

int previewInsetsMaskPenalty({
  required Uint8List mask,
  required int innerWidth,
  required int innerHeight,
  required int canvasWidth,
  required int canvasHeight,
  required PreviewInsets insets,
}) {
  if (mask.length != canvasWidth * canvasHeight) {
    return 1 << 30;
  }

  int outsideForeground = 0;
  int insideBackground = 0;
  final int left = insets.left;
  final int top = insets.top;
  final int right = left + innerWidth;
  final int bottom = top + innerHeight;

  for (int y = 0; y < canvasHeight; y += 1) {
    for (int x = 0; x < canvasWidth; x += 1) {
      final bool inside = x >= left && x < right && y >= top && y < bottom;
      final int value = mask[y * canvasWidth + x];
      if (!inside && value == 0) {
        outsideForeground += 1;
      } else if (inside && value != 0) {
        insideBackground += 1;
      }
    }
  }

  return outsideForeground * 2 + insideBackground;
}

Uint16List expandMappingToCanvas({
  required Uint16List mapping,
  required int innerWidth,
  required int innerHeight,
  required int canvasWidth,
  required int canvasHeight,
  required PreviewInsets insets,
}) {
  if (innerWidth <= 0 ||
      innerHeight <= 0 ||
      canvasWidth <= 0 ||
      canvasHeight <= 0 ||
      mapping.length != innerWidth * innerHeight) {
    return mapping;
  }

  final Uint16List expanded = Uint16List(canvasWidth * canvasHeight);
  for (int y = 0; y < innerHeight; y += 1) {
    final int srcRow = y * innerWidth;
    final int destRow = (y + insets.top) * canvasWidth + insets.left;
    for (int x = 0; x < innerWidth; x += 1) {
      expanded[destRow + x] = mapping[srcRow + x];
    }
  }
  return expanded;
}

Uint8List expandMaskToCanvas({
  required Uint8List mask,
  required int innerWidth,
  required int innerHeight,
  required int canvasWidth,
  required int canvasHeight,
  required PreviewInsets insets,
  int padValue = 1,
}) {
  if (innerWidth <= 0 ||
      innerHeight <= 0 ||
      canvasWidth <= 0 ||
      canvasHeight <= 0 ||
      mask.length != innerWidth * innerHeight) {
    return mask;
  }

  final Uint8List expanded = Uint8List(canvasWidth * canvasHeight);
  if (padValue != 0) {
    expanded.fillRange(0, expanded.length, padValue.clamp(0, 255));
  }
  for (int y = 0; y < innerHeight; y += 1) {
    final int srcRow = y * innerWidth;
    final int destRow = (y + insets.top) * canvasWidth + insets.left;
    for (int x = 0; x < innerWidth; x += 1) {
      expanded[destRow + x] = mask[srcRow + x];
    }
  }
  return expanded;
}
