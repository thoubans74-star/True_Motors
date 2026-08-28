import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart';
import 'package:true_motors/lease_module/lease_details_screen.dart';

class LocationDocumentsScreen extends StatefulWidget {
  final String vehicleType;
  final String brand;
  final String model;
  final String fuelType;
  final String transmission;
  final String year;
  final String kmDriven;
  final List<String> imagePaths;
  final String additionalInfo;

  const LocationDocumentsScreen({
    super.key,
    required this.vehicleType,
    required this.brand,
    required this.model,
    required this.fuelType,
    required this.transmission,
    required this.year,
    required this.kmDriven,
    required this.imagePaths,
    required this.additionalInfo,
  });

  @override
  State<LocationDocumentsScreen> createState() =>
      _LocationDocumentsScreenState();
}

class _LocationDocumentsScreenState extends State<LocationDocumentsScreen> {
  // ── Selected values ─────────────────────────────────────────────────────
  String? _selectedState;
  String? _selectedCity;
  final TextEditingController _areaController = TextEditingController();

  // ── Which dropdown is currently open ──────────────────────────────────────
  String? _openDropdown;

  // ── Documents (RC, Insurance, Pollution) ───────────────────────────────────
  final List<File?> _documents = [null, null, null];
  final List<String?> _docErrors = [null, null, null];

  final List<String> _docTitles = const [
    'Registration Certificate (RC)',
    'Insurance Certificate',
    'Pollution certificate',
  ];

  final List<String> _docButtonTitles = const [
    'Upload RC Photo',
    'Upload Insurance Certificate',
    'Upload Pollution Certificate',
  ];

  String? _areaError;

  // ── Lists ──────────────────────────────────────────────────────────────────
  final List<String> _states = const [
    'Tamil Nadu',
    'Karnataka',
    'Kerala',
    'Andhra Pradesh',
    'Telangana',
    'Maharashtra',
    'Gujarat',
    'Rajasthan',
    'Delhi',
    'Uttar Pradesh',
    'West Bengal',
    'Punjab',
  ];

  final Map<String, List<String>> _citiesByState = const {
    'Tamil Nadu': ['Coimbatore', 'Chennai', 'Madurai', 'Trichy', 'Salem'],
    'Karnataka': ['Bengaluru', 'Mysuru', 'Mangaluru', 'Hubballi'],
    'Kerala': ['Kochi', 'Thiruvananthapuram', 'Kozhikode'],
    'Andhra Pradesh': ['Visakhapatnam', 'Vijayawada', 'Guntur'],
    'Telangana': ['Hyderabad', 'Warangal'],
    'Maharashtra': ['Mumbai', 'Pune', 'Nagpur'],
    'Gujarat': ['Ahmedabad', 'Surat', 'Vadodara'],
    'Rajasthan': ['Jaipur', 'Udaipur', 'Jodhpur'],
    'Delhi': ['New Delhi'],
    'Uttar Pradesh': ['Lucknow', 'Noida', 'Kanpur'],
    'West Bengal': ['Kolkata', 'Howrah'],
    'Punjab': ['Ludhiana', 'Amritsar', 'Chandigarh'],
  };

  @override
  void dispose() {
    _areaController.dispose();
    super.dispose();
  }

  void _toggleDropdown(String key) {
    setState(() => _openDropdown = _openDropdown == key ? null : key);
  }

  Future<void> _pickDocument(int index) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          _documents[index] = File(result.files.single.path!);
          _docErrors[index] = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open file picker')),
      );
    }
  }

  void _removeDocument(int index) {
    setState(() => _documents[index] = null);
  }

  bool _validate() {
    bool valid = true;
    setState(() {
      if (_selectedState == null) valid = false;
      if (_selectedCity == null) valid = false;

      if (_areaController.text.trim().isEmpty) {
        _areaError = 'Please enter area / locality';
        valid = false;
      } else {
        _areaError = null;
      }

      for (int i = 0; i < _documents.length; i++) {
        if (_documents[i] == null) {
          _docErrors[i] = 'Please upload ${_docTitles[i]}';
          valid = false;
        } else {
          _docErrors[i] = null;
        }
      }
    });
    return valid;
  }

  void _onSaveAndNext() {
    FocusScope.of(context).unfocus();
    setState(() => _openDropdown = null);

    if (!_validate()) {
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LeaseDetailsScreen(
          vehicleType: widget.vehicleType,
          brand: widget.brand,
          model: widget.model,
          fuelType: widget.fuelType,
          transmission: widget.transmission,
          year: widget.year,
          kmDriven: widget.kmDriven,
          imagePaths: widget.imagePaths,
          additionalInfo: widget.additionalInfo,
          state: _selectedState!,
          city: _selectedCity!,
          area: _areaController.text.trim(),
          rcPath: _documents[0]!.path,
          insurancePath: _documents[1]!.path,
          pollutionPath: _documents[2]!.path,
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
                        'Location',
                        style: TextStyle(
                          color: const Color(0xFF01422D),
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // ── State ────────────────────────────────────────────
                      _buildLabeledDropdown(
                        keyId: 'state',
                        label: 'State',
                        placeholder: 'Select State',
                        value: _selectedState,
                        items: _states,
                        onSelected: (v) => setState(() {
                          _selectedState = v;
                          _selectedCity = null;
                          _openDropdown = null;
                        }),
                      ),

                      // ── City ─────────────────────────────────────────────
                      _buildLabeledDropdown(
                        keyId: 'city',
                        label: 'City',
                        placeholder: 'Select City',
                        value: _selectedCity,
                        items: _selectedState != null
                            ? (_citiesByState[_selectedState] ?? [])
                            : [],
                        onSelected: (v) => setState(() {
                          _selectedCity = v;
                          _openDropdown = null;
                        }),
                      ),

                      // ── Area ─────────────────────────────────────────────
                      _buildLabeledTextField(
                        label: 'Area',
                        controller: _areaController,
                        placeholder: 'Enter area / Locality',
                        error: _areaError,
                        onChanged: (_) => setState(() => _areaError = null),
                      ),

                      SizedBox(height: 12.h),
                      Text(
                        'Documents',
                        style: TextStyle(
                          color: const Color(0xFF01422D),
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        'Upload Required Documents',
                        style: TextStyle(fontSize: 13.5.sp, color: Colors.black),
                      ),
                      SizedBox(height: 12.h),

                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.10),
                              offset: const Offset(0, 8),
                              blurRadius: 24,
                            ),
                          ],
                        ),
                        child: Column(
                          children: List.generate(
                            _documents.length,
                                (i) => Padding(
                              padding: EdgeInsets.only(
                                bottom: i == _documents.length - 1 ? 0 : 20.h,
                              ),
                              child: _buildDocumentSlot(index: i),
                            ),
                          ),
                        ),
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

  // ── Labeled dropdown ────────────────────────────────────────────────────────
  Widget _buildLabeledDropdown({
    required String keyId,
    required String label,
    required String placeholder,
    required String? value,
    required List<String> items,
    required ValueChanged<String> onSelected,
  }) {
    final isOpen = _openDropdown == keyId;
    final hasValue = value != null;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.5.sp,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 6.h),
          GestureDetector(
            onTap: () {
              if (items.isEmpty) return;
              FocusScope.of(context).unfocus();
              _toggleDropdown(keyId);
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
                      hasValue ? value : placeholder,
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        color:
                        hasValue ? Colors.black : const Color(0xFFB4B4B4),
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
            Container(
              margin: EdgeInsets.only(top: 6.h),
              constraints: BoxConstraints(maxHeight: 220.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F4F4),
                border: Border.all(color: const Color(0xFFE2E2E2)),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                children: List.generate(items.length, (index) {
                  final item = items[index];
                  return InkWell(
                    onTap: () => onSelected(item),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 12.h,
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
            ),
        ],
      ),
    );
  }

  // ── Labeled text field ──────────────────────────────────────────────────────
  Widget _buildLabeledTextField({
    required String label,
    required TextEditingController controller,
    required String placeholder,
    String? error,
    bool readOnly = false,
    Widget? suffixIcon,
    String? prefixText,
    String? suffixText,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.5.sp,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 6.h),
          TextFormField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            onChanged: onChanged,
            onTap: onTap,
            style: TextStyle(
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: placeholder,
              hintStyle: TextStyle(
                fontSize: 13.5.sp,
                color: const Color(0xFFB4B4B4),
              ),
              prefixText: prefixText,
              suffixText: suffixText,
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

  // ── Document upload slot ────────────────────────────────────────────────
  Widget _buildDocumentSlot({required int index}) {
    final file = _documents[index];
    final error = _docErrors[index];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _docTitles[index],
          style: TextStyle(
            fontSize: 13.5.sp,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        file == null
            ? CustomPaint(
          painter: _DashedBorderPainter(
            color: const Color(0xFF000000),
            borderRadius: 12,
            dashWidth: 2,
            dashSpace: 2,
            strokeWidth: 2,
          ),
          child: GestureDetector(
            onTap: () => _pickDocument(index),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                children: [
                  Image.asset('assets/buy_car/camera.png',
                    width: 32.r,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    _docButtonTitles[index],
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'File Format JPG/PNG/PDF',
                    style: TextStyle(
                        fontSize: 11.5.sp, color: const Color(0xFF938F8F)),
                  ),
                ],
              ),
            ),
          ),
        )
            : Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
              vertical: 12.h, horizontal: 12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFF005F65)),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle,
                  color: const Color(0xFF005F65), size: 20.r),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  file.path.split('/').last,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 12.5.sp, fontWeight: FontWeight.w500),
                ),
              ),
              GestureDetector(
                onTap: () => _pickDocument(index),
                child: Text(
                  'Change',
                  style: TextStyle(
                    color: const Color(0xFF742B88),
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              GestureDetector(
                onTap: () => _removeDocument(index),
                child: Icon(Icons.close,
                    color: Colors.redAccent, size: 18.r),
              ),
            ],
          ),
        ),
        if (error != null)
          Padding(
            padding: EdgeInsets.only(top: 6.h),
            child: Text(
              error,
              style: TextStyle(color: const Color(0xFFB00020), fontSize: 11.5.sp),
            ),
          ),
      ],
    );
  }
}

// ── Custom painter for dashed border ─────────────────────────────────────────
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double borderRadius;
  final double dashWidth;
  final double dashSpace;
  final double strokeWidth;

  _DashedBorderPainter({
    required this.color,
    required this.borderRadius,
    required this.dashWidth,
    required this.dashSpace,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    final path = Path()..addRRect(rrect);
    final dashPath = _createDashedPath(path);
    canvas.drawPath(dashPath, paint);
  }

  Path _createDashedPath(Path source) {
    final Path dest = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0;
      bool draw = true;
      while (distance < metric.length) {
        final len = draw ? dashWidth : dashSpace;
        if (draw) {
          dest.addPath(
            metric.extractPath(distance, distance + len),
            Offset.zero,
          );
        }
        distance += len;
        draw = !draw;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color ||
          old.dashWidth != dashWidth ||
          old.dashSpace != dashSpace;
}