import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:true_motors/utils/shared_prefs_helper.dart';

// ─── STEP 1 RESPONSE MODEL ──────────────────────────────────────────────────
class Step1Response {
  final String status;
  final String message;
  final int step;
  final int id;
  final String listingId;
  final int userId;
  final String vehicleNo;

  Step1Response({
    required this.status,
    required this.message,
    required this.step,
    required this.id,
    required this.listingId,
    required this.userId,
    required this.vehicleNo,
  });

  factory Step1Response.fromJson(Map<String, dynamic> json) {
    return Step1Response(
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      step: int.tryParse(json['step']?.toString() ?? '1') ?? 1,
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      listingId: (json['listing_id'] ?? json['id'] ?? '').toString(),
      userId: int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      vehicleNo: json['vehicle_no']?.toString() ?? '',
    );
  }
}

// ─── STEP 2 RESPONSE MODEL ──────────────────────────────────────────────────
class Step2Response {
  final String status;
  final String message;
  final int step;
  final String listingId;
  final String? vehicleType;
  final String? vehicleCategory;
  final String? brand;
  final String? model;
  final String? fuelType;
  final String? manifactureYear;
  final String? regYear;
  final int? age;
  final String? regState;
  final String? regCity;
  final String? rtoLocation;
  final dynamic vehLocation;
  final dynamic kmDriven;
  final String? transmission;
  final String? noOfOwner;
  final String? colour;

  Step2Response({
    required this.status,
    required this.message,
    required this.step,
    required this.listingId,
    this.vehicleType,
    this.vehicleCategory,
    this.brand,
    this.model,
    this.fuelType,
    this.manifactureYear,
    this.regYear,
    this.age,
    this.regState,
    this.regCity,
    this.rtoLocation,
    this.vehLocation,
    this.kmDriven,
    this.transmission,
    this.noOfOwner,
    this.colour,
  });

  factory Step2Response.fromJson(Map<String, dynamic> json) {
    return Step2Response(
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      step: int.tryParse(json['step']?.toString() ?? '2') ?? 2,
      listingId: (json['listing_id'] ?? '').toString(),
      vehicleType: json['vehicle_type']?.toString(),
      vehicleCategory: json['vehicle_category']?.toString(),
      brand: json['brand']?.toString(),
      model: json['model']?.toString(),
      fuelType: json['fuel_type']?.toString(),
      manifactureYear: json['manifacture_year']?.toString(),
      regYear: json['reg_year']?.toString(),
      age: int.tryParse(json['age']?.toString() ?? '0'),
      regState: json['reg_state']?.toString(),
      regCity: json['reg_city']?.toString(),
      rtoLocation: json['rto_location']?.toString(),
      vehLocation: json['veh_location'],
      kmDriven: json['km_driven'],
      transmission: json['transmission']?.toString(),
      noOfOwner: json['no_of_owner']?.toString(),
      colour: json['colour']?.toString(),
    );
  }
}

// ─── STEP 3 RESPONSE MODEL ──────────────────────────────────────────────────
class Step3Response {
  final String status;
  final String message;
  final int step;
  final String listingId;
  final dynamic sellingPrice;
  final String? vehicleCondition;
  final String? negotiable;
  final String? accidentHistory;
  final String? serHistory;
  final String? insAvil;
  final String? insExpDate;
  final String? pucAvil;
  final String? pucExpDate;

  Step3Response({
    required this.status,
    required this.message,
    required this.step,
    required this.listingId,
    this.sellingPrice,
    this.vehicleCondition,
    this.negotiable,
    this.accidentHistory,
    this.serHistory,
    this.insAvil,
    this.insExpDate,
    this.pucAvil,
    this.pucExpDate,
  });

  factory Step3Response.fromJson(Map<String, dynamic> json) {
    return Step3Response(
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      step: int.tryParse(json['step']?.toString() ?? '3') ?? 3,
      listingId: (json['listing_id'] ?? '').toString(),
      sellingPrice: json['selling_price'],
      vehicleCondition: json['vehicle_condition']?.toString(),
      negotiable: json['negotiable']?.toString(),
      accidentHistory: json['accident_history']?.toString(),
      serHistory: json['ser_history']?.toString(),
      insAvil: json['ins_avil']?.toString(),
      insExpDate: json['ins_exp_date']?.toString(),
      pucAvil: json['puc_avil']?.toString(),
      pucExpDate: json['puc_exp_date']?.toString(),
    );
  }
}

// ─── STEP 4 RESPONSE MODEL ──────────────────────────────────────────────────
class Step4Response {
  final String status;
  final String message;
  final int step;
  final String listingId;
  final String? uplImg;
  final String? featureList;
  final String? vehicleStatus;
  final String? sellerName;
  final String? contact;
  final String? remarks;

  Step4Response({
    required this.status,
    required this.message,
    required this.step,
    required this.listingId,
    this.uplImg,
    this.featureList,
    this.vehicleStatus,
    this.sellerName,
    this.contact,
    this.remarks,
  });

  factory Step4Response.fromJson(Map<String, dynamic> json) {
    return Step4Response(
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      step: int.tryParse(json['step']?.toString() ?? '4') ?? 4,
      listingId: (json['listing_id'] ?? '').toString(),
      uplImg: json['upl_img']?.toString(),
      featureList: json['feature_list']?.toString(),
      vehicleStatus: json['vehicle_status']?.toString(),
      sellerName: json['seller_name']?.toString(),
      contact: json['contact']?.toString(),
      remarks: json['remarks']?.toString(),
    );
  }
}

// ─── SELLER INSERT STEP PROVIDER ─────────────────────────────────────────────
class SellerInsertStepProvider with ChangeNotifier {
  static const String _baseUrl = 'https://truemotors.in/ai/api/m_api/';

  // ── Loading and error states ──
  bool _isLoadingStep1 = false;
  bool _isLoadingStep2 = false;
  bool _isLoadingStep3 = false;
  bool _isLoadingStep4 = false;

  String? _step1Error;
  String? _step2Error;
  String? _step3Error;
  String? _step4Error;

  // ── Results ──
  String? _currentListingId;
  Step1Response? _step1Result;
  Step2Response? _step2Result;
  Step3Response? _step3Result;
  Step4Response? _step4Result;

  // ── Getters ──
  bool get isLoadingStep1 => _isLoadingStep1;
  bool get isLoadingStep2 => _isLoadingStep2;
  bool get isLoadingStep3 => _isLoadingStep3;
  bool get isLoadingStep4 => _isLoadingStep4;
  bool get isAnyLoading =>
      _isLoadingStep1 || _isLoadingStep2 || _isLoadingStep3 || _isLoadingStep4;

  String? get step1Error => _step1Error;
  String? get step2Error => _step2Error;
  String? get step3Error => _step3Error;
  String? get step4Error => _step4Error;

  String? get currentListingId => _currentListingId;
  Step1Response? get step1Result => _step1Result;
  Step2Response? get step2Result => _step2Result;
  Step3Response? get step3Result => _step3Result;
  Step4Response? get step4Result => _step4Result;

  void setListingId(String? id) {
    _currentListingId = id;
    notifyListeners();
  }

  void reset() {
    _isLoadingStep1 = false;
    _isLoadingStep2 = false;
    _isLoadingStep3 = false;
    _isLoadingStep4 = false;
    _step1Error = null;
    _step2Error = null;
    _step3Error = null;
    _step4Error = null;
    _currentListingId = null;
    _step1Result = null;
    _step2Result = null;
    _step3Result = null;
    _step4Result = null;
    notifyListeners();
  }

  // ── Helper: Extract clean JSON ──
  String _extractJson(String raw) {
    final start = raw.indexOf('{');
    if (start == -1) {
      throw const FormatException('No JSON object found in response');
    }
    return raw.substring(start);
  }

  // ── Helper: Resolve User ID ──
  Future<String> _getUserId(String? overrideUserId) async {
    if (overrideUserId != null && overrideUserId.isNotEmpty) {
      return overrideUserId;
    }
    final stored = await SharedPrefsHelper.getUserId();
    if (stored != null && stored.isNotEmpty && stored != '0') {
      return stored;
    }
    return '25';
  }

  // ── Helper: Common Request Parameters ──
  Future<Map<String, String>> _getCommonParams() async {
    final cid = await SharedPrefsHelper.getCid() ?? '21472147';
    final deviceId = await SharedPrefsHelper.getDeviceId() ?? '123';
    final lt = await SharedPrefsHelper.getLt() ?? '9090';
    final ln = await SharedPrefsHelper.getLn() ?? '9090';

    return {
      'cid': cid.isNotEmpty ? cid : '21472147',
      'device_id': deviceId.isNotEmpty ? deviceId : '123',
      'ln': ln.isNotEmpty ? ln : '9090',
      'lt': lt.isNotEmpty ? lt : '9090',
      'type': '2526',
    };
  }

  // ── Helper: Normalize Date to DD-MM-YYYY ──
  String normalizeDate(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return '';
    // If input is just 4-digit year e.g. 2023
    if (RegExp(r'^\d{4}$').hasMatch(trimmed)) {
      return '01-01-$trimmed';
    }
    // If input is YYYY-MM-DD
    final ymd = RegExp(r'^(\d{4})\s*[-/]\s*(\d{1,2})\s*[-/]\s*(\d{1,2})$').firstMatch(trimmed);
    if (ymd != null) {
      final y = ymd.group(1)!;
      final m = ymd.group(2)!.padLeft(2, '0');
      final d = ymd.group(3)!.padLeft(2, '0');
      return '$d-$m-$y';
    }
    // If input is DD-MM-YYYY or DD/MM/YYYY
    final dmy = RegExp(r'^(\d{1,2})\s*[-/]\s*(\d{1,2})\s*[-/]\s*(\d{4})$').firstMatch(trimmed);
    if (dmy != null) {
      final d = dmy.group(1)!.padLeft(2, '0');
      final m = dmy.group(2)!.padLeft(2, '0');
      final y = dmy.group(3)!;
      return '$d-$m-$y';
    }
    return trimmed;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STEP 1 API: INITIALIZE / DRAFT VEHICLE NUMBER
  // ═══════════════════════════════════════════════════════════════════════════
  Future<Step1Response?> submitStep1({
    required String vehicleNo,
    String? userId,
  }) async {
    _isLoadingStep1 = true;
    _step1Error = null;
    notifyListeners();

    try {
      final common = await _getCommonParams();
      final uid = await _getUserId(userId);

      // Strip spaces e.g. "TN 42 A 4872" -> "TN42A4872"
      final cleanVehNo = vehicleNo.replaceAll(' ', '').toUpperCase();

      final params = {
        ...common,
        'step': '1',
        'user_id': uid,
        'vehicle_no': cleanVehNo,
      };

      debugPrint('┌─────────────────────────────────────────────');
      debugPrint('│ [SellerInsertStepProvider] STEP 1 REQUEST');
      debugPrint('│ URL    : $_baseUrl');
      debugPrint('│ Params : $params');
      debugPrint('└─────────────────────────────────────────────');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: params,
      );

      debugPrint('┌─────────────────────────────────────────────');
      debugPrint('│ [SellerInsertStepProvider] STEP 1 RESPONSE');
      debugPrint('│ Status : ${response.statusCode}');
      debugPrint('│ Body   : ${response.body}');
      debugPrint('└─────────────────────────────────────────────');

      if (response.statusCode != 200) {
        throw Exception('Server returned status ${response.statusCode}');
      }

      final cleanJson = _extractJson(response.body);
      final Map<String, dynamic> json = jsonDecode(cleanJson);

      if (json['status'] == 'success' || json['error'] == false) {
        final result = Step1Response.fromJson(json);
        _step1Result = result;
        if (result.listingId.isNotEmpty) {
          _currentListingId = result.listingId;
        }
        return result;
      } else {
        final msg = json['message'] ?? json['error_msg'] ?? 'Step 1 failed';
        _step1Error = msg.toString();
        return null;
      }
    } catch (e) {
      _step1Error = e.toString();
      debugPrint('[SellerInsertStepProvider] Step 1 Error: $e');
      return null;
    } finally {
      _isLoadingStep1 = false;
      notifyListeners();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STEP 2 API: SAVE VEHICLE FORM DETAILS
  // ═══════════════════════════════════════════════════════════════════════════
  Future<Step2Response?> submitStep2({
    String? listingId,
    String? userId,
    required String vehicleType,
    required String vehicleCategory,
    required String brand,
    required String model,
    required String fuelType,
    String regState = '33',
    String regCity = '1',
    required String rtoLocation,
    required String vehLocation,
    required String kmDriven,
    required String transmission,
    required String noOfOwner,
    required String manifactureYear,
    required String regYear,
    required String colour,
  }) async {
    _isLoadingStep2 = true;
    _step2Error = null;
    notifyListeners();

    try {
      final common = await _getCommonParams();
      final uid = await _getUserId(userId);
      final activeListingId = listingId ?? _currentListingId;

      if (activeListingId == null || activeListingId.isEmpty) {
        throw Exception('listing_id is required for Step 2. Please complete Step 1 first.');
      }

      final params = {
        ...common,
        'step': '2',
        'user_id': uid,
        'listing_id': activeListingId,
        'vehicle_type': vehicleType,
        'vehicle_category': vehicleCategory,
        'brand': brand,
        'model': model,
        'fuel_type': fuelType,
        'reg_state': regState,
        'reg_city': regCity,
        'rto_location': rtoLocation,
        'veh_location': vehLocation,
        'km_driven': kmDriven,
        'transmission': transmission,
        'no_of_owner': noOfOwner,
        'manifacture_year': normalizeDate(manifactureYear),
        'reg_year': normalizeDate(regYear),
        'colour': colour,
      };

      debugPrint('┌─────────────────────────────────────────────');
      debugPrint('│ [SellerInsertStepProvider] STEP 2 REQUEST');
      debugPrint('│ URL    : $_baseUrl');
      debugPrint('│ Params : $params');
      debugPrint('└─────────────────────────────────────────────');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: params,
      );

      debugPrint('┌─────────────────────────────────────────────');
      debugPrint('│ [SellerInsertStepProvider] STEP 2 RESPONSE');
      debugPrint('│ Status : ${response.statusCode}');
      debugPrint('│ Body   : ${response.body}');
      debugPrint('└─────────────────────────────────────────────');

      if (response.statusCode != 200) {
        throw Exception('Server returned status ${response.statusCode}');
      }

      final cleanJson = _extractJson(response.body);
      final Map<String, dynamic> json = jsonDecode(cleanJson);

      if (json['status'] == 'success' || json['error'] == false) {
        final result = Step2Response.fromJson(json);
        _step2Result = result;
        if (result.listingId.isNotEmpty) {
          _currentListingId = result.listingId;
        }
        return result;
      } else {
        final msg = json['message'] ?? json['error_msg'] ?? 'Step 2 failed';
        _step2Error = msg.toString();
        return null;
      }
    } catch (e) {
      _step2Error = e.toString();
      debugPrint('[SellerInsertStepProvider] Step 2 Error: $e');
      return null;
    } finally {
      _isLoadingStep2 = false;
      notifyListeners();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STEP 3 API: SAVE PRICE & CONDITION DETAILS
  // ═══════════════════════════════════════════════════════════════════════════
  Future<Step3Response?> submitStep3({
    String? listingId,
    String? userId,
    required String sellingPrice,
    required String vehicleCondition,
    required String negotiable, // '1' = Yes, '2' = No
    required String accidentHistory, // '1' = Yes, '2' = No
    required String serHistory, // '1' = Yes, '2' = No
    required String insAvil, // '1' = Yes, '2' = No
    String? insExpDate,
    required String pucAvil, // '1' = Yes, '2' = No
    String? pucExpDate,
  }) async {
    _isLoadingStep3 = true;
    _step3Error = null;
    notifyListeners();

    try {
      final common = await _getCommonParams();
      final uid = await _getUserId(userId);
      final activeListingId = listingId ?? _currentListingId;

      if (activeListingId == null || activeListingId.isEmpty) {
        throw Exception('listing_id is required for Step 3. Please complete previous steps first.');
      }

      final cleanInsDate = (insExpDate != null && insExpDate.trim().isNotEmpty)
          ? normalizeDate(insExpDate)
          : '';
      final cleanPucDate = (pucExpDate != null && pucExpDate.trim().isNotEmpty)
          ? normalizeDate(pucExpDate)
          : '';

      // On the backend, availability '2' represents Available/Yes (which saves the expiry date),
      // whereas '1' represents Not Available/No (which clears the expiry date).
      final resolvedInsAvil = (insAvil == '2' || cleanInsDate.isNotEmpty) ? '2' : '1';
      final resolvedPucAvil = (pucAvil == '2' || cleanPucDate.isNotEmpty) ? '2' : '1';

      final params = {
        ...common,
        'step': '3',
        'user_id': uid,
        'listing_id': activeListingId,
        'selling_price': sellingPrice.replaceAll(',', '').trim(),
        'vehicle_condition': vehicleCondition,
        'negotiable': negotiable,
        'accident_history': accidentHistory,
        'ser_history': serHistory,
        'ins_avil': resolvedInsAvil,
        'ins_exp_date': resolvedInsAvil == '2' ? cleanInsDate : '',
        'puc_avil': resolvedPucAvil,
        'puc_exp_date': resolvedPucAvil == '2' ? cleanPucDate : '',
      };

      debugPrint('┌─────────────────────────────────────────────');
      debugPrint('│ [SellerInsertStepProvider] STEP 3 REQUEST');
      debugPrint('│ URL    : $_baseUrl');
      debugPrint('│ Params : $params');
      debugPrint('└─────────────────────────────────────────────');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: params,
      );

      debugPrint('┌─────────────────────────────────────────────');
      debugPrint('│ [SellerInsertStepProvider] STEP 3 RESPONSE');
      debugPrint('│ Status : ${response.statusCode}');
      debugPrint('│ Body   : ${response.body}');
      debugPrint('└─────────────────────────────────────────────');

      if (response.statusCode != 200) {
        throw Exception('Server returned status ${response.statusCode}');
      }

      final cleanJson = _extractJson(response.body);
      final Map<String, dynamic> json = jsonDecode(cleanJson);

      if (json['status'] == 'success' || json['error'] == false) {
        final result = Step3Response.fromJson(json);
        _step3Result = result;
        if (result.listingId.isNotEmpty) {
          _currentListingId = result.listingId;
        }
        return result;
      } else {
        final msg = json['message'] ?? json['error_msg'] ?? 'Step 3 failed';
        _step3Error = msg.toString();
        return null;
      }
    } catch (e) {
      _step3Error = e.toString();
      debugPrint('[SellerInsertStepProvider] Step 3 Error: $e');
      return null;
    } finally {
      _isLoadingStep3 = false;
      notifyListeners();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STEP 4 API: SAVE PHOTOS, FEATURES & SELLER INFORMATION (MULTIPART)
  // ═══════════════════════════════════════════════════════════════════════════
  Future<Step4Response?> submitStep4({
    String? listingId,
    String? userId,
    String status = '1',
    required List<String> features, // e.g. ["1","3","4","5"]
    required String sellerName,
    required String contactNumber,
    String additionalInfo = '',
    required List<File> vehicleImages,
  }) async {
    _isLoadingStep4 = true;
    _step4Error = null;
    notifyListeners();

    try {
      final common = await _getCommonParams();
      final uid = await _getUserId(userId);
      final activeListingId = listingId ?? _currentListingId;

      if (activeListingId == null || activeListingId.isEmpty) {
        throw Exception('listing_id is required for Step 4. Please complete previous steps first.');
      }

      final request = http.MultipartRequest('POST', Uri.parse(_baseUrl));

      // Add fields
      final fields = {
        ...common,
        'step': '4',
        'user_id': uid,
        'listing_id': activeListingId,
        'status': status,
        'features': jsonEncode(features),
        'seller_name': sellerName,
        'contact_number': contactNumber,
        'additional_info': additionalInfo,
      };

      request.fields.addAll(fields);

      // Add vehicle image files under 'vehicle_images[]'
      for (int i = 0; i < vehicleImages.length; i++) {
        final file = vehicleImages[i];
        if (await file.exists()) {
          final fileName = file.path.split('/').last.split('\\').last;
          final ext = fileName.contains('.')
              ? fileName.split('.').last.toLowerCase()
              : 'jpg';
          String subtype = 'jpeg';
          if (ext == 'png') subtype = 'png';
          if (ext == 'webp') subtype = 'webp';

          final multipartFile = await http.MultipartFile.fromPath(
            'vehicle_images[]',
            file.path,
            filename: fileName,
            contentType: MediaType('image', subtype),
          );
          request.files.add(multipartFile);
        }
      }

      debugPrint('┌─────────────────────────────────────────────');
      debugPrint('│ [SellerInsertStepProvider] STEP 4 MULTIPART REQUEST');
      debugPrint('│ URL    : $_baseUrl');
      debugPrint('│ Fields : ${request.fields}');
      debugPrint('│ Files  : ${request.files.length} images attached');
      debugPrint('└─────────────────────────────────────────────');

      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();

      debugPrint('┌─────────────────────────────────────────────');
      debugPrint('│ [SellerInsertStepProvider] STEP 4 RESPONSE');
      debugPrint('│ Status : ${streamedResponse.statusCode}');
      debugPrint('│ Body   : $responseBody');
      debugPrint('└─────────────────────────────────────────────');

      if (streamedResponse.statusCode != 200) {
        throw Exception('Server returned status ${streamedResponse.statusCode}');
      }

      final cleanJson = _extractJson(responseBody);
      final Map<String, dynamic> json = jsonDecode(cleanJson);

      if (json['status'] == 'success' || json['error'] == false) {
        final result = Step4Response.fromJson(json);
        _step4Result = result;
        return result;
      } else {
        final msg = json['message'] ?? json['error_msg'] ?? 'Step 4 failed';
        _step4Error = msg.toString();
        return null;
      }
    } catch (e) {
      _step4Error = e.toString();
      debugPrint('[SellerInsertStepProvider] Step 4 Error: $e');
      return null;
    } finally {
      _isLoadingStep4 = false;
      notifyListeners();
    }
  }
}
