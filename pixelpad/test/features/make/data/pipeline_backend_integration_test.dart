import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:pixelpad/features/make/data/pixel_codec.dart';

Map<String, dynamic> asJson(String body) {
  final Object? value = jsonDecode(body);
  if (value is Map<String, dynamic>) {
    return value;
  }
  return <String, dynamic>{};
}

void main() {
  final bool runBackendTests =
      Platform.environment['PIXELPAD_RUN_BACKEND_TESTS'] == 'true';
  final String backendBase =
      Platform.environment['PIXELPAD_BACKEND_URL']?.trim().isNotEmpty == true
      ? Platform.environment['PIXELPAD_BACKEND_URL']!.trim()
      : 'http://127.0.0.1:8080';

  test(
    'pipeline uses color_map size and keeps render buffers aligned',
    () async {
      final File imageFile = File('assets/source/community-example1.png');
      expect(imageFile.existsSync(), isTrue);

      final http.MultipartRequest create =
          http.MultipartRequest('POST', Uri.parse('$backendBase/sessions'))
            ..fields['settings_file'] = 'MARD-48.json'
            ..fields['max_colors'] = '48'
            ..files.add(
              http.MultipartFile.fromBytes(
                'file',
                await imageFile.readAsBytes(),
                filename: imageFile.uri.pathSegments.last,
              ),
            );

      final http.Response sessionResp = await http.Response.fromStream(
        await create.send(),
      );
      expect(sessionResp.statusCode, 200, reason: sessionResp.body);
      final Map<String, dynamic> sessionJson = asJson(sessionResp.body);
      final String sessionId = (sessionJson['session_id'] ?? '').toString();
      expect(sessionId.isNotEmpty, isTrue);

      final http.Response ppResp = await http.post(
        Uri.parse('$backendBase/perfect_pixel'),
        body: <String, String>{'session_id': sessionId, 'grid_mode': 'default'},
      );
      expect(ppResp.statusCode, 200, reason: ppResp.body);
      final Map<String, dynamic> ppJson = asJson(ppResp.body);

      final http.Response rbResp = await http.post(
        Uri.parse('$backendBase/remove_background'),
        body: <String, String>{'session_id': sessionId, 'tight_crop': 'true'},
      );
      expect(rbResp.statusCode, 200, reason: rbResp.body);
      final Map<String, dynamic> rbJson = asJson(rbResp.body);

      final http.Response cmResp = await http.post(
        Uri.parse('$backendBase/color_map'),
        body: <String, String>{
          'session_id': sessionId,
          'color_map_mode': 'nearest',
          'alpha_harden': 'true',
        },
      );
      expect(cmResp.statusCode, 200, reason: cmResp.body);
      final Map<String, dynamic> cmJson = asJson(cmResp.body);

      final int finalWidth = (cmJson['width'] as num?)?.toInt() ?? 0;
      final int finalHeight = (cmJson['height'] as num?)?.toInt() ?? 0;
      expect(finalWidth, greaterThan(0));
      expect(finalHeight, greaterThan(0));

      final Uint16List mapping = decodeMappingU16le(
        (cmJson['mapping_u16le_base64'] ?? '').toString(),
      );
      expect(mapping.length, finalWidth * finalHeight);

      final int rbWidth = (rbJson['width'] as num?)?.toInt() ?? 0;
      final int rbHeight = (rbJson['height'] as num?)?.toInt() ?? 0;
      final int rbTotal = rbWidth * rbHeight;
      final Uint8List decodedMask = decodeRleMask(
        (rbJson['bg_mask_rle_u32le_base64'] ?? '').toString(),
        (rbJson['bg_mask_start'] as bool?) ?? false,
        rbTotal,
      );
      final Uint8List alignedMask = alignMaskToExpectedOrZero(
        decodedMask: decodedMask,
        expectedPixels: finalWidth * finalHeight,
      );
      expect(alignedMask.length, finalWidth * finalHeight);

      if (rbTotal != finalWidth * finalHeight) {
        expect(alignedMask.every((int value) => value == 0), isTrue);
      }

      final int ppWidth = (ppJson['width'] as num?)?.toInt() ?? 0;
      final int ppHeight = (ppJson['height'] as num?)?.toInt() ?? 0;
      expect(ppWidth, greaterThan(0));
      expect(ppHeight, greaterThan(0));
    },
    skip: !runBackendTests
        ? 'Set PIXELPAD_RUN_BACKEND_TESTS=true to run backend integration test.'
        : false,
  );
}
