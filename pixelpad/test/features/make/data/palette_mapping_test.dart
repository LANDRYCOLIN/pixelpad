import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pixelpad/features/make/data/palette_mapping.dart';

void main() {
  group('resolvePaletteIndexBase', () {
    test('keeps one-based mapping when palette max index is present', () {
      final PaletteIndexBase base = resolvePaletteIndexBase(
        mapping: Uint16List.fromList(<int>[1, 2, 3]),
        paletteLength: 3,
      );

      expect(base, PaletteIndexBase.oneBased);
      expect(
        resolvePaletteIndex(mappingValue: 3, paletteLength: 3, indexBase: base),
        2,
      );
    });

    test(
      'switches to zero-based mapping when one-based would drop many pixels',
      () {
        final PaletteIndexBase base = resolvePaletteIndexBase(
          mapping: Uint16List.fromList(<int>[
            0,
            0,
            0,
            1,
            1,
            2,
            2,
            3,
            3,
            4,
            4,
            0,
          ]),
          paletteLength: 5,
        );

        expect(base, PaletteIndexBase.zeroBased);
        expect(
          resolvePaletteIndex(
            mappingValue: 0,
            paletteLength: 5,
            indexBase: base,
          ),
          0,
        );
      },
    );
  });

  group('preview padding expansion', () {
    test('supports left-top-right-bottom padding payloads', () {
      final PreviewInsets? insets = resolvePreviewInsets(
        rawPadding: <int>[2, 1, 3, 4],
        innerWidth: 5,
        innerHeight: 6,
        canvasWidth: 10,
        canvasHeight: 11,
      );

      expect(insets, isNotNull);
      expect(insets!.left, 2);
      expect(insets.top, 1);
      expect(insets.right, 3);
      expect(insets.bottom, 4);
    });

    test('supports top-right-bottom-left padding payloads', () {
      final PreviewInsets? insets = resolvePreviewInsets(
        rawPadding: <int>[1, 2, 3, 4],
        innerWidth: 5,
        innerHeight: 6,
        canvasWidth: 11,
        canvasHeight: 10,
      );

      expect(insets, isNotNull);
      expect(insets!.left, 4);
      expect(insets.top, 1);
      expect(insets.right, 2);
      expect(insets.bottom, 3);
    });

    test('expands mapping and mask into the padded preview canvas', () {
      const PreviewInsets insets = PreviewInsets(
        left: 1,
        top: 1,
        right: 0,
        bottom: 0,
      );
      final Uint16List expandedMapping = expandMappingToCanvas(
        mapping: Uint16List.fromList(<int>[7, 8, 9, 10]),
        innerWidth: 2,
        innerHeight: 2,
        canvasWidth: 3,
        canvasHeight: 3,
        insets: insets,
      );
      final Uint8List expandedMask = expandMaskToCanvas(
        mask: Uint8List.fromList(<int>[0, 1, 1, 0]),
        innerWidth: 2,
        innerHeight: 2,
        canvasWidth: 3,
        canvasHeight: 3,
        insets: insets,
      );

      expect(
        expandedMapping,
        Uint16List.fromList(<int>[0, 0, 0, 0, 7, 8, 0, 9, 10]),
      );
      expect(
        expandedMask,
        Uint8List.fromList(<int>[1, 1, 1, 1, 0, 1, 1, 1, 0]),
      );
    });
  });
}
