import 'package:flutter_test/flutter_test.dart';
import 'package:pixelpad/features/make/data/pixelpad_api_service.dart';

void main() {
  test('ColorMapResult preserves palette entry ids and idx values', () {
    final ColorMapResult result = ColorMapResult.fromJson(<String, dynamic>{
      'width': 2,
      'height': 2,
      'mapping_u16le_base64': '',
      'palette': <Map<String, dynamic>>[
        <String, dynamic>{
          'idx': 7,
          'id': 'H2',
          'count': 12,
          'rgba': <int>[250, 250, 250, 255],
          'hex': '#fafafa',
        },
        <String, dynamic>{
          'idx': 9,
          'id': 'C7',
          'count': 8,
          'rgba': <int>[57, 119, 204, 255],
        },
      ],
    });

    expect(result.palette, hasLength(2));
    expect(result.palette[0].idx, 7);
    expect(result.palette[0].id, 'H2');
    expect(result.palette[0].count, 12);
    expect(result.palette[0].rgba, <int>[250, 250, 250, 255]);
    expect(result.palette[1].idx, 9);
    expect(result.palette[1].id, 'C7');
    expect(result.palette[1].hex, '#3977cc');
  });
}
