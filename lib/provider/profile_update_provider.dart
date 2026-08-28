import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:true_motors/utils/shared_prefs_helper.dart';

// ─── Profile Model ──────────────────────────────────────────────────────────

class ProfileModel {
  final String name;
  final String email;
  final String mobile;
  final String block;
  final String street;
  final String area;
  final String city;
  final String state;
  final String pincode;
  final String imageUrl;

  const ProfileModel({
    this.name = '',
    this.email = '',
    this.mobile = '',
    this.block = '',
    this.street = '',
    this.area = '',
    this.city = '',
    this.state = '',
    this.pincode = '',
    this.imageUrl = '',
  });

  /// Factory to construct ProfileModel from server response data map or top-level json.
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final dataMap = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;

    final rawAddress =
        dataMap['address']?.toString() ?? json['address']?.toString() ?? '';
    final addressParts = rawAddress
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    String block = addressParts.isNotEmpty ? addressParts[0] : '';
    String street = addressParts.length > 1 ? addressParts[1] : '';
    String area = addressParts.length > 2 ? addressParts[2] : '';
    String city = addressParts.length > 3 ? addressParts[3] : '';
    String state = addressParts.length > 4 ? addressParts[4] : '';
    String pincode = addressParts.length > 5 ? addressParts[5] : '';

    final imgUrl = dataMap['Image']?.toString() ??
        dataMap['image']?.toString() ??
        json['Image']?.toString() ??
        json['image']?.toString() ??
        '';

    return ProfileModel(
      name: dataMap['name']?.toString() ?? json['name']?.toString() ?? '',
      email: dataMap['email']?.toString() ?? json['email']?.toString() ?? '',
      mobile: dataMap['mobile']?.toString() ?? json['mobile']?.toString() ?? '',
      block: block,
      street: street,
      area: area,
      city: city,
      state: state,
      pincode: pincode,
      imageUrl: imgUrl,
    );
  }

  ProfileModel copyWith({
    String? name,
    String? email,
    String? mobile,
    String? block,
    String? street,
    String? area,
    String? city,
    String? state,
    String? pincode,
    String? imageUrl,
  }) {
    return ProfileModel(
      name: name ?? this.name,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      block: block ?? this.block,
      street: street ?? this.street,
      area: area ?? this.area,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

// ─── Profile Update Provider ────────────────────────────────────────────────

class ProfileUpdateProvider with ChangeNotifier {
  static const String _baseUrl = 'https://truemotors.in/ai/api/m_api/';

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ProfileModel _profile = const ProfileModel();
  ProfileModel get profile => _profile;

  /// Helper to extract clean JSON string if server prepends non-JSON content.
  String _extractJson(String raw) {
    final start = raw.indexOf('{');
    if (start == -1) throw const FormatException('No JSON object found in response');
    return raw.substring(start);
  }

  /// **API 2507: Fetch Profile Information**
  Future<bool> fetchProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final cid = await SharedPrefsHelper.getCid() ?? '21472147';
      final ledId = await SharedPrefsHelper.getUserId() ?? '10';
      final token = await SharedPrefsHelper.getToken() ?? '';
      final deviceId = await SharedPrefsHelper.getDeviceId() ?? '123';
      final ln = await SharedPrefsHelper.getLn() ?? '123';
      final lt = await SharedPrefsHelper.getLt() ?? '123';

      final params = {
        'type': '2507',
        'cid': cid,
        'led_id': ledId,
        'token': token,
        'device_id': deviceId,
        'ln': ln,
        'lt': lt,
      };

      debugPrint('┌─────────────────────────────────────────────');
      debugPrint('│ [ProfileUpdateProvider] FETCH REQUEST (2507)');
      debugPrint('│ URL    : $_baseUrl');
      debugPrint('│ Params : $params');
      debugPrint('└─────────────────────────────────────────────');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: params,
      );

      debugPrint('┌─────────────────────────────────────────────');
      debugPrint('│ [ProfileUpdateProvider] FETCH RESPONSE');
      debugPrint('│ Status : ${response.statusCode}');
      debugPrint('│ Body   : ${response.body}');
      debugPrint('└─────────────────────────────────────────────');

      if (response.statusCode != 200) {
        throw Exception('Server returned status code ${response.statusCode}');
      }

      final cleanJson = _extractJson(response.body);
      final Map<String, dynamic> json = jsonDecode(cleanJson);

      if (json['status'] == 'success' || json['error'] == false || json['data'] != null) {
        if (json['token'] != null && json['token'].toString().isNotEmpty) {
          await SharedPrefsHelper.setToken(json['token'].toString());
        }

        if (json['data'] != null && json['data'] is Map<String, dynamic>) {
          _profile = ProfileModel.fromJson(json['data']);
          await _saveProfileToPrefs(_profile);
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = json['message'] ?? 'Failed to fetch profile details';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('[ProfileUpdateProvider] Fetch Error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// **API 2508: Update Profile Information**
  Future<bool> updateProfile({
    required String name,
    required String email,
    required String mobile,
    required String block,
    required String street,
    required String area,
    required String city,
    required String state,
    required String pincode,
    File? profileImageFile,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final cid = await SharedPrefsHelper.getCid() ?? '21472147';
      final ledId = await SharedPrefsHelper.getUserId() ?? '10';
      final token = await SharedPrefsHelper.getToken() ?? '';
      final deviceId = await SharedPrefsHelper.getDeviceId() ?? '123';
      final ln = await SharedPrefsHelper.getLn() ?? '123';
      final lt = await SharedPrefsHelper.getLt() ?? '123';

      final Map<String, String> fields = {
        'type': '2508',
        'cid': cid,
        'led_id': ledId,
        'token': token,
        'name': name,
        'email': email,
        'mobile': mobile,
        'city': city,
        'area': area,
        'block': block,
        'state': state,
        'pincode': pincode,
        'street': street,
        'ln': ln,
        'lt': lt,
        'device_id': deviceId,
      };

      debugPrint('┌─────────────────────────────────────────────');
      debugPrint('│ [ProfileUpdateProvider] UPDATE REQUEST (2508)');
      debugPrint('│ URL    : $_baseUrl');
      debugPrint('│ Params : $fields');
      if (profileImageFile != null) {
        debugPrint('│ Image  : ${profileImageFile.path}');
      }
      debugPrint('└─────────────────────────────────────────────');

      String responseBody = '';
      int statusCode = 200;

      if (profileImageFile != null && await profileImageFile.exists()) {
        final request = http.MultipartRequest('POST', Uri.parse(_baseUrl));
        request.fields.addAll(fields);

        final fileName = profileImageFile.path.split('/').last.split('\\').last;
        final ext = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : 'jpg';
        String subtype = 'jpeg';
        if (ext == 'png') subtype = 'png';
        if (ext == 'webp') subtype = 'webp';

        final mimeType = MediaType('image', subtype);

        final multipartFileUpper = await http.MultipartFile.fromPath(
          'Image',
          profileImageFile.path,
          filename: fileName,
          contentType: mimeType,
        );
        request.files.add(multipartFileUpper);

        final multipartFileLower = await http.MultipartFile.fromPath(
          'image',
          profileImageFile.path,
          filename: fileName,
          contentType: mimeType,
        );
        request.files.add(multipartFileLower);

        final streamedResponse = await request.send();
        statusCode = streamedResponse.statusCode;
        responseBody = await streamedResponse.stream.bytesToString();
      } else {
        final response = await http.post(
          Uri.parse(_baseUrl),
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: fields,
        );
        statusCode = response.statusCode;
        responseBody = response.body;
      }

      debugPrint('┌─────────────────────────────────────────────');
      debugPrint('│ [ProfileUpdateProvider] UPDATE RESPONSE');
      debugPrint('│ Status : $statusCode');
      debugPrint('│ Body   : $responseBody');
      debugPrint('└─────────────────────────────────────────────');

      if (statusCode != 200) {
        throw Exception('Server returned status code $statusCode');
      }

      final cleanJson = _extractJson(responseBody);
      final Map<String, dynamic> json = jsonDecode(cleanJson);
      final prevImageUrl = _profile.imageUrl;

      if (json['status'] == 'success' || json['error'] == false || json['data'] != null) {
        if (json['token'] != null && json['token'].toString().isNotEmpty) {
          await SharedPrefsHelper.setToken(json['token'].toString());
        }

        _profile = ProfileModel.fromJson(json);
        if (_profile.imageUrl.isEmpty && prevImageUrl.isNotEmpty) {
          _profile = _profile.copyWith(imageUrl: prevImageUrl);
        }

        await _saveProfileToPrefs(_profile);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = json['message'] ?? 'Failed to update profile';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('[ProfileUpdateProvider] Update Error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Save profile details to SharedPreferences for quick local sync across app screens.
  Future<void> _saveProfileToPrefs(ProfileModel p) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', p.name);
    await prefs.setString('phone', p.mobile);
    await prefs.setString('mobile', p.mobile);
    await prefs.setString('email', p.email);
    await prefs.setString('block', p.block);
    await prefs.setString('street_name', p.street);
    await prefs.setString('area', p.area);
    await prefs.setString('city', p.city);
    await prefs.setString('state', p.state);
    await prefs.setString('pincode', p.pincode);
    if (p.imageUrl.isNotEmpty) {
      await prefs.setString('profile_image_url', p.imageUrl);
    }
  }
}
