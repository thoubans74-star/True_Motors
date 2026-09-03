import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TermsSection {
  final String title;
  final String desc;
  final List<String> points;

  TermsSection({
    required this.title,
    required this.desc,
    required this.points,
  });

  factory TermsSection.fromJson(Map<String, dynamic> json) {
    return TermsSection(
      title: json['title'] ?? '',
      desc: json['desc'] ?? '',
      points: (json['points'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class TermsProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  List<TermsSection> _sections = [];

  bool _isPrivacyLoading = false;
  String? _privacyErrorMessage;
  List<TermsSection> _privacySections = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<TermsSection> get sections => _sections;

  bool get isPrivacyLoading => _isPrivacyLoading;
  String? get privacyErrorMessage => _privacyErrorMessage;
  List<TermsSection> get privacySections => _privacySections;

  Future<void> fetchTerms() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = prefs.getString('cid') ?? '21472147';
      final deviceId = prefs.getString('device_id') ?? '123';
      final lt = prefs.getString('lt') ?? '123';
      final ln = prefs.getString('ln') ?? '123';

      final requestBody = {
        'type': '2523',
        'cid': cid,
        'device_id': deviceId,
        'lt': lt,
        'ln': ln,
      };
      
      print('--- FETCH TERMS REQUEST ---');
      print('URL: https://truemotors.in/ai/api/m_api/');
      print('BODY: $requestBody');

      final response = await http.post(
        Uri.parse('https://truemotors.in/ai/api/m_api/'),
        body: requestBody,
      );

      print('--- FETCH TERMS RESPONSE ---');
      print('STATUS: ${response.statusCode}');
      print('BODY: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success' && data['data'] != null) {
          _sections = (data['data'] as List)
              .map((e) => TermsSection.fromJson(e))
              .toList();
        } else {
          _errorMessage = data['message'] ?? 'Failed to fetch Terms & Conditions';
        }
      } else {
        _errorMessage = 'Server Error: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchPrivacyPolicy() async {
    _isPrivacyLoading = true;
    _privacyErrorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = prefs.getString('cid') ?? '21472147';
      final deviceId = prefs.getString('device_id') ?? '123';
      final lt = prefs.getString('lt') ?? '123';
      final ln = prefs.getString('ln') ?? '123';

      final requestBody = {
        'type': '2524',
        'cid': cid,
        'device_id': deviceId,
        'lt': lt,
        'ln': ln,
      };
      
      print('--- FETCH PRIVACY POLICY REQUEST ---');
      print('URL: https://truemotors.in/ai/api/m_api/');
      print('BODY: $requestBody');

      final response = await http.post(
        Uri.parse('https://truemotors.in/ai/api/m_api/'),
        body: requestBody,
      );

      print('--- FETCH PRIVACY POLICY RESPONSE ---');
      print('STATUS: ${response.statusCode}');
      print('BODY: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success' && data['data'] != null) {
          _privacySections = (data['data'] as List)
              .map((e) => TermsSection.fromJson(e))
              .toList();
        } else {
          _privacyErrorMessage = data['message'] ?? 'Failed to fetch Privacy Policy';
        }
      } else {
        _privacyErrorMessage = 'Server Error: ${response.statusCode}';
      }
    } catch (e) {
      _privacyErrorMessage = 'An error occurred: $e';
    }

    _isPrivacyLoading = false;
    notifyListeners();
  }
}
