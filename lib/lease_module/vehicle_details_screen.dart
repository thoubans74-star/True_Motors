import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:true_motors/lease_module/upload_vehicle_images_screen.dart';

class VehicleDetailsScreen extends StatefulWidget {
  final String vehicleType;

  const VehicleDetailsScreen({super.key, required this.vehicleType});

  @override
  State<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> {
  // ── Selected values ────────────────────────────────────────────────────────
  String? _selectedBrand;
  String? _selectedModel;
  String? _selectedFuelType;
  String? _selectedTransmission;
  String? _selectedYear;

  // ── Which dropdown is currently open ──────────────────────────────────────
  String? _openDropdown;

  // ── Text controllers ───────────────────────────────────────────────────────
  final TextEditingController _kmController = TextEditingController();
  final TextEditingController _insuranceController = TextEditingController();

  // ── Text field errors ──────────────────────────────────────────────────────
  String? _kmError;
  String? _insuranceError;

  // ── Field limits ───────────────────────────────────────────────────────────
  static const int _maxKmDigits = 7;

  // ── Lists ──────────────────────────────────────────────────────────────────
  final List<String> _brands = [
    'Maruti Suzuki',
    'Hyundai',
    'Tata',
    'Mahindra',
    'Honda',
    'Toyota',
    'Ford',
    'Kia',
  ];

  final Map<String, List<String>> _modelsByBrand = {
    'Maruti Suzuki': ['Baleno', 'Brezza', 'Swift', 'Alto', 'Ciaz'],
    'Hyundai': ['Creta', 'Venue', 'i20', 'Tucson', 'Alcazar'],
    'Tata': ['Nexon', 'Harrier', 'Safari', 'Punch', 'Altroz'],
    'Mahindra': ['Scorpio', 'XUV700', 'Thar', 'Bolero', 'XUV300'],
    'Honda': ['City', 'Amaze', 'Jazz', 'WR-V', 'CR-V'],
    'Toyota': ['Innova', 'Fortuner', 'Glanza', 'Urban Cruiser', 'Camry'],
    'Ford': ['EcoSport', 'Endeavour', 'Freestyle', 'Aspire', 'Figo'],
    'Kia': ['Seltos', 'Sonet', 'Carnival', 'Carens', 'EV6'],
  };

  final List<String> _fuelTypes = ['Petrol', 'Diesel', 'CNG', 'Electric'];
  final List<String> _transmissions = ['Manual', 'Automatic'];
  final List<String> _years = List.generate(
    20,
        (i) => (DateTime.now().year - i).toString(),
  );

  @override
  void dispose() {
    _kmController.dispose();
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
    if (_selectedYear == null) missing.add('Registration Year');
    return missing;
  }

  void _onSaveAndNext() {
    FocusScope.of(context).unfocus();
    setState(() => _openDropdown = null);

    final missing = _missingDropdowns();
    final bool textFieldsValid = _validateTextFields();

    if (missing.isNotEmpty || !textFieldsValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill all fields',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: Color(0xFF323232),
          behavior: SnackBarBehavior.fixed,
          duration: Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UploadVehicleImagesScreen(
          vehicleType: widget.vehicleType,
          brand: _selectedBrand!,
          model: _selectedModel!,
          fuelType: _selectedFuelType!,
          transmission: _selectedTransmission!,
          year: _selectedYear!,
          kmDriven: _kmController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        setState(() => _openDropdown = null);
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: const Color(0xFFF2F2F2),
          resizeToAvoidBottomInset: true,
          body: Column(
            children: [
              Container(
                width: double.infinity,
                height: statusBarHeight, color: Colors.transparent,
              ),
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vehicle Details',
                        style: TextStyle(
                          color: const Color(0xFF01422D),
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        'Enter your vehicle basic details',
                        style: TextStyle(fontSize: 13.5.sp, color: Colors.black),
                      ),
                      SizedBox(height: 16.h),

                      // ── Select Brand ───────────────────────────────────────
                      _buildInlineDropdown(
                        key: 'brand',
                        label: 'Select Brand',
                        value: _selectedBrand,
                        items: _brands,
                        onSelected: (v) => setState(() {
                          _selectedBrand = v;
                          _selectedModel = null;
                          _openDropdown = null;
                        }),
                      ),

                      // ── Select Model ───────────────────────────────────────
                      _buildInlineDropdown(
                        key: 'model',
                        label: 'Select Model',
                        value: _selectedModel,
                        items: _selectedBrand != null
                            ? (_modelsByBrand[_selectedBrand] ?? [])
                            : [],
                        onSelected: (v) => setState(() {
                          _selectedModel = v;
                          _openDropdown = null;
                        }),
                      ),

                      // ── Fuel Type ──────────────────────────────────────────
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

                      // ── Transmission ───────────────────────────────────────
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

                      // ── Registration Year ──────────────────────────────────
                      _buildInlineDropdown(
                        key: 'year',
                        label: 'Registration Year',
                        value: _selectedYear,
                        items: _years,
                        onSelected: (v) => setState(() {
                          _selectedYear = v;
                          _openDropdown = null;
                        }),
                      ),

                      // ── Kilometers Driven ──────────────────────────────────
                      _buildFloatingTextField(
                        label: 'Kilometer Driven',
                        controller: _kmController,
                        error: _kmError,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(_maxKmDigits),
                        ],
                        onChanged: (_) => setState(() => _kmError = null),
                      ),

                      // ── Insurance Validity Date ────────────────────────────
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
                            initialDate: DateTime.now()
                                .add(const Duration(days: 365)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now()
                                .add(const Duration(days: 3650)),
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

                      SizedBox(height: 30.h),

                      // ── Previous & Save and Next buttons ──────────────────
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                side: const BorderSide(
                                    color: Color(0xFF005F65), width: 1),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.r)),
                              ),
                              child: Text(
                                'Previous',
                                style: TextStyle(
                                  color: const Color(0xFF005F65),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.sp,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 14.w),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _onSaveAndNext,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF005F65),
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r)),
                                elevation: 0,
                              ),
                              child: Text(
                                'Save & Next',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.sp,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 30.h),
                    ],
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
  Widget _buildAppBar(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back,
              size: 24.r,
              color: const Color(0xFF01422D),
            ),
          ),
          SizedBox(width: 16.w),
          Text(
            'Add New Vehicle',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF01422D),
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  // ── Inline dropdown ────────────────────────────────────────────────────────
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

          GestureDetector(
            onTap: () {
              if (items.isEmpty) return;
              FocusScope.of(context).unfocus();
              _toggleDropdown(key);
            },
            child: Container(
              height: 46.h,
              padding: EdgeInsets.symmetric(horizontal: 14.w),
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
                        color: items.isEmpty
                            ? const Color(0xFFB4B4B4)
                            : Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    color: const Color(0xFF742B88),
                    size: 24.r,
                  ),
                ],
              ),
            ),
          ),

          if (isOpen && items.isNotEmpty)
            Column(
              children: List.generate(items.length, (index) {
                final item = items[index];
                return GestureDetector(
                  onTap: () => onSelected(item),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F4F4),
                      border: Border.all(color: const Color(0xFFE2E2E2)),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
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
              errorStyle: TextStyle(fontSize: 11.sp),
              suffixIcon: suffixIcon,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
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
                borderSide: const BorderSide(color: Color(0xFF005F65)),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: Color(0xFFB00020)),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: Color(0xFFB00020)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}