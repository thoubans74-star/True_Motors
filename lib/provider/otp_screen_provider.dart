import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ─── OTP Request Model ────────────────────────────────────────────────────────

class OtpRequest {
  final String cid;
  final String mobile;
  final String otp;
  final String token;

  const OtpRequest({
    required this.cid,
    required this.mobile,
    required this.otp,
    required this.token,
  });
}

// ─── OTP Response Model ───────────────────────────────────────────────────────

class OtpResponse {
  final bool error;
  final String message;
  final String mobile;
  final int cid;
  final int userId;
  final String token;
  final dynamic details;

  const OtpResponse({
    required this.error,
    required this.message,
    required this.mobile,
    required this.cid,
    required this.userId,
    required this.token,
    required this.details,
  });

  factory OtpResponse.fromJson(Map<String, dynamic> json) => OtpResponse(
    error: json['error'] ?? true,
    message: json['message'] ?? '',
    mobile: json['mobile']?.toString() ?? '',
    cid: int.tryParse(json['cid']?.toString() ?? '0') ?? 0,
    userId: int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
    token: json['token'] ?? '',
    details: json['details'],
  );
}

// ─── OTP API ──────────────────────────────────────────────────────────────────

class OtpApi {
  static const String _baseUrl = 'https://truemotors.in/ai/api/m_api/';

  /// Strips any non-JSON prefix the server prepends (e.g. SQL error strings)
  /// and returns only the JSON substring starting with '{'.
  static String _extractJson(String raw) {
    final start = raw.indexOf('{');
    if (start == -1) throw FormatException('No JSON object found in response');
    return raw.substring(start);
  }

  /// Reads lt, ln, device_id from SharedPreferences (saved by LoginApi).
  static Future<Map<String, String>> _loadLocationAndDevice() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'lt':        prefs.getString('latitude')  ?? '',
      'ln':        prefs.getString('longitude') ?? '',
      'device_id': prefs.getString('device_id') ?? '',
    };
  }

  /// Verifies the OTP entered by the user via POST form-encoded body.
  /// Reads lt, ln, device_id from SharedPreferences.
  /// Throws an exception on network or server error.
  static Future<OtpResponse> verifyOtp(OtpRequest request) async {
    final saved = await _loadLocationAndDevice();

    final params = {
      'cid':       request.cid,
      'ln':        saved['ln']!,
      'lt':        saved['lt']!,
      'device_id': saved['device_id']!,
      'type':      '2501',
      'mobile':    request.mobile,
      'otp':       request.otp,
      'token':     request.token,
    };

    // ── Print request ──────────────────────────────────────────────────────
    print('┌─────────────────────────────────────────────');
    print('│ [OtpApi] VERIFY REQUEST');
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
    print('│ [OtpApi] VERIFY RESPONSE');
    print('│ Status : ${response.statusCode}');
    print('│ Body   : ${response.body}');
    print('└─────────────────────────────────────────────');

    if (response.statusCode != 200) {
      throw Exception('[OtpApi] Server returned status ${response.statusCode}');
    }

    final cleanJson = _extractJson(response.body);
    final Map<String, dynamic> json = jsonDecode(cleanJson);
    return OtpResponse.fromJson(json);
  }

  /// Resends OTP by calling the login endpoint (type: 2500) again.
  /// Reads lt, ln, device_id from SharedPreferences.
  /// Returns the parsed JSON map so the caller can extract the new f_token.
  static Future<Map<String, dynamic>> resendOtp({
    required String cid,
    required String mobile,
    required String appSignature,
  }) async {
    final saved = await _loadLocationAndDevice();

    final params = {
      'cid':          cid,
      'ln':           saved['ln']!,
      'lt':           saved['lt']!,
      'device_id':    saved['device_id']!,
      'type':         '2500',
      'mobile':       mobile,
      'app_signature': appSignature,
    };

    // ── Print request ──────────────────────────────────────────────────────
    print('┌─────────────────────────────────────────────');
    print('│ [OtpApi] RESEND REQUEST');
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
    print('│ [OtpApi] RESEND RESPONSE');
    print('│ Status : ${response.statusCode}');
    print('│ Body   : ${response.body}');
    print('└─────────────────────────────────────────────');

    if (response.statusCode != 200) {
      throw Exception('[OtpApi] Resend - server returned status ${response.statusCode}');
    }

    final cleanJson = _extractJson(response.body);
    return jsonDecode(cleanJson) as Map<String, dynamic>;
  }
}