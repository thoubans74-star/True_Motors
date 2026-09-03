import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionPlan {
  final int id;
  final String planName;
  final String price;
  final int validity;
  final int listings;
  final int coins;

  SubscriptionPlan({
    required this.id,
    required this.planName,
    required this.price,
    required this.validity,
    required this.listings,
    required this.coins,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] ?? 0,
      planName: json['plan_name']?.toString() ?? '',
      price: json['price']?.toString() ?? '0',
      validity: json['validity'] is int
          ? json['validity']
          : int.tryParse(json['validity']?.toString() ?? '0') ?? 0,
      listings: json['listings'] is int
          ? json['listings']
          : int.tryParse(json['listings']?.toString() ?? '0') ?? 0,
      coins: json['coins'] is int
          ? json['coins']
          : int.tryParse(json['coins']?.toString() ?? '0') ?? 0,
    );
  }
}

class SubscriptionProvider extends ChangeNotifier {
  static const String _baseUrl = 'https://truemotors.in/ai/api/m_api/';

  bool _isLoading = false;
  String? _errorMessage;
  List<SubscriptionPlan> _monthlyPlans = [];
  List<SubscriptionPlan> _yearlyPlans = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<SubscriptionPlan> get monthlyPlans => _monthlyPlans;
  List<SubscriptionPlan> get yearlyPlans => _yearlyPlans;

  /// Strips any non-JSON prefix the server prepends (e.g. SQL error strings)
  /// and returns only the JSON substring starting with '{'.
  String _extractJson(String raw) {
    final start = raw.indexOf('{');
    if (start == -1) throw const FormatException('No JSON object found in response');
    return raw.substring(start);
  }

  Future<void> fetchPlans() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = prefs.getString('cid') ?? '21472147';
      final deviceId = prefs.getString('device_id') ?? '123';
      final ln = prefs.getString('longitude') ?? '11';
      final lt = prefs.getString('latitude') ?? '11';

      final params = {
        'type': '2522',
        'cid': cid,
        'device_id': deviceId,
        'ln': ln,
        'lt': lt,
      };

      debugPrint('┌─────────────────────────────────────────────');
      debugPrint('│ [SubscriptionProvider] FETCH REQUEST (2522)');
      debugPrint('│ URL    : $_baseUrl');
      debugPrint('│ Params : $params');
      debugPrint('└─────────────────────────────────────────────');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: params,
      );

      debugPrint('┌─────────────────────────────────────────────');
      debugPrint('│ [SubscriptionProvider] FETCH RESPONSE');
      debugPrint('│ Status : ${response.statusCode}');
      debugPrint('│ Body   : ${response.body}');
      debugPrint('└─────────────────────────────────────────────');

      if (response.statusCode != 200) {
        throw Exception('Server returned status code ${response.statusCode}');
      }

      final cleanJson = _extractJson(response.body);
      final Map<String, dynamic> json = jsonDecode(cleanJson);

      if (json['error'] == false && json['data'] != null && json['data'] is List) {
        final List<dynamic> data = json['data'];
        final List<SubscriptionPlan> allPlans =
            data.map((item) => SubscriptionPlan.fromJson(item as Map<String, dynamic>)).toList();

        _monthlyPlans = allPlans.where((plan) => plan.validity == 30).toList();
        _yearlyPlans = allPlans.where((plan) => plan.validity == 365).toList();
      } else {
        _errorMessage = json['error_msg'] ?? 'Failed to fetch plans';
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('[SubscriptionProvider] Fetch Error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
