import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ─── Logout Request Model ─────────────────────────────────────────────────────

class LogoutRequest {
  final String cid;
  final String token;
  final String ledId;

  const LogoutRequest({
    required this.cid,
    required this.token,
    required this.ledId,
  });
}

// ─── Logout Response Model ────────────────────────────────────────────────────

class LogoutResponse {
  final bool error;
  final String message;
  final String ledId;
  final String cid;

  const LogoutResponse({
    required this.error,
    required this.message,
    required this.ledId,
    required this.cid,
  });

  factory LogoutResponse.fromJson(Map<String, dynamic> json) => LogoutResponse(
    error: json['error'] ?? true,
    message: json['message'] ?? '',
    ledId: json['led_id']?.toString() ?? '',
    cid: json['cid']?.toString() ?? '',
  );
}

// ─── Logout API ───────────────────────────────────────────────────────────────

class LogoutApi {
  static const String _baseUrl = 'https://truemotors.in/ai/api/m_api/';

  /// Strips any non-JSON prefix the server prepends (e.g. SQL error strings)
  /// and returns only the JSON substring starting with '{'.
  static String _extractJson(String raw) {
    final start = raw.indexOf('{');
    if (start == -1) throw FormatException('No JSON object found in response');
    return raw.substring(start);
  }

  /// Sends logout request via POST form-encoded body.
  /// Reads lt, ln, device_id from SharedPreferences.
  /// Throws an exception on network or server error.
  static Future<LogoutResponse> logout(LogoutRequest request) async {
    final prefs = await SharedPreferences.getInstance();
    
    final String ln = prefs.getString('longitude') ?? '';
    final String lt = prefs.getString('latitude') ?? '';
    final String deviceId = prefs.getString('device_id') ?? '';

    final params = {
      'cid': request.cid,
      'ln': ln,
      'lt': lt,
      'device_id': deviceId,
      'type': '2502',
      'f_token': request.token,
      'led_id': request.ledId,
    };

    // ── Print request ──────────────────────────────────────────────────────
    print('┌─────────────────────────────────────────────');
    print('│ [LogoutApi] REQUEST');
    print('│ URL    : $_baseUrl');
    print('│ Method : POST (form-encoded)');
    print('│ Params :');
    params.forEach((k, v) => print('│   $k: $v'));
    print('└─────────────────────────────────────────────');

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: params,
    );

    // ── Print response ─────────────────────────────────────────────────────
    print('┌─────────────────────────────────────────────');
    print('│ [LogoutApi] RESPONSE');
    print('│ Status : ${response.statusCode}');
    print('│ Body   : ${response.body}');
    print('└─────────────────────────────────────────────');

    if (response.statusCode != 200) {
      throw Exception('[LogoutApi] Server returned status ${response.statusCode}');
    }

    final cleanJson = _extractJson(response.body);
    final Map<String, dynamic> json = jsonDecode(cleanJson);
    return LogoutResponse.fromJson(json);
  }
}
