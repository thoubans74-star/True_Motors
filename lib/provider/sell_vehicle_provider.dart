import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:true_motors/utils/shared_prefs_helper.dart';

// ─── VEHICLE TYPE MODEL (API 2527) ──────────────────────────────────────────
class VehicleTypeItem {
  final int id;
  final String vehName;

  VehicleTypeItem({
    required this.id,
    required this.vehName,
  });

  factory VehicleTypeItem.fromJson(Map<String, dynamic> json) {
    return VehicleTypeItem(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      vehName: (json['veh_name'] ?? json['name'] ?? '').toString().trim(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'veh_name': vehName,
      };

  @override
  String toString() => vehName;
}

// ─── BRAND ITEM MODEL (API 2530, 2533) ───────────────────────────────────────
class BrandItem {
  final int id;
  final String name;
  final int vehicleId;
  final String? vehName;

  BrandItem({
    this.id = 0,
    required this.name,
    this.vehicleId = 0,
    this.vehName,
  });

  factory BrandItem.fromJson(Map<String, dynamic> json) {
    return BrandItem(
      id: int.tryParse(
            (json['id'] ?? json['brand_id'])?.toString() ?? '0',
          ) ??
          0,
      name: (json['name'] ?? json['brand_name'] ?? '').toString().trim(),
      vehicleId: int.tryParse(
            (json['vehicle_id'] ?? json['vehi_id'] ?? json['veh_id'])
                    ?.toString() ??
                '0',
          ) ??
          0,
      vehName: json['veh_name']?.toString().trim(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'vehicle_id': vehicleId,
        if (vehName != null) 'veh_name': vehName,
      };

  BrandItem copyWith({
    int? id,
    String? name,
    int? vehicleId,
    String? vehName,
  }) {
    return BrandItem(
      id: id ?? this.id,
      name: name ?? this.name,
      vehicleId: vehicleId ?? this.vehicleId,
      vehName: vehName ?? this.vehName,
    );
  }

  @override
  String toString() => name;
}

// ─── MODEL ITEM MODEL (API 2529, 2531) ───────────────────────────────────────
class ModelItem {
  final int id;
  final String name;
  final String brand;
  final int brandId;
  final String? cat;
  final int? vehId;

  ModelItem({
    this.id = 0,
    required this.name,
    this.brand = '',
    this.brandId = 0,
    this.cat,
    this.vehId,
  });

  factory ModelItem.fromJson(Map<String, dynamic> json) {
    return ModelItem(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: (json['model'] ?? json['name'] ?? '').toString().trim(),
      brand: (json['brand'] ?? json['brand_name'] ?? '').toString().trim(),
      brandId: int.tryParse(
            (json['brand_id'] ?? json['brandId'])?.toString() ?? '0',
          ) ??
          0,
      cat: json['cat']?.toString().trim(),
      vehId: int.tryParse(json['veh_id']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'model': name,
        'brand': brand,
        'brand_id': brandId,
        if (cat != null) 'cat': cat,
        if (vehId != null) 'veh_id': vehId,
      };

  ModelItem copyWith({
    int? id,
    String? name,
    String? brand,
    int? brandId,
    String? cat,
    int? vehId,
  }) {
    return ModelItem(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      brandId: brandId ?? this.brandId,
      cat: cat ?? this.cat,
      vehId: vehId ?? this.vehId,
    );
  }

  @override
  String toString() => name;
}

// ─── SELL VEHICLE PROVIDER ───────────────────────────────────────────────────
class SellVehicleProvider with ChangeNotifier {
  static const String _baseUrl = 'https://truemotors.in/ai/api/m_api/';

  // ── Loading & Error States ──
  bool _isVehicleTypesLoading = false;
  bool get isVehicleTypesLoading => _isVehicleTypesLoading;

  bool _isBrandsLoading = false;
  bool get isBrandsLoading => _isBrandsLoading;

  bool _isModelsLoading = false;
  bool get isModelsLoading => _isModelsLoading;

  bool _isAllModelsLoading = false;
  bool get isAllModelsLoading => _isAllModelsLoading;

  String? _vehicleTypesError;
  String? get vehicleTypesError => _vehicleTypesError;

  String? _brandsError;
  String? get brandsError => _brandsError;

  String? _modelsError;
  String? get modelsError => _modelsError;

  // ── Data Lists ──
  List<VehicleTypeItem> _vehicleTypes = [];
  List<VehicleTypeItem> get vehicleTypes => _vehicleTypes;

  // Standalone brands list from API 2530 (used for brand_id resolution)
  List<BrandItem> _allBrands = [];
  List<BrandItem> get allBrands => _allBrands;

  // Cascaded brands (filtered by vehicle_id via API 2533, or standalone API 2530)
  List<BrandItem> _brands = [];
  List<BrandItem> get brands => _brands;

  // Standalone models list from API 2531
  List<ModelItem> _standaloneModels = [];
  List<ModelItem> get standaloneModels => _standaloneModels;

  // Brand-filtered models from API 2529
  List<ModelItem> _models = [];
  List<ModelItem> get models => _models;

  // ── Current Selections ──
  VehicleTypeItem? _selectedVehicleType;
  VehicleTypeItem? get selectedVehicleType => _selectedVehicleType;

  BrandItem? _selectedBrand;
  BrandItem? get selectedBrand => _selectedBrand;

  ModelItem? _selectedModel;
  ModelItem? get selectedModel => _selectedModel;

  // ── Convenient Helpers for Dropdowns ──
  /// Distinct vehicle type names
  List<String> get vehicleTypeNames =>
      _vehicleTypes.map((v) => v.vehName).where((n) => n.isNotEmpty).toList();

  /// Returns distinct brand names for the UI dropdown
  List<String> get uniqueBrandNames {
    final seen = <String>{};
    return _brands
        .map((b) => b.name)
        .where((name) => name.isNotEmpty && seen.add(name))
        .toList();
  }

  /// Returns distinct model names for the UI dropdown
  List<String> get uniqueModelNames {
    final seen = <String>{};
    final list = <String>[];

    for (final m in _models) {
      final key = m.name.trim().toLowerCase();
      if (key.isNotEmpty && seen.add(key)) {
        list.add(m.name.trim());
      }
    }

    if (_selectedBrand != null) {
      final brandClean = _selectedBrand!.name.trim().toLowerCase();
      final brandId = _selectedBrand!.id;
      for (final sm in _standaloneModels) {
        final matchesBrand = (brandId > 0 && sm.brandId == brandId) ||
            (brandClean.isNotEmpty &&
                sm.brand.trim().toLowerCase() == brandClean);
        if (matchesBrand) {
          final key = sm.name.trim().toLowerCase();
          if (key.isNotEmpty && seen.add(key)) {
            list.add(sm.name.trim());
          }
        }
      }
    }
    return list;
  }

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
    final lt = await SharedPrefsHelper.getLt() ?? '9090';
    final ln = await SharedPrefsHelper.getLn() ?? '9090';

    return {
      'cid': cid,
      'device_id': deviceId,
      'lt': lt,
      'ln': ln,
    };
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 1. VEHICLE TYPE API (type: 2527)
  // Fetches list of all vehicle types (Car, Bikes, etc.)
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> fetchVehicleTypes() async {
    _isVehicleTypesLoading = true;
    _vehicleTypesError = null;
    notifyListeners();

    try {
      final commonParams = await _getCommonParams();
      final params = {
        'type': '2527',
        ...commonParams,
      };

      debugPrint('┌─────────────────────────────────────────────');
      debugPrint('│ [SellVehicleProvider] 1. FETCH VEHICLE TYPES (type: 2527)');
      debugPrint('│ URL    : $_baseUrl');
      debugPrint('│ Params : $params');
      debugPrint('└─────────────────────────────────────────────');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'User-Agent': 'TrueMotors/1.0',
        },
        body: params,
      );

      debugPrint('┌─────────────────────────────────────────────');
      debugPrint('│ [SellVehicleProvider] FETCH VEHICLE TYPES RESPONSE');
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
        _vehicleTypes =
            list.map((item) => VehicleTypeItem.fromJson(item)).toList();
      } else {
        _vehicleTypesError =
            json['message'] ?? 'Failed to fetch vehicle types';
      }
    } catch (e) {
      _vehicleTypesError = e.toString();
      debugPrint('[SellVehicleProvider] fetchVehicleTypes Error: $e');
    } finally {
      _isVehicleTypesLoading = false;
      notifyListeners();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. STANDALONE BRAND API (type: 2530)
  // Fetches list of all vehicle brands with their IDs and vehicle_ids
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> fetchBrands() async {
    _isBrandsLoading = true;
    _brandsError = null;
    notifyListeners();

    try {
      final commonParams = await _getCommonParams();
      final params = {
        'type': '2530',
        ...commonParams,
      };

      debugPrint('┌─────────────────────────────────────────────');
      debugPrint('│ [SellVehicleProvider] 2. FETCH BRANDS (type: 2530)');
      debugPrint('│ URL    : $_baseUrl');
      debugPrint('│ Params : $params');
      debugPrint('└─────────────────────────────────────────────');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'User-Agent': 'TrueMotors/1.0',
        },
        body: params,
      );

      debugPrint('┌─────────────────────────────────────────────');
      debugPrint('│ [SellVehicleProvider] FETCH BRANDS RESPONSE');
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
        _allBrands = list.map((item) => BrandItem.fromJson(item)).toList();
        // If no vehicle-specific brands loaded yet, default to all brands
        if (_brands.isEmpty) {
          _brands = List.from(_allBrands);
        }
      } else {
        _brandsError = json['message'] ?? 'Failed to fetch brands';
      }
    } catch (e) {
      _brandsError = e.toString();
      debugPrint('[SellVehicleProvider] fetchBrands Error: $e');
    } finally {
      _isBrandsLoading = false;
      notifyListeners();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. STANDALONE MODEL API (type: 2531)
  // Standalone list of all vehicle models
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> fetchStandaloneModels() async {
    _isAllModelsLoading = true;
    _modelsError = null;
    notifyListeners();

    try {
      final commonParams = await _getCommonParams();
      final params = {
        'type': '2531',
        ...commonParams,
      };

      debugPrint('┌─────────────────────────────────────────────');
      debugPrint('│ [SellVehicleProvider] 3. FETCH STANDALONE MODELS (type: 2531)');
      debugPrint('│ URL    : $_baseUrl');
      debugPrint('│ Params : $params');
      debugPrint('└─────────────────────────────────────────────');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'User-Agent': 'TrueMotors/1.0',
        },
        body: params,
      );

      if (response.statusCode == 200) {
        final cleanJson = _extractJson(response.body);
        final Map<String, dynamic> json = jsonDecode(cleanJson);

        if (json['error'] == false && json['data'] != null) {
          final List<dynamic> list = json['data'];
          _standaloneModels =
              list.map((item) => ModelItem.fromJson(item)).toList();
        } else {
          _modelsError = json['message'] ?? 'Failed to fetch standalone models';
        }
      }
    } catch (e) {
      _modelsError = e.toString();
      debugPrint('[SellVehicleProvider] fetchStandaloneModels Error: $e');
    } finally {
      _isAllModelsLoading = false;
      notifyListeners();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. COMBINE VEHICLE TYPE AND BRAND API (type: 2533)
  // Fetches brands for a specific vehicle_id
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> fetchBrandsByVehicleType(int vehicleId) async {
    _isBrandsLoading = true;
    _brandsError = null;
    _brands = [];
    _selectedBrand = null;
    _selectedModel = null;
    _models = [];
    notifyListeners();

    try {
      final commonParams = await _getCommonParams();
      final params = {
        'type': '2533',
        ...commonParams,
        'vehicle_id': vehicleId.toString(),
      };

      debugPrint('┌─────────────────────────────────────────────');
      debugPrint('│ [SellVehicleProvider] 4. FETCH BRANDS BY VEHICLE TYPE (type: 2533)');
      debugPrint('│ Vehicle ID : $vehicleId');
      debugPrint('│ URL        : $_baseUrl');
      debugPrint('│ Params     : $params');
      debugPrint('└─────────────────────────────────────────────');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'User-Agent': 'TrueMotors/1.0',
        },
        body: params,
      );

      debugPrint('┌─────────────────────────────────────────────');
      debugPrint('│ [SellVehicleProvider] BRANDS BY VEHICLE TYPE RESPONSE');
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
        _brands = list.map((item) {
          final brand = BrandItem.fromJson(item);
          // If ID is missing in 2533 response, resolve it from _allBrands (from 2530)
          if (brand.id == 0 && _allBrands.isNotEmpty) {
            final match = _allBrands.where(
              (b) => b.name.toLowerCase() == brand.name.toLowerCase(),
            ).firstOrNull;
            if (match != null && match.id > 0) {
              return brand.copyWith(id: match.id);
            }
          }
          return brand;
        }).toList();
      } else {
        _brandsError = json['message'] ?? 'No brands found for selected vehicle type';
      }
    } catch (e) {
      _brandsError = e.toString();
      debugPrint('[SellVehicleProvider] fetchBrandsByVehicleType Error: $e');
    } finally {
      _isBrandsLoading = false;
      notifyListeners();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 5. COMBINE BRAND AND MODEL API (type: 2529)
  // Fetches models for a specific brand_id
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> fetchModelsByBrand(int brandId, {String? brandName}) async {
    _isModelsLoading = true;
    _modelsError = null;
    _models = [];
    _selectedModel = null;
    notifyListeners();

    try {
      final commonParams = await _getCommonParams();
      final params = {
        'type': '2529',
        ...commonParams,
        'brand_id': brandId.toString(),
      };

      debugPrint('┌─────────────────────────────────────────────');
      debugPrint('│ [SellVehicleProvider] 5. FETCH MODELS BY BRAND (type: 2529)');
      debugPrint('│ Brand ID : $brandId (${brandName ?? ""})');
      debugPrint('│ URL      : $_baseUrl');
      debugPrint('│ Params   : $params');
      debugPrint('└─────────────────────────────────────────────');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'User-Agent': 'TrueMotors/1.0',
        },
        body: params,
      );

      debugPrint('┌─────────────────────────────────────────────');
      debugPrint('│ [SellVehicleProvider] MODELS BY BRAND RESPONSE');
      debugPrint('│ Status : ${response.statusCode}');
      debugPrint('│ Body   : ${response.body}');
      debugPrint('└─────────────────────────────────────────────');

      if (response.statusCode != 200) {
        throw Exception('Server returned status ${response.statusCode}');
      }

      final cleanJson = _extractJson(response.body);
      final Map<String, dynamic> json = jsonDecode(cleanJson);

      // Ensure standalone models (API 2531) are loaded for exact database IDs
      if (_standaloneModels.isEmpty) {
        await fetchStandaloneModels();
      }

      if (json['error'] == false) {
        List<dynamic> modelList = [];
        if (json['data'] != null && json['data'] is List) {
          modelList = json['data'];
        } else if (json['form_MODULS'] != null && json['form_MODULS'] is List) {
          modelList = json['form_MODULS'];
        }

        final List<ModelItem> parsed =
            modelList.map((item) => ModelItem.fromJson(item)).toList();
        final List<ModelItem> enriched = [];

        for (final m in parsed) {
          if (m.id > 0) {
            enriched.add(m);
          } else {
            // Find model in _standaloneModels (API 2531) to get the real database ID
            final match = _standaloneModels.where((sm) =>
              sm.name.toLowerCase() == m.name.toLowerCase() &&
              (sm.brandId == brandId ||
               (brandName != null && sm.brand.toLowerCase() == brandName.toLowerCase()))
            ).firstOrNull ?? _standaloneModels.where((sm) =>
              sm.name.toLowerCase() == m.name.toLowerCase()
            ).firstOrNull;

            if (match != null && match.id > 0) {
              enriched.add(m.copyWith(
                id: match.id,
                brandId: match.brandId > 0 ? match.brandId : (brandId > 0 ? brandId : m.brandId),
                cat: match.cat ?? m.cat,
                vehId: match.vehId ?? m.vehId,
              ));
            } else {
              enriched.add(m);
            }
          }
        }

        // Also add any models for this brand from API 2531 that were not in 2529
        final standaloneForBrand = _standaloneModels.where((sm) {
          if (brandId > 0 && sm.brandId == brandId) return true;
          if (brandName != null &&
              brandName.isNotEmpty &&
              sm.brand.toLowerCase() == brandName.toLowerCase()) {
            return true;
          }
          return false;
        }).toList();

        for (final sm in standaloneForBrand) {
          if (!enriched.any((e) => e.name.toLowerCase() == sm.name.toLowerCase())) {
            enriched.add(sm);
          }
        }

        _models = enriched;
        if (_models.isNotEmpty) {
          _modelsError = null;
        }
      } else {
        _modelsError = json['message'] ?? 'No models found for this brand';
      }

      // Fallback: If _models is empty but we have standalone models from 2531
      if (_models.isEmpty && _standaloneModels.isNotEmpty) {
        final fallback = _standaloneModels.where((m) {
          if (brandId > 0 && m.brandId == brandId) return true;
          if (brandName != null &&
              brandName.isNotEmpty &&
              m.brand.toLowerCase() == brandName.toLowerCase()) {
            return true;
          }
          return false;
        }).toList();
        if (fallback.isNotEmpty) {
          _models = fallback;
          _modelsError = null;
        }
      }
    } catch (e) {
      _modelsError = e.toString();
      debugPrint('[SellVehicleProvider] fetchModelsByBrand Error: $e');
    } finally {
      _isModelsLoading = false;
      notifyListeners();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CASCADING SELECTION LOGIC
  // ═══════════════════════════════════════════════════════════════════════════

  /// Select vehicle type by model item
  Future<void> onVehicleTypeSelected(VehicleTypeItem? vehicleType) async {
    _selectedVehicleType = vehicleType;
    _selectedBrand = null;
    _selectedModel = null;
    _models = [];

    if (vehicleType != null) {
      await fetchBrandsByVehicleType(vehicleType.id);
    } else {
      _brands = List.from(_allBrands);
      notifyListeners();
    }
  }

  /// Select vehicle type by string name
  Future<void> selectVehicleTypeByName(String typeName) async {
    final cleanName = typeName.trim().toLowerCase();

    // Match exact or contains (e.g. "car" vs "Cars", "bike" vs "Bikes / Two-Wheelers")
    var vehicleType = _vehicleTypes.where(
      (v) => v.vehName.toLowerCase() == cleanName,
    ).firstOrNull;

    vehicleType ??= _vehicleTypes.where(
      (v) =>
          v.vehName.toLowerCase().contains(cleanName) ||
          cleanName.contains(v.vehName.toLowerCase()),
    ).firstOrNull;

    if (vehicleType != null) {
      await onVehicleTypeSelected(vehicleType);
    } else {
      // If vehicle types list not yet loaded or not found, try to fetch first
      if (_vehicleTypes.isEmpty) {
        await fetchVehicleTypes();
        vehicleType = _vehicleTypes.where(
          (v) =>
              v.vehName.toLowerCase() == cleanName ||
              v.vehName.toLowerCase().contains(cleanName) ||
              cleanName.contains(v.vehName.toLowerCase()),
        ).firstOrNull;
        if (vehicleType != null) {
          await onVehicleTypeSelected(vehicleType);
          return;
        }
      }
      _selectedVehicleType = null;
      _selectedBrand = null;
      _selectedModel = null;
      _brands = List.from(_allBrands);
      notifyListeners();
    }
  }

  /// Select brand by string name
  Future<void> selectBrandByName(String brandName) async {
    final cleanBrand = brandName.trim().toLowerCase();

    // Find brand from current list or fallback to allBrands
    var brand = _brands.where(
      (b) => b.name.toLowerCase() == cleanBrand,
    ).firstOrNull;

    brand ??= _allBrands.where(
      (b) => b.name.toLowerCase() == cleanBrand,
    ).firstOrNull;

    if (brand != null) {
      // Ensure we have a valid brand_id
      int brandId = brand.id;
      if (brandId == 0) {
        final resolved = _allBrands.where(
          (b) => b.name.toLowerCase() == cleanBrand,
        ).firstOrNull;
        if (resolved != null && resolved.id > 0) {
          brandId = resolved.id;
          brand = brand.copyWith(id: brandId);
        }
      }

      _selectedBrand = brand;
      _selectedModel = null;
      _models = [];

      if (brandId > 0) {
        await fetchModelsByBrand(brandId, brandName: brand.name);
      } else {
        // If still 0, try fetching standalone models and filter
        if (_standaloneModels.isEmpty) {
          await fetchStandaloneModels();
        }
        _models = _standaloneModels.where(
          (m) => m.brand.toLowerCase() == cleanBrand,
        ).toList();
        notifyListeners();
      }
    } else {
      _selectedBrand = null;
      _selectedModel = null;
      _models = [];
      notifyListeners();
    }
  }

  /// Select model by string name
  void selectModelByName(String modelName) {
    final clean = modelName.trim().toLowerCase();
    if (clean.isEmpty) {
      _selectedModel = null;
      notifyListeners();
      return;
    }

    // 1. Look in _models with a positive ID
    var found = _models.where(
      (m) => m.name.trim().toLowerCase() == clean && m.id > 0,
    ).firstOrNull;

    // 2. Look in _standaloneModels (API 2531) matching brand
    if (found == null || found.id == 0) {
      final match = _standaloneModels.where(
        (sm) =>
            sm.name.trim().toLowerCase() == clean &&
            sm.id > 0 &&
            (_selectedBrand == null ||
             sm.brand.trim().toLowerCase() == _selectedBrand!.name.trim().toLowerCase() ||
             (sm.brandId > 0 && sm.brandId == _selectedBrand!.id)),
      ).firstOrNull;

      if (match != null) {
        found = match;
      }
    }

    // 3. Look in _standaloneModels by name alone
    if (found == null || found.id == 0) {
      final match = _standaloneModels.where(
        (sm) => sm.name.trim().toLowerCase() == clean && sm.id > 0,
      ).firstOrNull;

      if (match != null) {
        found = match;
      }
    }

    // 4. Fallback to _models even if id == 0
    found ??= _models.where(
      (m) => m.name.trim().toLowerCase() == clean,
    ).firstOrNull;

    _selectedModel = found;
    debugPrint('[SellVehicleProvider] selectModelByName("$modelName") -> ID: ${_selectedModel?.id}, Brand: ${_selectedModel?.brand}');
    notifyListeners();
  }

  /// Helper to get model ID by name from models or standalone models (API 2531)
  int? getModelIdByName(String modelName, {int? brandId, String? brandName}) {
    final clean = modelName.trim().toLowerCase();
    if (clean.isEmpty) return null;

    if (_selectedModel != null &&
        _selectedModel!.name.trim().toLowerCase() == clean &&
        _selectedModel!.id > 0) {
      return _selectedModel!.id;
    }

    for (final m in _models) {
      if (m.name.trim().toLowerCase() == clean && m.id > 0) {
        return m.id;
      }
    }

    for (final sm in _standaloneModels) {
      final matchesBrand = (brandId != null && brandId > 0 && sm.brandId == brandId) ||
          (brandName != null &&
              brandName.trim().isNotEmpty &&
              sm.brand.trim().toLowerCase() == brandName.trim().toLowerCase());
      if (matchesBrand && sm.name.trim().toLowerCase() == clean && sm.id > 0) {
        return sm.id;
      }
    }

    for (final sm in _standaloneModels) {
      if (sm.name.trim().toLowerCase() == clean && sm.id > 0) {
        return sm.id;
      }
    }

    return null;
  }

  /// Reset all selections
  void resetSelections() {
    _selectedVehicleType = null;
    _selectedBrand = null;
    _selectedModel = null;
    _models = [];
    _brands = List.from(_allBrands);
    _vehicleTypesError = null;
    _brandsError = null;
    _modelsError = null;
    notifyListeners();
  }
}

