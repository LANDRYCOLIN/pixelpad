import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:pixelpad/features/make/data/pixel_codec.dart';
import 'package:pixelpad/features/make/data/pixelpad_api_service.dart';
import 'package:pixelpad/features/make/data/pixel_renderer.dart';

void main() {
  group('Mask alignment', () {
    test('falls back to all-zero mask when decoded mask size mismatches', () {
      final Uint8List decoded = Uint8List(50 * 52);
      decoded[0] = 1;
      decoded[decoded.length - 1] = 1;

      final Uint8List aligned = alignMaskToExpectedOrZero(
        decodedMask: decoded,
        expectedPixels: 52 * 52,
      );

      expect(aligned.length, 52 * 52);
      expect(aligned.every((int value) => value == 0), isTrue);
    });

    test('keeps decoded mask when size already matches expected pixels', () {
      final Uint8List decoded = Uint8List.fromList(<int>[0, 1, 0, 1]);
      final Uint8List aligned = alignMaskToExpectedOrZero(
        decodedMask: decoded,
        expectedPixels: 4,
      );

      expect(identical(aligned, decoded), isTrue);
    });
  });

  group('Pixel renderer strict size checks', () {
    test('throws when mapping length is not exactly width*height', () {
      expect(
        () => renderPixelImage(
          width: 2,
          height: 2,
          mapping: Uint16List.fromList(<int>[1, 1, 1, 1, 1]),
          palette: <PaletteColorEntry>[
            PaletteColorEntry(
              idx: 1,
              id: 'H2',
              count: 4,
              rgba: <int>[255, 255, 255, 255],
              hex: '#ffffff',
            ),
          ],
          bgMask: Uint8List.fromList(<int>[0, 0, 0, 0]),
        ),
        throwsA(
          predicate(
            (Object e) => e.toString().contains('mapping_size_mismatch'),
          ),
        ),
      );
    });

    test('throws when bgMask length is not exactly width*height', () {
      expect(
        () => renderPixelImage(
          width: 2,
          height: 2,
          mapping: Uint16List.fromList(<int>[1, 1, 1, 1]),
          palette: <PaletteColorEntry>[
            PaletteColorEntry(
              idx: 1,
              id: 'H2',
              count: 4,
              rgba: <int>[255, 255, 255, 255],
              hex: '#ffffff',
            ),
          ],
          bgMask: Uint8List.fromList(<int>[0, 0, 0]),
        ),
        throwsA(
          predicate(
            (Object e) => e.toString().contains('bg_mask_size_mismatch'),
          ),
        ),
      );
    });
  });
}
