import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:true_motors/utils/shared_prefs_helper.dart';

// ─── COMMON DROPDOWN ITEM MODEL ──────────────────────────────────────────────
class CommonDropdownItem {
  final int id;
  final String name;
  final String? featureName;
  final String? code;
  final int? aid;
  final int? uid;
  final int? bid;
  final int? did;
  final int? cid;
  final String? dtime;
  final dynamic del;
  final dynamic age;

  CommonDropdownItem({
    required this.id,
    required this.name,
    this.featureName,
    this.code,
    this.aid,
    this.uid,
    this.bid,
    this.did,
    this.cid,
    this.dtime,
    this.del,
    this.age,
  });

  factory CommonDropdownItem.fromJson(Map<String, dynamic> json) {
    final featureName = json['feature_name']?.toString().trim();
    final rawName =
        (json['name'] ?? json['cat_name'] ?? json['title'] ?? '').toString().trim();
    final resolvedName = (featureName != null && featureName.isNotEmpty)
        ? featureName
        : rawName;

    return CommonDropdownItem(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: resolvedName,
      featureName: featureName,
      code: json['code']?.toString(),
      aid: int.tryParse(json['aid']?.toString() ?? ''),
      uid: int.tryParse(json['uid']?.toString() ?? ''),
      bid: int.tryParse(json['bid']?.toString() ?? ''),
      did: int.tryParse(json['did']?.toString() ?? ''),
      cid: int.tryParse(json['cid']?.toString() ?? ''),
      dtime: json['dtime']?.toString(),
      del: json['del'],
      age: json['age'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'feature_name': featureName,
        'code': code,
        'aid': aid,
        'uid': uid,
        'bid': bid,
        'did': did,
        'cid': cid,
        'dtime': dtime,
        'del': del,
        'age': age,
      };

  @override
  String toString() => name;
}

// ─── LIST DROPDOWN ITEM MODEL (API 2506) ─────────────────────────────────────
class ListDropdownItem {
  final int id;
  final String value;
  final String label;

  ListDropdownItem({
    required this.id,
    required this.value,
    required this.label,
  });

  factory ListDropdownItem.fromJson(Map<String, dynamic> json) {
    return ListDropdownItem(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      value: (json['value'] ?? '').toString().trim(),
      label: (json['label'] ?? json['name'] ?? '').toString().trim(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'value': value,
        'label': label,
      };

  @override
  String toString() => label;
}

// ─── COMMON DROPDOWN PROVIDER ────────────────────────────────────────────────
class CommonDropdownProvider with ChangeNotifier {
  static const String _baseUrl = 'https://truemotors.in/ai/api/m_api/';

  // ── Cache for dynamic forms (type: 2503): formId -> List of items ──
  final Map<String, List<CommonDropdownItem>> _formData = {};
  final Map<String, bool> _loadingStates = {};
  final Map<String, String?> _errorStates = {};

  // ── Cache for list dropdowns (type: 2506): listId -> List of items ──
  final Map<String, List<ListDropdownItem>> _listDropdownData = {};
  final Map<String, bool> _listLoadingStates = {};
  final Map<String, String?> _listErrorStates = {};

  // ── Cache for category dropdown (type: 2517) ──
  List<CommonDropdownItem> _categoryData = [];
  bool _isCategoryLoading = false;
  String? _categoryError;

  // ── Vehicle Condition List Constant (type: 2506) ──
  static const String vehicleConditionListId = '919';

  // ── Fuel Type Form Constant ──
  static const String fuelTypeFormId = 'sm_main_form_10100';

  // ── Transmission Form Constant ──
  static const String transmissionFormId = 'sm_main_form_10109';

  // ── Owner Form Constant ──
  static const String ownerFormId = 'sm_main_form_10114';

  // ── Color Form Constant ──
  static const String colorFormId = 'sm_main_form_402';

  // ── Feature Checklist Form Constant ──
  static const String featureFormId = 'sm_main_form_2005';

  // ── Convenience Getters for Vehicle Condition (list_id: 919) ──
  List<ListDropdownItem> get conditionItems =>
      _listDropdownData[vehicleConditionListId] ?? [];

  List<String> get conditionLabels =>
      conditionItems.map((e) => e.label).toList();

  bool get isConditionLoading =>
      _listLoadingStates[vehicleConditionListId] ?? false;

  String? get conditionError => _listErrorStates[vehicleConditionListId];

  String? getConditionValueByLabel(String label) {
    for (final item in conditionItems) {
      if (item.label.toLowerCase() == label.toLowerCase()) {
        return item.value;
      }
    }
    return null;
  }

  String? getConditionLabelByValue(String value) {
    for (final item in conditionItems) {
      if (item.value == value) {
        return item.label;
      }
    }
    return null;
  }

  // ── Convenience Getters for Fuel Type ──
  List<CommonDropdownItem> get fuelTypeItems =>
      _formData[fuelTypeFormId] ?? [];

  List<String> get fuelTypeNames =>
      fuelTypeItems.map((e) => e.name).toList();

  bool get isFuelTypeLoading => _loadingStates[fuelTypeFormId] ?? false;

  String? get fuelTypeError => _errorStates[fuelTypeFormId];

  // ── Convenience Getters for Transmission ──
  List<CommonDropdownItem> get transmissionItems =>
      _formData[transmissionFormId] ?? [];

  List<String> get transmissionNames =>
      transmissionItems.map((e) => e.name).toList();

  bool get isTransmissionLoading =>
      _loadingStates[transmissionFormId] ?? false;

  String? get transmissionError => _errorStates[transmissionFormId];

  // ── Convenience Getters for Category (type: 2517) ──
  List<CommonDropdownItem> get categoryItems => _categoryData;

  List<String> get categoryNames =>
      _categoryData.map((e) => e.name).where((name) => name.isNotEmpty).toList();

  bool get isCategoryLoading => _isCategoryLoading;

  String? get categoryError => _categoryError;

  String? getCategoryNameById(int id) {
    for (final item in _categoryData) {
      if (item.id == id) {
        return item.name;
      }
    }
    return null;
  }

  int? getCategoryIdByName(String name) {
    for (final item in _categoryData) {
      if (item.name.toLowerCase() == name.toLowerCase()) {
        return item.id;
      }
    }
    return null;
  }

  // ── Convenience Getters for Owner ──
  List<CommonDropdownItem> get ownerItems =>
      _formData[ownerFormId] ?? [];

  List<String> get ownerNames =>
      ownerItems.map((e) => e.name).toList();

  bool get isOwnerLoading =>
      _loadingStates[ownerFormId] ?? false;

  String? get ownerError => _errorStates[ownerFormId];

  // ── Convenience Getters for Color ──
  List<CommonDropdownItem> get colorItems =>
      _formData[colorFormId] ?? [];

  List<String> get colorNames =>
      colorItems.map((e) => e.name).toList();

  bool get isColorLoading =>
      _loadingStates[colorFormId] ?? false;

  String? get colorError => _errorStates[colorFormId];

  // ── Convenience Getters for Features (form: sm_main_form_2005) ──
  List<CommonDropdownItem> get featureItems =>
      _formData[featureFormId] ?? [];

  List<String> get featureNames => featureItems
      .map((e) => e.name)
      .where((name) => name.isNotEmpty)
      .toList();

  bool get isFeatureLoading => _loadingStates[featureFormId] ?? false;

  String? get featureError => _errorStates[featureFormId];

  // ── Generic Getters ──
  List<CommonDropdownItem> getItems(String formId) =>
      _formData[formId] ?? [];

  List<String> getItemNames(String formId) =>
      getItems(formId).map((e) => e.name).toList();

  bool isLoading(String formId) => _loadingStates[formId] ?? false;

  String? getError(String formId) => _errorStates[formId];

  // ── Clean JSON parser helper ──
  String _extractJson(String raw) {
    final start = raw.indexOf('{');
    if (start == -1) {
      throw const FormatException('No JSON object found in response');
    }
    return raw.substring(start);
  }

  // ── Common Request Headers/Params ──
  Future<Map<String, String>> _getCommonParams() async {
    final cid = await SharedPrefsHelper.getCid() ?? '21472147';
    final deviceId = await SharedPrefsHelper.getDeviceId() ?? '123';
    final lt = await SharedPrefsHelper.getLt() ?? '123';
    final ln = await SharedPrefsHelper.getLn() ?? '123';

    return {
      'cid': cid,
      'device_id': deviceId,
      'lt': lt,
      'ln': ln,
    };
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GENERIC DROPDOWN FETCH METHOD (type: 2503)
  // Can be called with any form/table ID (e.g. 'sm_main_form_10100')
  // ═══════════════════════════════════════════════════════════════════════════
  Future<List<CommonDropdownItem>> fetchDropdownData(
    String formId, {
    String? select,
  }) async {
    _loadingStates[formId] = true;
    _errorStates[formId] = null;
    notifyListeners();

    try {
      final commonParams = await _getCommonParams();
      final params = {
        'type': '2503',
        ...commonParams,
        'form': formId,
        if (select != null && select.isNotEmpty) 'select': select,
      };

      debugPrint('┌─────────────────────────────────────────────');
      debugPrint('│ [CommonDropdownProvider] FETCH DROPDOWN REQUEST');
      debugPrint('│ Form   : $formId');
      debugPrint('│ URL    : $_baseUrl');
      debugPrint('│ Params : $params');
      debugPrint('└─────────────────────────────────────────────');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: params,
      );

      debugPrint('┌─────────────────────────────────────────────');
      debugPrint('│ [CommonDropdownProvider] FETCH DROPDOWN RESPONSE ($formId)');
      debugPrint('│ Status : ${response.statusCode}');
      debugPrint('│ Body   : ${response.body}');
      debugPrint('└─────────────────────────────────────────────');

      if (response.statusCode != 200) {
        throw Exception('Server returned status ${response.statusCode}');
      }

      final cleanJson = _extractJson(response.body);
      final Map<String, dynamic> json = jsonDecode(cleanJson);

      if (json['error'] == false && json['data'] != null) {
        final List<dynamic> list = json['data'];
        final items =
            list.map((item) => CommonDropdownItem.fromJson(item)).toList();
        _formData[formId] = items;
        return items;
      } else {
        final errorMsg = json['message'] ?? 'Failed to fetch dropdown data';
        _errorStates[formId] = errorMsg;
        return [];
      }
    } catch (e) {
      _errorStates[formId] = e.toString();
      debugPrint('[CommonDropdownProvider] ($formId) Error: $e');
      return [];
    } finally {
      _loadingStates[formId] = false;
      notifyListeners();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CONVENIENCE METHOD: FETCH FUEL TYPES (form: sm_main_form_10100)
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> fetchFuelTypes() async {
    await fetchDropdownData(fuelTypeFormId);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CONVENIENCE METHOD: FETCH TRANSMISSIONS (form: sm_main_form_10109)
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> fetchTransmissions() async {
    await fetchDropdownData(transmissionFormId);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CONVENIENCE METHOD: FETCH CATEGORIES (type: 2517)
  // ═══════════════════════════════════════════════════════════════════════════
  Future<List<CommonDropdownItem>> fetchCategories() async {
    _isCategoryLoading = true;
    _categoryError = null;
    notifyListeners();

    try {
      final cid = await SharedPrefsHelper.getCid() ?? '21472147';
      final deviceId = await SharedPrefsHelper.getDeviceId() ?? '123';

      final params = {
        'type': '2517',
        'cid': cid.isNotEmpty ? cid : '21472147',
        'device_id': deviceId.isNotEmpty ? deviceId : '123',
        'ln': '9090',
        'lt': '9090',
      };

      debugPrint('┌─────────────────────────────────────────────');
      debugPrint('│ [CommonDropdownProvider] FETCH CATEGORIES (2517)');
      debugPrint('│ URL    : $_baseUrl');
      debugPrint('│ Params : $params');
      debugPrint('└─────────────────────────────────────────────');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
        },
        body: params,
      );

      debugPrint('┌─────────────────────────────────────────────');
      debugPrint('│ [CommonDropdownProvider] CATEGORIES RESPONSE (2517)');
      debugPrint('│ Status : ${response.statusCode}');
      debugPrint('│ Body   : ${response.body}');
      debugPrint('└─────────────────────────────────────────────');

      if (response.statusCode != 200) {
        throw Exception('Server returned status ${response.statusCode}');
      }

      final cleanJson = _extractJson(response.body);
      final Map<String, dynamic> json = jsonDecode(cleanJson);

      if (json['error'] == false && json['data'] != null) {
        final List<dynamic> list = json['data'];
        final items =
            list.map((item) => CommonDropdownItem.fromJson(item)).toList();
        _categoryData = items;
        return items;
      } else {
        final errorMsg = json['message'] ?? 'Failed to fetch categories';
        _categoryError = errorMsg;
        return [];
      }
    } catch (e) {
      _categoryError = e.toString();
      debugPrint('[CommonDropdownProvider] (type: 2517) Error: $e');
      return [];
    } finally {
      _isCategoryLoading = false;
      notifyListeners();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CONVENIENCE METHOD: FETCH OWNERS (form: sm_main_form_10114)
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> fetchOwners() async {
    await fetchDropdownData(ownerFormId);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CONVENIENCE METHOD: FETCH COLORS (form: sm_main_form_402)
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> fetchColors() async {
    await fetchDropdownData(colorFormId);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CONVENIENCE METHOD: FETCH FEATURES (form: sm_main_form_2005)
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> fetchFeatures() async {
    await fetchDropdownData(featureFormId);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GENERIC LIST DROPDOWN FETCH METHOD (type: 2506)
  // Fetches list dropdown options by list_id (e.g. 919 for vehicle condition)
  // ═══════════════════════════════════════════════════════════════════════════
  Future<List<ListDropdownItem>> fetchListDropdownData(String listId) async {
    _listLoadingStates[listId] = true;
    _listErrorStates[listId] = null;
    notifyListeners();

    try {
      final commonParams = await _getCommonParams();
      final params = {
        'type': '2506',
        ...commonParams,
        'list_id': listId,
      };

      debugPrint('┌─────────────────────────────────────────────');
      debugPrint('│ [CommonDropdownProvider] FETCH LIST DROPDOWN (2506)');
      debugPrint('│ list_id : $listId');
      debugPrint('│ URL     : $_baseUrl');
      debugPrint('│ Params  : $params');
      debugPrint('└─────────────────────────────────────────────');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
        },
        body: params,
      );

      debugPrint('┌─────────────────────────────────────────────');
      debugPrint('│ [CommonDropdownProvider] LIST DROPDOWN RESPONSE ($listId)');
      debugPrint('│ Status : ${response.statusCode}');
      debugPrint('│ Body   : ${response.body}');
      debugPrint('└─────────────────────────────────────────────');

      if (response.statusCode != 200) {
        throw Exception('Server returned status ${response.statusCode}');
      }

      final cleanJson = _extractJson(response.body);
      final Map<String, dynamic> json = jsonDecode(cleanJson);

      if (json['error'] == false && json['dropdown'] != null) {
        final List<dynamic> list = json['dropdown'];
        final items =
            list.map((item) => ListDropdownItem.fromJson(item)).toList();
        _listDropdownData[listId] = items;
        return items;
      } else {
        final errorMsg = json['message'] ?? 'Failed to fetch dropdown data';
        _listErrorStates[listId] = errorMsg;
        return [];
      }
    } catch (e) {
      _listErrorStates[listId] = e.toString();
      debugPrint('[CommonDropdownProvider] (list_id: $listId) Error: $e');
      return [];
    } finally {
      _listLoadingStates[listId] = false;
      notifyListeners();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CONVENIENCE METHOD: FETCH VEHICLE CONDITIONS (list_id: 919)
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> fetchVehicleConditions() async {
    await fetchListDropdownData(vehicleConditionListId);
  }
}
