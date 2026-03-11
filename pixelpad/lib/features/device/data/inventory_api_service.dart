import 'dart:convert';

import 'package:http/http.dart' as http;

class InventoryApiException implements Exception {
  final int statusCode;
  final String message;

  const InventoryApiException({
    required this.statusCode,
    required this.message,
  });

  @override
  String toString() => 'InventoryApiException($statusCode): $message';
}

enum InventoryTransactionAction { deposit, withdraw }

class InventoryBrand {
  final int brandId;
  final String brandName;
  final int totalStock;

  const InventoryBrand({
    required this.brandId,
    required this.brandName,
    required this.totalStock,
  });

  factory InventoryBrand.fromJson(Map<String, dynamic> json) {
    return InventoryBrand(
      brandId: _asInt(json['brand_id'] ?? json['brandId']),
      brandName: _asString(json['brand_name'] ?? json['brandName']),
      totalStock: _asInt(json['total_stock'] ?? json['totalStock']),
    );
  }
}

class InventoryBead {
  final String beadId;
  final String beadType;
  final String color;
  final String color1;
  final int currentStock;

  const InventoryBead({
    required this.beadId,
    required this.beadType,
    required this.color,
    required this.color1,
    required this.currentStock,
  });

  factory InventoryBead.fromJson(Map<String, dynamic> json) {
    return InventoryBead(
      beadId: _asString(json['bead_id'] ?? json['beadId']),
      beadType: _asString(json['bead_type'] ?? json['beadType']),
      color: _asString(json['color']),
      color1: _asString(json['color1']),
      currentStock: _asInt(json['current_stock'] ?? json['currentStock']),
    );
  }
}

class InventoryTransactionDetail {
  final String beadId;
  final int quantity;

  const InventoryTransactionDetail({
    required this.beadId,
    required this.quantity,
  });

  factory InventoryTransactionDetail.fromJson(Map<String, dynamic> json) {
    return InventoryTransactionDetail(
      beadId: _asString(json['bead_id'] ?? json['beadId']),
      quantity: _asInt(json['quantity'] ?? json['qty'] ?? json['amount']),
    );
  }
}

class InventoryTransaction {
  final String transactionId;
  final InventoryTransactionAction action;
  final int durationMinutes;
  final int totalQuantity;
  final DateTime? createdAt;
  final List<InventoryTransactionDetail> details;

  const InventoryTransaction({
    required this.transactionId,
    required this.action,
    required this.durationMinutes,
    required this.totalQuantity,
    required this.createdAt,
    required this.details,
  });

  factory InventoryTransaction.fromJson(Map<String, dynamic> json) {
    final String operation = _asString(
      json['operation_type'] ??
          json['operationType'] ??
          json['action'] ??
          json['type'],
    ).toUpperCase();
    final InventoryTransactionAction action =
        operation == 'OUT' ||
            operation.contains('WITH') ||
            operation.contains('REMOVE')
        ? InventoryTransactionAction.withdraw
        : InventoryTransactionAction.deposit;

    final List<dynamic> rawDetails =
        json['details'] as List<dynamic>? ?? <dynamic>[];
    final List<InventoryTransactionDetail> details = rawDetails
        .whereType<Map>()
        .map(
          (Map item) => InventoryTransactionDetail.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();

    return InventoryTransaction(
      transactionId: _asString(
        json['transaction_id'] ?? json['transactionId'] ?? json['id'],
      ),
      action: action,
      durationMinutes: _asInt(
        json['duration_minutes'] ?? json['durationMinutes'] ?? 0,
      ),
      totalQuantity: _asInt(
        json['total_quantity'] ?? json['totalQuantity'] ?? json['quantity'],
      ),
      createdAt: _asDateTime(
        json['created_at'] ?? json['createdAt'] ?? json['timestamp'],
      ),
      details: details,
    );
  }
}

class InventoryApiService {
  InventoryApiService({
    http.Client? client,
    this.baseUrl = 'https://pixelpad.edmounds.top',
  }) : _client = client ?? http.Client();

  static const Duration _timeout = Duration(seconds: 20);

  final http.Client _client;
  final String baseUrl;

  Future<Map<String, dynamic>> health() async {
    final http.Response response = await _client
        .get(Uri.parse('$baseUrl/health'))
        .timeout(_timeout);
    if (response.statusCode != 200) {
      throw _toApiException(response, defaultMessage: 'Health check failed');
    }
    return _decodeJsonMap(response.body);
  }

  Future<List<String>> listSettingsFiles() async {
    final http.Response response = await _client
        .get(Uri.parse('$baseUrl/settings/list'))
        .timeout(_timeout);
    if (response.statusCode != 200) {
      throw _toApiException(
        response,
        defaultMessage: 'Failed to load settings list',
      );
    }
    final Map<String, dynamic> map = _decodeJsonMap(response.body);
    final List<dynamic> files = map['files'] as List<dynamic>? ?? <dynamic>[];
    return files.map((dynamic value) => value.toString()).toList();
  }

  Future<List<InventoryBrand>> listBrands({
    required String accessToken,
    String tokenType = 'Bearer',
  }) async {
    final http.Response response = await _client
        .get(
          Uri.parse('$baseUrl/inventory/brands'),
          headers: _authHeaders(accessToken: accessToken, tokenType: tokenType),
        )
        .timeout(_timeout);
    if (response.statusCode != 200) {
      throw _toApiException(response, defaultMessage: 'Failed to load brands');
    }
    final Map<String, dynamic> map = _decodeJsonMap(response.body);
    final List<dynamic> items = map['items'] as List<dynamic>? ?? <dynamic>[];
    return items
        .whereType<Map>()
        .map(
          (Map item) =>
              InventoryBrand.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  Future<InventoryBrand> getBrand({
    required int brandId,
    required String accessToken,
    String tokenType = 'Bearer',
  }) async {
    final http.Response response = await _client
        .get(
          Uri.parse('$baseUrl/inventory/brands/$brandId'),
          headers: _authHeaders(accessToken: accessToken, tokenType: tokenType),
        )
        .timeout(_timeout);
    if (response.statusCode != 200) {
      throw _toApiException(response, defaultMessage: 'Failed to load brand');
    }
    return InventoryBrand.fromJson(_decodeJsonMap(response.body));
  }

  Future<List<InventoryBead>> listBeads({
    required int brandId,
    required String accessToken,
    String tokenType = 'Bearer',
  }) async {
    final http.Response response = await _client
        .get(
          Uri.parse('$baseUrl/inventory/brands/$brandId/beads'),
          headers: _authHeaders(accessToken: accessToken, tokenType: tokenType),
        )
        .timeout(_timeout);
    if (response.statusCode != 200) {
      throw _toApiException(response, defaultMessage: 'Failed to load beads');
    }
    final Map<String, dynamic> map = _decodeJsonMap(response.body);
    final List<dynamic> items = map['items'] as List<dynamic>? ?? <dynamic>[];
    return items
        .whereType<Map>()
        .map(
          (Map item) => InventoryBead.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  Future<List<InventoryTransaction>> listTransactions({
    required String accessToken,
    int limit = 20,
    int offset = 0,
    String tokenType = 'Bearer',
  }) async {
    final int resolvedLimit = limit <= 0 ? 20 : limit;
    final int resolvedOffset = offset < 0 ? 0 : offset;
    final Uri uri = Uri.parse('$baseUrl/inventory/transactions').replace(
      queryParameters: <String, String>{
        'limit': '$resolvedLimit',
        'offset': '$resolvedOffset',
      },
    );
    final http.Response response = await _client
        .get(
          uri,
          headers: _authHeaders(accessToken: accessToken, tokenType: tokenType),
        )
        .timeout(_timeout);
    if (response.statusCode != 200) {
      throw _toApiException(
        response,
        defaultMessage: 'Failed to load transactions',
      );
    }
    final Map<String, dynamic> map = _decodeJsonMap(response.body);
    final List<dynamic> items = map['items'] as List<dynamic>? ?? <dynamic>[];
    return items
        .whereType<Map>()
        .map(
          (Map item) =>
              InventoryTransaction.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  Future<InventoryTransaction> createTransaction({
    required String accessToken,
    required String beadId,
    required int quantity,
    required InventoryTransactionAction action,
    int durationMinutes = 0,
    String tokenType = 'Bearer',
  }) async {
    final String normalizedBeadId = beadId.trim().toUpperCase();
    final Map<String, dynamic> payload = <String, dynamic>{
      'operation_type': action == InventoryTransactionAction.deposit
          ? 'IN'
          : 'OUT',
      'duration_minutes': durationMinutes < 0 ? 0 : durationMinutes,
      'items': <Map<String, dynamic>>[
        <String, dynamic>{'bead_id': normalizedBeadId, 'quantity': quantity},
      ],
    };
    final http.Response response = await _client
        .post(
          Uri.parse('$baseUrl/inventory/transactions'),
          headers: _authHeaders(
            accessToken: accessToken,
            tokenType: tokenType,
            withJsonContentType: true,
          ),
          body: jsonEncode(payload),
        )
        .timeout(_timeout);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw _toApiException(
        response,
        defaultMessage: 'Failed to create transaction',
      );
    }
    final Map<String, dynamic> map = _decodeJsonMap(response.body);
    if (map.isEmpty) {
      return InventoryTransaction(
        transactionId: '',
        action: action,
        durationMinutes: durationMinutes < 0 ? 0 : durationMinutes,
        totalQuantity: quantity,
        createdAt: DateTime.now(),
        details: <InventoryTransactionDetail>[
          InventoryTransactionDetail(
            beadId: normalizedBeadId,
            quantity: quantity,
          ),
        ],
      );
    }
    return InventoryTransaction.fromJson(map);
  }

  Map<String, String> _authHeaders({
    required String accessToken,
    required String tokenType,
    bool withJsonContentType = false,
  }) {
    final String resolvedTokenType = tokenType.isEmpty ? 'Bearer' : tokenType;
    final Map<String, String> headers = <String, String>{
      'Authorization': '$resolvedTokenType $accessToken',
    };
    if (withJsonContentType) {
      headers['Content-Type'] = 'application/json';
    }
    return headers;
  }

  InventoryApiException _toApiException(
    http.Response response, {
    required String defaultMessage,
  }) {
    final Map<String, dynamic> map = _decodeJsonMap(response.body);
    final String message =
        map['detail'] as String? ??
        map['error'] as String? ??
        map['message'] as String? ??
        defaultMessage;
    return InventoryApiException(
      statusCode: response.statusCode,
      message: message,
    );
  }
}

Map<String, dynamic> _decodeJsonMap(String body) {
  if (body.isEmpty) {
    return <String, dynamic>{};
  }
  try {
    final dynamic decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    return <String, dynamic>{};
  } catch (_) {
    return <String, dynamic>{};
  }
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

DateTime? _asDateTime(dynamic value) {
  if (value is String && value.trim().isNotEmpty) {
    return DateTime.tryParse(value);
  }
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value);
  }
  if (value is num) {
    return DateTime.fromMillisecondsSinceEpoch(value.toInt());
  }
  return null;
}
