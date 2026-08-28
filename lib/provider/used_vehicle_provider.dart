import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UsedVehicleCategory {
  final int id;
  final String catName;
  final String image;

  UsedVehicleCategory({
    required this.id,
    required this.catName,
    required this.image,
  });

  factory UsedVehicleCategory.fromJson(Map<String, dynamic> json) {
    return UsedVehicleCategory(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      catName: json['cat_name'] ?? '',
      image: json['image'] ?? '',
    );
  }
}

class UsedVehicleProvider with ChangeNotifier {
  static const String _baseUrl = 'https://truemotors.in/ai/api/m_api/';

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<UsedVehicleCategory> _categories = [];
  List<UsedVehicleCategory> get categories => _categories;

  String _extractJson(String raw) {
    final start = raw.indexOf('{');
    if (start == -1) throw const FormatException('No JSON object found in response');
    return raw.substring(start);
  }

  Future<void> fetchUsedVehicleCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final lt = prefs.getString('latitude') ?? '123';
      final ln = prefs.getString('longitude') ?? '123';
      final deviceId = prefs.getString('device_id') ?? '123';

      final params = {
        'type': '2503',
        'cid': '21472147',
        'lt': lt,
        'ln': ln,
        'device_id': deviceId,
        'form': 'sm_main_form_10000',
        'select': 'id,cat_name,image',
      };

      print('┌─────────────────────────────────────────────');
      print('│ [UsedVehicleProvider] REQUEST');
      print('│ URL    : $_baseUrl');
      print('│ Method : POST (form-encoded)');
      print('│ Params : $params');
      print('└─────────────────────────────────────────────');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: params,
      );

      print('┌─────────────────────────────────────────────');
      print('│ [UsedVehicleProvider] RESPONSE');
      print('│ Status : ${response.statusCode}');
      print('│ Body   : ${response.body}');
      print('└─────────────────────────────────────────────');

      if (response.statusCode != 200) {
        throw Exception('Server returned status ${response.statusCode}');
      }

      final cleanJson = _extractJson(response.body);
      final Map<String, dynamic> json = jsonDecode(cleanJson);

      if (json['error'] == false && json['data'] != null) {
        final List<dynamic> data = json['data'];
        _categories = data.map((item) => UsedVehicleCategory.fromJson(item)).toList();
      } else {
        _error = json['message'] ?? 'Failed to fetch data';
      }
    } catch (e) {
      _error = e.toString();
      print('[UsedVehicleProvider] Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
