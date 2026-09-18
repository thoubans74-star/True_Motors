import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:true_motors/utils/shared_prefs_helper.dart';

// ─── LOCATION / DISTRICT MODEL ───────────────────────────────────────────────
class LocationDistrictItem {
  final int id;
  final String name;
  final int? aid;
  final int? uid;
  final int? bid;
  final int? did;
  final int? cid;
  final String? dtime;

  LocationDistrictItem({
    required this.id,
    required this.name,
    this.aid,
    this.uid,
    this.bid,
    this.did,
    this.cid,
    this.dtime,
  });

  factory LocationDistrictItem.fromJson(Map<String, dynamic> json) {
    return LocationDistrictItem(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: (json['name'] ?? json['district_name'] ?? '').toString().trim(),
      aid: int.tryParse(json['aid']?.toString() ?? ''),
      uid: int.tryParse(json['uid']?.toString() ?? ''),
      bid: int.tryParse(json['bid']?.toString() ?? ''),
      did: int.tryParse(json['did']?.toString() ?? ''),
      cid: int.tryParse(json['cid']?.toString() ?? ''),
      dtime: json['dtime']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'aid': aid,
        'uid': uid,
        'bid': bid,
        'did': did,
        'cid': cid,
        'dtime': dtime,
      };

  @override
  String toString() => name;
}

// ─── RTO LOCATION MODEL ──────────────────────────────────────────────────────
class RtoLocationItem {
  final int id;
  final String name;
  final String location;
  final int locId;
  final String? age;

  RtoLocationItem({
    required this.id,
    required this.name,
    this.location = '',
    this.locId = 0,
    this.age,
  });

  factory RtoLocationItem.fromJson(Map<String, dynamic> json) {
    return RtoLocationItem(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: (json['name'] ?? '').toString().trim(),
      location: (json['location'] ?? '').toString().trim(),
      locId: int.tryParse(
            (json['loc_id'] ?? json['locId'])?.toString() ?? '0',
          ) ??
          0,
      age: json['age']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'location': location,
        'loc_id': locId,
        'age': age,
      };

  /// Full display text e.g. "TN01 - Chennai (Central) Ayanavaram"
  String get displayName =>
      location.isNotEmpty ? '$name - $location' : name;

  @override
  String toString() => name;
}

// ─── RTO LOCATION PROVIDER ───────────────────────────────────────────────────
class RtoLocationProvider with ChangeNotifier {
  static const String _baseUrl = 'https://truemotors.in/ai/api/m_api/';

  // ── Form Constants ──
  static const String locationFormId = 'sm_main_form_10113';
  static const String rtoFormId = 'sm_main_form_10107';

  // ── State Variables ──
  List<LocationDistrictItem> _locations = [];
  List<LocationDistrictItem> get locations => _locations;

  List<RtoLocationItem> _standaloneRtos = [];
  List<RtoLocationItem> get standaloneRtos => _standaloneRtos;

  // Cascaded RTOs for currently selected location
  List<RtoLocationItem> _rtos = [];
  List<RtoLocationItem> get rtos => _rtos;

  LocationDistrictItem? _selectedLocation;
  LocationDistrictItem? get selectedLocation => _selectedLocation;

  RtoLocationItem? _selectedRto;
  RtoLocationItem? get selectedRto => _selectedRto;

  bool _isLocationsLoading = false;
  bool get isLocationsLoading => _isLocationsLoading;

  bool _isRtosLoading = false;
  bool get isRtosLoading => _isRtosLoading;

  String? _locationsError;
  String? get locationsError => _locationsError;

  String? _rtosError;
  String? get rtosError => _rtosError;

  // ── Convenient Helpers for UI Dropdowns ──
  List<String> get locationNames =>
      _locations.map((e) => e.name).where((n) => n.isNotEmpty).toList();

  List<String> get rtoNames =>
      _rtos.map((e) => e.name).where((n) => n.isNotEmpty).toList();

  List<String> get rtoDisplayNames =>
      _rtos.map((e) => e.displayName).where((n) => n.isNotEmpty).toList();

  // ── Helper: Extract clean JSON ──
  String _extractJson(String raw) {
    final start = raw.indexOf('{');
    if (start == -1) {
      throw const FormatException('No JSON object found in response');
    }
    return raw.substring(start);
  }

  // ── Helper: Common Request Parameters ──
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
  // 1. LOCATION API (type: 2503, form: sm_main_form_10113)
  // Fetches list of all districts / locations
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> fetchLocations() async {
    _isLocationsLoading = true;
    _locationsError = null;
    notifyListeners();

    try {
      final commonParams = await _getCommonParams();
      final params = {
        'type': '2503',
        ...commonParams,
        'form': locationFormId,
      };

      debugPrint('┌─────────────────────────────────────────────');
      debugPrint('│ [RtoLocationProvider] 1. FETCH LOCATIONS (type: 2503)');
      debugPrint('│ Form   : $locationFormId');
      debugPrint('│ URL    : $_baseUrl');
      debugPrint('│ Params : $params');
      debugPrint('└─────────────────────────────────────────────');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: params,
      );

      debugPrint('┌─────────────────────────────────────────────');
      debugPrint('│ [RtoLocationProvider] FETCH LOCATIONS RESPONSE');
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
        _locations =
            list.map((item) => LocationDistrictItem.fromJson(item)).toList();
      } else {
        _locationsError = json['message'] ?? 'Failed to fetch locations';
      }
    } catch (e) {
      _locationsError = e.toString();
      debugPrint('[RtoLocationProvider] fetchLocations Error: $e');
    } finally {
      _isLocationsLoading = false;
      notifyListeners();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. STANDALONE RTO API (type: 2503, form: sm_main_form_10107)
  // Fetches all RTOs in one standalone call
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> fetchStandaloneRtos() async {
    try {
      final commonParams = await _getCommonParams();
      final params = {
        'type': '2503',
        ...commonParams,
        'form': rtoFormId,
      };

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: params,
      );

      if (response.statusCode == 200) {
        final cleanJson = _extractJson(response.body);
        final Map<String, dynamic> json = jsonDecode(cleanJson);
        if (json['error'] == false && json['data'] != null) {
          final List<dynamic> list = json['data'];
          _standaloneRtos =
              list.map((item) => RtoLocationItem.fromJson(item)).toList();
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('[RtoLocationProvider] fetchStandaloneRtos Error: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. COMBINED LOCATION & RTO API (type: 2532)
  // Invoked when user selects a Location (district).
  // Passes id (district id) to retrieve RTOs for that location.
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> fetchRtosByLocationId(int locationId) async {
    _isRtosLoading = true;
    _rtosError = null;
    _rtos = [];
    notifyListeners();

    try {
      final commonParams = await _getCommonParams();
      final params = {
        'type': '2532',
        ...commonParams,
        'id': locationId.toString(),
      };

      debugPrint('┌─────────────────────────────────────────────');
      debugPrint('│ [RtoLocationProvider] 3. FETCH COMBINED RTO (type: 2532)');
      debugPrint('│ Location ID : $locationId');
      debugPrint('│ URL         : $_baseUrl');
      debugPrint('│ Params      : $params');
      debugPrint('└─────────────────────────────────────────────');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: params,
      );

      debugPrint('┌─────────────────────────────────────────────');
      debugPrint('│ [RtoLocationProvider] COMBINED RTO RESPONSE');
      debugPrint('│ Status : ${response.statusCode}');
      debugPrint('│ Body   : ${response.body}');
      debugPrint('└─────────────────────────────────────────────');

      if (response.statusCode != 200) {
        throw Exception('Server returned status ${response.statusCode}');
      }

      final cleanJson = _extractJson(response.body);
      final Map<String, dynamic> json = jsonDecode(cleanJson);

      if (json['error'] == false) {
        if (json['form_LOCATION'] != null && json['form_LOCATION'] is List) {
          final List<dynamic> list = json['form_LOCATION'];
          _rtos = list.map((item) => RtoLocationItem.fromJson(item)).toList();
        }
      } else {
        _rtosError = json['message'] ?? 'RTO data not found';
      }
    } catch (e) {
      _rtosError = e.toString();
      debugPrint('[RtoLocationProvider] fetchRtosByLocationId Error: $e');
    } finally {
      _isRtosLoading = false;
      notifyListeners();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CASCADING SELECTION LOGIC
  // ═══════════════════════════════════════════════════════════════════════════

  /// Select location by model item
  Future<void> selectLocation(LocationDistrictItem? location) async {
    _selectedLocation = location;
    _selectedRto = null;
    _rtos = [];

    if (location != null) {
      await fetchRtosByLocationId(location.id);
    } else {
      notifyListeners();
    }
  }

  /// Select location by string name (finds matching district in `_locations`)
  Future<void> selectLocationByName(String locationName) async {
    final location = _locations.where(
      (loc) => loc.name.toLowerCase() == locationName.toLowerCase(),
    ).firstOrNull;

    if (location != null) {
      await selectLocation(location);
    } else {
      _selectedLocation = null;
      _selectedRto = null;
      _rtos = [];
      notifyListeners();
    }
  }

  /// Select RTO by model item
  void selectRto(RtoLocationItem? rto) {
    _selectedRto = rto;
    notifyListeners();
  }

  /// Select RTO by string name
  void selectRtoByName(String rtoName) {
    _selectedRto = _rtos.where(
      (r) =>
          r.name.toLowerCase() == rtoName.toLowerCase() ||
          r.displayName.toLowerCase() == rtoName.toLowerCase(),
    ).firstOrNull;
    notifyListeners();
  }

  /// Reset all selections
  void resetSelections() {
    _selectedLocation = null;
    _selectedRto = null;
    _rtos = [];
    _locationsError = null;
    _rtosError = null;
    notifyListeners();
  }
}
