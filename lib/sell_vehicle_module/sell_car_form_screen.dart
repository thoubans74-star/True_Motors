import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:true_motors/menu_module/listing_manager.dart';
import 'sell_car_photo_screen.dart';

class SellCarFormScreen extends StatefulWidget {
  final String registrationNumber;
  final String vehicleType;
  final int? vehicleCategoryId;
  // When set, we are editing an existing listing instead of creating new
  final String? editingListingId;

  const SellCarFormScreen({
    super.key,
    required this.registrationNumber,
    required this.vehicleType,
    this.vehicleCategoryId,
    this.editingListingId,
  });

  @override
  State<SellCarFormScreen> createState() => _SellCarFormScreenState();
}

class _SellCarFormScreenState extends State<SellCarFormScreen> {
  // ── Selected values ────────────────────────────────────────────────────────
  String? _selectedBrand;
  String? _selectedModel;
  String? _selectedFuelType;
  String? _selectedTransmission;
  String? _selectedRegYear;
  String? _selectedLocation;
  String? _selectedRTO;
  final List<String> _selectedFeatures = [];

  // ── Which dropdown is currently open ──────────────────────────────────────
  String? _openDropdown;

  // ── Text controllers ───────────────────────────────────────────────────────
  final TextEditingController _kmController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _insuranceController = TextEditingController();

  // ── Text field errors ──────────────────────────────────────────────────────
  String? _kmError;
  String? _priceError;
  String? _insuranceError;

  // ── Lists ──────────────────────────────────────────────────────────────────
  final List<String> _brands = [
    'Maruti Suzuki',
    'Tata',
    'Kia',
    'Honda',
    'Hyundai',
  ];
  final List<String> _models = [
    'Baleno',
    'Brezza',
    'Ciaz',
    'Swift',
    'Alto',
  ];
  final List<String> _fuelTypes = [
    'Petrol',
    'Diesel',
    'Electric',
    'CNG',
    'LPG'
  ];
  final List<String> _transmissions = ['Manual', 'Automatic', 'AMT', 'DCT'];
  final List<String> _years =
  List.generate(20, (i) => (2024 - i).toString());
  final List<String> _locations = [
    'Coimbatore',
    'Chennai',
    'Bangalore',
    'Hyderabad',
    'Mumbai',
  ];
  final List<String> _rtos = [
    'TN 57',
    'TN 01',
    'TN 33',
    'TN 11',
    'TN 58',
  ];
  final List<String> _features = [
    'Air Conditioning',
    'Power Steering',
    'Airbags',
    'Bluetooth',
  ];

  // ── Field limits ───────────────────────────────────────────────────────────
  static const int _maxKmDigits = 7;
  static const int _maxPriceDigits = 8;

  @override
  void initState() {
    super.initState();
    // Pre-fill form if editing an existing listing
    if (widget.editingListingId != null) {
      final existing = ListingManager()
          .allListings
          .where((l) => l.id == widget.editingListingId)
          .firstOrNull;
      if (existing != null) {
        _selectedBrand = existing.brand;
        _selectedModel = existing.model;
        _selectedFuelType = existing.fuelType;
        _selectedTransmission = existing.transmission;
        _selectedRegYear = existing.regYear;
        _selectedLocation = existing.location;
        _selectedRTO = existing.rto;
        _selectedFeatures.addAll(existing.features);
        _kmController.text = existing.kmDriven;
        _priceController.text = existing.price;
        _insuranceController.text = existing.insuranceDate;
      }
    }
  }

  @override
  void dispose() {
    _kmController.dispose();
    _priceController.dispose();
    _insuranceController.dispose();
    super.dispose();
  }

  void _toggleDropdown(String key) {
    setState(() => _openDropdown = _openDropdown == key ? null : key);
  }

  bool _validateTextFields() {
    bool valid = true;
    setState(() {
      final km = _kmController.text.trim();
      if (km.isEmpty) {
        _kmError = 'Please enter kilometers driven';
        valid = false;
      } else {
        final val = int.tryParse(km);
        if (val == null || val <= 0) {
          _kmError = 'Enter a valid number greater than 0';
          valid = false;
        } else {
          _kmError = null;
        }
      }

      final price = _priceController.text.trim();
      if (price.isEmpty) {
        _priceError = 'Please enter a price';
        valid = false;
      } else {
        final val = int.tryParse(price);
        if (val == null || val <= 0) {
          _priceError = 'Enter a valid price greater than 0';
          valid = false;
        } else {
          _priceError = null;
        }
      }

      if (_insuranceController.text.trim().isEmpty) {
        _insuranceError = 'Please select insurance validity date';
        valid = false;
      } else {
        _insuranceError = null;
      }
    });
    return valid;
  }

  List<String> _missingDropdowns() {
    final missing = <String>[];
    if (_selectedBrand == null) missing.add('Brand');
    if (_selectedModel == null) missing.add('Model');
    if (_selectedFuelType == null) missing.add('Fuel Type');
    if (_selectedTransmission == null) missing.add('Transmission');
    if (_selectedRegYear == null) missing.add('Registration Year');
    if (_selectedLocation == null) missing.add('Location');
    if (_selectedRTO == null) missing.add('RTO');
    return missing;
  }

  void _onSaveAndNext() {
    FocusScope.of(context).unfocus();
    setState(() => _openDropdown = null);

    final missing = _missingDropdowns();
    final bool textFieldsValid = _validateTextFields();

    if (missing.isNotEmpty || !textFieldsValid || _selectedFeatures.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please fill all fields',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: const Color(0xFF323232),
          behavior: SnackBarBehavior.fixed,
          duration: const Duration(seconds: 2),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
      );
      return;
    }

    if (widget.editingListingId != null) {
      // Editing mode — update the listing directly and pop back to My Listing
      final existing = ListingManager()
          .allListings
          .where((l) => l.id == widget.editingListingId)
          .firstOrNull;
      if (existing != null) {
        final updated = existing.copyWith(
          brand: _selectedBrand,
          model: _selectedModel,
          fuelType: _selectedFuelType,
          transmission: _selectedTransmission,
          regYear: _selectedRegYear,
          kmDriven: _kmController.text.trim(),
          location: _selectedLocation,
          rto: _selectedRTO,
          price: _priceController.text.trim(),
          insuranceDate: _insuranceController.text.trim(),
          features: List<String>.from(_selectedFeatures),
        );
        ListingManager().updateListing(widget.editingListingId!, updated);
      }
      // Pop back to My Listing
      Navigator.pop(context);
    } else {
      // New listing — continue to photo screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SellCarPhotoScreen(
            registrationNumber: widget.registrationNumber,
            vehicleType: widget.vehicleType,
            brand: _selectedBrand!,
            model: _selectedModel!,
            fuelType: _selectedFuelType!,
            transmission: _selectedTransmission!,
            regYear: _selectedRegYear!,
            kmDriven: _kmController.text.trim(),
            location: _selectedLocation!,
            rto: _selectedRTO!,
            price: _priceController.text.trim(),
            insuranceDate: _insuranceController.text.trim(),
            features: _selectedFeatures,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          setState(() => _openDropdown = null);
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF3F3F3),
          resizeToAvoidBottomInset: true,
          body: Column(
            children: [
              Container(
                width: double.infinity,
                height: statusBarHeight,
                color: Colors.white,
              ),
              _buildAppBar(),
              Expanded(
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPromoBanner(),
                        SizedBox(height: 14.h),

                        Text(
                          widget.editingListingId != null
                              ? 'Edit Vehicle - ${widget.registrationNumber}'
                              : 'Sell Vehicle - ${widget.registrationNumber}',
                          style: TextStyle(
                              fontSize: 15.sp, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Add Or Edit Vehicle',
                          style:
                          TextStyle(fontSize: 13.5.sp, color: Colors.black54),
                        ),
                        SizedBox(height: 16.h),

                        // ── Dropdowns ─────────────────────────────────────────
                        _buildInlineDropdown(
                          key: 'brand',
                          label: 'Select Brand',
                          value: _selectedBrand,
                          items: _brands,
                          onSelected: (v) => setState(() {
                            _selectedBrand = v;
                            _openDropdown = null;
                          }),
                        ),
                        _buildInlineDropdown(
                          key: 'model',
                          label: 'Select Model',
                          value: _selectedModel,
                          items: _models,
                          onSelected: (v) => setState(() {
                            _selectedModel = v;
                            _openDropdown = null;
                          }),
                        ),
                        _buildInlineDropdown(
                          key: 'fuel',
                          label: 'Fuel Type',
                          value: _selectedFuelType,
                          items: _fuelTypes,
                          onSelected: (v) => setState(() {
                            _selectedFuelType = v;
                            _openDropdown = null;
                          }),
                        ),
                        _buildInlineDropdown(
                          key: 'transmission',
                          label: 'Transmission',
                          value: _selectedTransmission,
                          items: _transmissions,
                          onSelected: (v) => setState(() {
                            _selectedTransmission = v;
                            _openDropdown = null;
                          }),
                        ),
                        _buildInlineDropdown(
                          key: 'year',
                          label: 'Registration Year',
                          value: _selectedRegYear,
                          items: _years,
                          onSelected: (v) => setState(() {
                            _selectedRegYear = v;
                            _openDropdown = null;
                          }),
                        ),

                        // ── Kilometers Driven ─────────────────────────────────
                        _buildFloatingTextField(
                          label: 'Kilometers Driven',
                          controller: _kmController,
                          error: _kmError,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(_maxKmDigits),
                          ],
                          onChanged: (_) => setState(() => _kmError = null),
                        ),

                        _buildInlineDropdown(
                          key: 'location',
                          label: 'Select Location',
                          value: _selectedLocation,
                          items: _locations,
                          onSelected: (v) => setState(() {
                            _selectedLocation = v;
                            _openDropdown = null;
                          }),
                        ),
                        _buildInlineDropdown(
                          key: 'rto',
                          label: 'Select RTO',
                          value: _selectedRTO,
                          items: _rtos,
                          onSelected: (v) => setState(() {
                            _selectedRTO = v;
                            _openDropdown = null;
                          }),
                        ),

                        // ── Price ─────────────────────────────────────────────
                        _buildFloatingTextField(
                          label: 'Price',
                          controller: _priceController,
                          error: _priceError,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(_maxPriceDigits),
                          ],
                          onChanged: (_) => setState(() => _priceError = null),
                        ),

                        // ── Insurance Validity Date ───────────────────────────
                        _buildFloatingTextField(
                          label: 'Insurance Validity Date',
                          controller: _insuranceController,
                          error: _insuranceError,
                          readOnly: true,
                          suffixIcon: Icon(Icons.calendar_month_outlined,
                              color: const Color(0xFF742B88), size: 20.r),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate:
                              DateTime.now().add(const Duration(days: 30)),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2035),
                              builder: (ctx, child) => Theme(
                                data: Theme.of(ctx).copyWith(
                                  colorScheme: const ColorScheme.light(
                                      primary: Color(0xFF005F65)),
                                ),
                                child: child!,
                              ),
                            );
                            if (picked != null) {
                              _insuranceController.text =
                              '${picked.day}/${picked.month}/${picked.year}';
                              setState(() => _insuranceError = null);
                            }
                          },
                        ),

                        // ── Feature Checklist (multi-select) ──────────────────
                        _buildMultiSelectDropdown(),

                        SizedBox(height: 24.h),

                        Center(
                          child: SizedBox(
                            width: 230.w,
                            height: 48.h,
                            child: ElevatedButton(
                              onPressed: _onSaveAndNext,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF005F65),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r)),
                                elevation: 0,
                              ),
                              child: Text(
                                widget.editingListingId != null
                                    ? 'Save Changes'
                                    : 'Save & Next',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15.sp),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── App bar ────────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back,
                size: 24.r, color: const Color(0xFF01422D)),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            widget.editingListingId != null ? 'Edit Listing' : 'Sell car',
            style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF01422D),
                fontFamily: 'Poppins'),
          ),
        ],
      ),
    );
  }

  // ── Promo banner ───────────────────────────────────────────────────────────
  Widget _buildPromoBanner() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFF00274B),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/sell_image/red_car.png',
            width: 125.w,
            height: 110.h,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Sell Your Car Instantly',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Calistoga',
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15.5.sp,
                    ),
                  ),
                ),
                SizedBox(height: 1.h),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Best price,Free inspection.\nInstant payment',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Calistoga',
                      color: Colors.white,
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Get Free Quote',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Calistoga',
                        color: const Color(0xFF000000),
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineDropdown({
    required String key,
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String> onSelected,
  }) {
    final isOpen = _openDropdown == key;
    final hasValue = value != null;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Floating label above — only when value is selected
          if (hasValue)
            Padding(
              padding: EdgeInsets.only(left: 8.w, bottom: 4.h),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: const Color(0xFF005F65),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          // Header — shows placeholder when nothing selected, selected value otherwise
          GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              _toggleDropdown(key);
            },
            child: Container(
              height: 46.h,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: isOpen
                      ? const Color(0xFF005F65)
                      : const Color(0xFFE2E2E2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      hasValue ? value : label,
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    size: 24.r,
                    color: const Color(0xFF742B88),
                  ),
                ],
              ),
            ),
          ),

          // Items — flush below header
          if (isOpen)
            Column(
              children: List.generate(items.length, (index) {
                final item = items[index];

                return GestureDetector(
                  onTap: () => onSelected(item),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                        color: const Color(0xFFF4F4F4),
                        border: Border.all(color: const Color(0xFFE2E2E2)),
                        borderRadius: BorderRadius.circular(8.r)),
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }

  Widget _buildMultiSelectDropdown() {
    const key = 'feature';
    final isOpen = _openDropdown == key;
    final hasValue = _selectedFeatures.isNotEmpty;

    final displayText =
    hasValue ? _selectedFeatures.join(', ') : 'Feature Checklist';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Floating label above — only when features are selected
          if (hasValue)
            Padding(
              padding: EdgeInsets.only(left: 8.w, bottom: 4.h),
              child: Text(
                'Feature Checklist',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: const Color(0xFF005F65),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          // Header
          GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              _toggleDropdown(key);
            },
            child: Container(
              height: 46.h,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: isOpen
                      ? const Color(0xFF005F65)
                      : const Color(0xFFE2E2E2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      displayText,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    size: 24.r,
                    color: const Color(0xFF742B88),
                  ),
                ],
              ),
            ),
          ),

          // Items with checkbox on right
          if (isOpen)
            Column(
              children: List.generate(_features.length, (index) {
                final item = _features[index];
                final isSelected = _selectedFeatures.contains(item);

                return GestureDetector(
                  onTap: () => setState(() {
                    if (isSelected) {
                      _selectedFeatures.remove(item);
                    } else {
                      _selectedFeatures.add(item);
                    }
                  }),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                        color: const Color(0xFFF4F4F4),
                        border: Border.all(color: const Color(0xFFE2E2E2)),
                        borderRadius: BorderRadius.circular(8.r)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item,
                            style: TextStyle(
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Checkbox(
                          value: isSelected,
                          activeColor: const Color(0xFF005F65),
                          side: const BorderSide(color: Colors.black),
                          checkColor: Colors.white,
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                          onChanged: (val) => setState(() {
                            if (val == true) {
                              _selectedFeatures.add(item);
                            } else {
                              _selectedFeatures.remove(item);
                            }
                          }),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }

  // ── Floating label text field ──────────────────────────────────────────────
  Widget _buildFloatingTextField({
    required String label,
    required TextEditingController controller,
    String? error,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    bool readOnly = false,
    Widget? suffixIcon,
    ValueChanged<String>? onChanged,
    VoidCallback? onTap,
  }) {
    final bool hasText = controller.text.isNotEmpty;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasText)
            Padding(
              padding: EdgeInsets.only(left: 8.w, bottom: 4.h),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: error != null
                      ? const Color(0xFFB00020)
                      : const Color(0xFF005F65),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            readOnly: readOnly,
            onChanged: (v) {
              onChanged?.call(v);
              setState(() {});
            },
            onTap: onTap,
            enableInteractiveSelection: !readOnly,
            style: TextStyle(
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: hasText ? '' : label,
              hintStyle: TextStyle(
                fontSize: 13.5.sp,
                color: const Color(0xFFB4B4B4),
              ),
              errorText: error,
              errorStyle: TextStyle(fontSize: 11.5.sp),
              suffixIcon: suffixIcon,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 12.h,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(
                  color: error != null
                      ? const Color(0xFFB00020)
                      : const Color(0xFFE2E2E2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide:
                const BorderSide(color: Color(0xFF005F65)),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: Color(0xFFB00020)),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide:
                const BorderSide(color: Color(0xFFB00020)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}