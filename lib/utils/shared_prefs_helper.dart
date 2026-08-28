import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  static const String _keyLt = 'lt';
  static const String _keyLn = 'ln';
  static const String _keyCid = 'cid';
  static const String _keyUserId = 'userId';
  static const String _keyDeviceId = 'deviceId';
  static const String _keyToken = 'token';
  static const String _keyMobile = 'phone';
  static const String _keyName = 'name';

  // ── LT ──────────────────────────────────────────────────────────────────
  static Future<void> setLt(String lt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLt, lt);
    await prefs.setString('latitude', lt);
  }

  static Future<String?> getLt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLt) ?? prefs.getString('latitude') ?? '123';
  }

  // ── LN ──────────────────────────────────────────────────────────────────
  static Future<void> setLn(String ln) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLn, ln);
    await prefs.setString('longitude', ln);
  }

  static Future<String?> getLn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLn) ?? prefs.getString('longitude') ?? '123';
  }

  // ── CID ─────────────────────────────────────────────────────────────────
  static Future<void> setCid(String cid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCid, cid);
  }

  static Future<String?> getCid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCid) ?? '21472147';
  }

  // ── USER ID ─────────────────────────────────────────────────────────────
  static Future<void> setUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, userId);
    await prefs.setInt('user_id', int.tryParse(userId) ?? 0);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final uidInt = prefs.getInt('user_id');
    if (uidInt != null && uidInt > 0) return uidInt.toString();
    return prefs.getString(_keyUserId) ?? '10';
  }

  // ── DEVICE ID ───────────────────────────────────────────────────────────
  static Future<void> setDeviceId(String deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDeviceId, deviceId);
    await prefs.setString('device_id', deviceId);
  }

  static Future<String?> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDeviceId) ?? prefs.getString('device_id') ?? '123';
  }

  // ── TOKEN ───────────────────────────────────────────────────────────────
  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  // ── MOBILE ──────────────────────────────────────────────────────────────
  static Future<void> setMobile(String mobile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyMobile, mobile);
  }

  static Future<String?> getMobile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyMobile) ?? prefs.getString('mobile');
  }

  // ── NAME ────────────────────────────────────────────────────────────────
  static Future<void> setName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, name);
  }

  static Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyName);
  }

  // ── CLEAR ALL ───────────────────────────────────────────────────────────
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLt);
    await prefs.remove(_keyLn);
    await prefs.remove(_keyCid);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyDeviceId);
    await prefs.remove(_keyToken);
    await prefs.remove(_keyMobile);
    await prefs.remove(_keyName);
    await prefs.remove('user_id');
    await prefs.remove('latitude');
    await prefs.remove('longitude');
    await prefs.remove('device_id');
  }
}
