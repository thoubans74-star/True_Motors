import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ─── Login Request Model ──────────────────────────────────────────────────────

class LoginRequest {
  final String cid;
  final String ln;
  final String lt;
  final String deviceId;
  final String mobile;
  final String appSignature;

  const LoginRequest({
    required this.cid,
    required this.ln,
    required this.lt,
    required this.deviceId,
    required this.mobile,
    required this.appSignature,
  });

  Map<String, String> toParams() => {
    'cid': cid,
    'ln': ln,
    'lt': lt,
    'device_id': deviceId,
    'type': '2500',
    'mobile': mobile,
    'app_signature': appSignature,
  };
}

// ─── Login Response Model ─────────────────────────────────────────────────────

class LoginResponse {
  final bool error;
  final String errorMsg;
  final int userId;
  final int cid;
  final String compName;
  final String otp;
  final String mobile;
  final String deviceId;
  final String fToken;
  final String appSignature;

  const LoginResponse({
    required this.error,
    required this.errorMsg,
    required this.userId,
    required this.cid,
    required this.compName,
    required this.otp,
    required this.mobile,
    required this.deviceId,
    required this.fToken,
    required this.appSignature,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    error: json['error'] ?? true,
    errorMsg: json['error_msg'] ?? '',
    userId: int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
    cid: int.tryParse(json['cid']?.toString() ?? '0') ?? 0,
    compName: json['comp_name'] ?? '',
    otp: json['otp']?.toString() ?? '',
    mobile: json['mobile']?.toString() ?? '',
    deviceId: json['device_id']?.toString() ?? '',
    fToken: json['f_token'] ?? '',
    appSignature: json['app_signature'] ?? '',
  );
}

// ─── Login API ────────────────────────────────────────────────────────────────

class LoginApi {
  static const String _baseUrl = 'https://truemotors.in/ai/api/m_api/';

  /// Strips any non-JSON prefix the server prepends (e.g. SQL error strings)
  /// and returns only the JSON substring starting with '{'.
  static String _extractJson(String raw) {
    final start = raw.indexOf('{');
    if (start == -1) throw FormatException('No JSON object found in response');
    return raw.substring(start);
  }

  /// Sends login OTP request via POST form-encoded body.
  /// Saves lt, ln, device_id to SharedPreferences for use by OtpApi.
  /// Throws an exception on network or server error.
  static Future<LoginResponse> sendOtp(LoginRequest request) async {
    final params = request.toParams();

    // ── Save lt / ln / device_id to SharedPreferences ─────────────────────
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('latitude',  request.lt);
    await prefs.setString('longitude', request.ln);
    await prefs.setString('device_id', request.deviceId);

    // ── Print request ──────────────────────────────────────────────────────
    print('┌─────────────────────────────────────────────');
    print('│ [LoginApi] REQUEST');
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
    print('│ [LoginApi] RESPONSE');
    print('│ Status : ${response.statusCode}');
    print('│ Body   : ${response.body}');
    print('└─────────────────────────────────────────────');

    if (response.statusCode != 200) {
      throw Exception('[LoginApi] Server returned status ${response.statusCode}');
    }

    final cleanJson = _extractJson(response.body);
    final Map<String, dynamic> json = jsonDecode(cleanJson);
    return LoginResponse.fromJson(json);
  }
}