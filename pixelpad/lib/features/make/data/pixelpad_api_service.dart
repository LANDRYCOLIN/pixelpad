import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'package:pixelpad/features/make/data/make_api.dart';

class PixelPadApiService {
  const PixelPadApiService();

  static const Duration _timeout = Duration(seconds: 20);

  Future<SessionResult> createSession({
    required Uint8List imageBytes,
    required String settingsFile,
    required int maxColors,
    String filename = 'upload.png',
  }) async {
    final http.MultipartRequest request = http.MultipartRequest(
      'POST',
      Uri.parse('$makeApiBaseUrl/sessions'),
    );
    request.fields['settings_file'] = settingsFile;
    request.fields['max_colors'] = maxColors.toString();
    request.files.add(
      http.MultipartFile.fromBytes('file', imageBytes, filename: filename),
    );

    final http.StreamedResponse streamed = await request.send().timeout(
      _timeout,
    );
    final http.Response response = await http.Response.fromStream(
      streamed,
    ).timeout(_timeout);
    if (response.statusCode != 200) {
      throw Exception('create_session_failed:${response.statusCode}');
    }
    return SessionResult.fromJson(_decodeJsonBody(response.body));
  }

  Future<PerfectPixelResult> perfectPixel({
    required String sessionId,
    required int maxColors,
    double mergeThreshold = 12.0,
  }) async {
    final http.Response response = await http
        .post(
          Uri.parse('$makeApiBaseUrl/perfect_pixel'),
          body: {
            'session_id': sessionId,
            'max_colors': maxColors.toString(),
            'merge_threshold': mergeThreshold.toString(),
          },
        )
        .timeout(_timeout);
    if (response.statusCode != 200) {
      throw Exception('perfect_pixel_failed:${response.statusCode}');
    }
    return PerfectPixelResult.fromJson(_decodeJsonBody(response.body));
  }

  Future<RemoveBackgroundResult> removeBackground({
    required String sessionId,
  }) async {
    final http.Response response = await http
        .post(
          Uri.parse('$makeApiBaseUrl/remove_background'),
          body: {'session_id': sessionId},
        )
        .timeout(_timeout);
    if (response.statusCode != 200) {
      throw Exception('remove_background_failed:${response.statusCode}');
    }
    return RemoveBackgroundResult.fromJson(_decodeJsonBody(response.body));
  }

  Future<ColorMapResult> colorMap({
    required String sessionId,
    String colorMapMode = 'nearest',
    bool alphaHarden = true,
  }) async {
    final http.Response response = await http
        .post(
          Uri.parse('$makeApiBaseUrl/color_map'),
          body: {
            'session_id': sessionId,
            'color_map_mode': colorMapMode,
            'alpha_harden': alphaHarden ? 'true' : 'false',
          },
        )
        .timeout(_timeout);
    if (response.statusCode != 200) {
      throw Exception('color_map_failed:${response.statusCode}');
    }
    return ColorMapResult.fromJson(_decodeJsonBody(response.body));
  }
}

class SessionResult {
  final String sessionId;
  final int width;
  final int height;

  const SessionResult({
    required this.sessionId,
    required this.width,
    required this.height,
  });

  factory SessionResult.fromJson(Map<String, dynamic> json) {
    return SessionResult(
      sessionId: _asString(json['session_id'] ?? json['sessionId']),
      width: _asInt(json['width']),
      height: _asInt(json['height']),
    );
  }
}

class PerfectPixelResult {
  final String rgbaU8Base64;
  final int width;
  final int height;

  const PerfectPixelResult({
    required this.rgbaU8Base64,
    required this.width,
    required this.height,
  });

  factory PerfectPixelResult.fromJson(Map<String, dynamic> json) {
    return PerfectPixelResult(
      rgbaU8Base64: _asString(
        json['rgba_u8_base64'] ?? json['rgbaU8Base64'] ?? json['rgba_base64'],
      ),
      width: _asInt(json['width']),
      height: _asInt(json['height']),
    );
  }
}

class RemoveBackgroundResult {
  final int width;
  final int height;
  final String bgMaskRleU32leBase64;
  final bool bgMaskStart;

  const RemoveBackgroundResult({
    required this.width,
    required this.height,
    required this.bgMaskRleU32leBase64,
    required this.bgMaskStart,
  });

  factory RemoveBackgroundResult.fromJson(Map<String, dynamic> json) {
    return RemoveBackgroundResult(
      width: _asInt(json['width']),
      height: _asInt(json['height']),
      bgMaskRleU32leBase64: _asString(
        json['bg_mask_rle_u32le_base64'] ?? json['bgMaskRleU32leBase64'],
      ),
      bgMaskStart: _asBool(json['bg_mask_start'] ?? json['bgMaskStart']),
    );
  }
}

class ColorMapResult {
  final int width;
  final int height;
  final List<List<int>> palette;
  final String mappingU16leBase64;
  final List<int>? previewPadding;

  const ColorMapResult({
    required this.width,
    required this.height,
    required this.palette,
    required this.mappingU16leBase64,
    required this.previewPadding,
  });

  factory ColorMapResult.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawPalette = (json['palette'] as List<dynamic>? ?? []);
    return ColorMapResult(
      width: _asInt(json['width']),
      height: _asInt(json['height']),
      palette: rawPalette.map(_toRgba).toList(),
      mappingU16leBase64: _asString(
        json['mapping_u16le_base64'] ?? json['mappingU16leBase64'],
      ),
      previewPadding: _toIntList(json['preview_padding']),
    );
  }
}

Map<String, dynamic> _decodeJsonBody(String body) {
  if (body.isEmpty) {
    return <String, dynamic>{};
  }
  final Object? parsed = jsonDecode(body);
  if (parsed is Map) {
    return parsed.map(
      (dynamic key, dynamic value) => MapEntry(key.toString(), value),
    );
  }
  return <String, dynamic>{};
}

int _asInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value) ?? 0;
  }
  return 0;
}

String _asString(dynamic value) {
  if (value is String) {
    return value;
  }
  return '';
}

bool _asBool(dynamic value) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  if (value is String) {
    final String normalized = value.trim().toLowerCase();
    return normalized == '1' || normalized == 'true' || normalized == 'yes';
  }
  return false;
}

List<int> _toRgba(dynamic color) {
  if (color is List) {
    final List<int> rgba = color
        .whereType<num>()
        .map((num value) => value.toInt().clamp(0, 255).toInt())
        .toList();
    if (rgba.length >= 4) {
      return rgba.sublist(0, 4);
    }
    if (rgba.length == 3) {
      return <int>[rgba[0], rgba[1], rgba[2], 255];
    }
  }
  if (color is Map) {
    final Object? nested = color['rgba'];
    if (nested is List) {
      return _toRgba(nested);
    }
    final int r = _asInt(color['r']).clamp(0, 255).toInt();
    final int g = _asInt(color['g']).clamp(0, 255).toInt();
    final int b = _asInt(color['b']).clamp(0, 255).toInt();
    final int a = (_asInt(color['a']) == 0 ? 255 : _asInt(color['a']))
        .clamp(0, 255)
        .toInt();
    return <int>[r, g, b, a];
  }
  return const <int>[0, 0, 0, 255];
}

List<int>? _toIntList(dynamic value) {
  if (value is! List) {
    return null;
  }
  return value.whereType<num>().map((num v) => v.toInt()).toList();
}
