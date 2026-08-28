import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:true_motors/lease_module/preview_submit_screen.dart';

class FeaturesDescriptionScreen extends StatefulWidget {
  final String vehicleType;
  final String brand;
  final String model;
  final String fuelType;
  final String transmission;
  final String year;
  final String kmDriven;
  final List<String> imagePaths;
  final String additionalInfo;
  final String state;
  final String city;
  final String area;
  final String rcPath;
  final String insurancePath;
  final String pollutionPath;
  final String leaseType;
  final String leaseDuration;
  final String noticePeriod;
  final String availableFrom;
  final String monthlyPrice;
  final String includedKm;
  final String extraKmCharge;

  const FeaturesDescriptionScreen({
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
    required this.state,
    required this.city,
    required this.area,
    required this.rcPath,
    required this.insurancePath,
    required this.pollutionPath,
    required this.leaseType,
    required this.leaseDuration,
    required this.noticePeriod,
    required this.availableFrom,
    required this.monthlyPrice,
    required this.includedKm,
    required this.extraKmCharge,
  });

  @override
  State<FeaturesDescriptionScreen> createState() =>
      _FeaturesDescriptionScreenState();
}

class _FeaturesDescriptionScreenState
    extends State<FeaturesDescriptionScreen> {
  // ── Security Deposit controller ──────────────────────────────────────────
  final TextEditingController _securityDepositController =
  TextEditingController();

  // ── Selected features ────────────────────────────────────────────────────
  final Set<String> _selectedFeatures = {};

  // ── Errors ───────────────────────────────────────────────────────────────
  String? _securityDepositError;

  // ── Available features list ───────────────────────────────────────────────
  final List<String> _features = const [
    'GPS Tracking',
    'Air Conditioning',
    'ABS',
    'Power Steering',
    'Power Windows',
    'Airbags',
    'Music System',
    'Bluetooth',
    'USB Charging',
  ];

  @override
  void dispose() {
    _securityDepositController.dispose();
    super.dispose();
  }

  bool _validate() {
    bool valid = true;
    setState(() {
      final deposit = _securityDepositController.text.trim();
      if (deposit.isEmpty || (int.tryParse(deposit) ?? 0) <= 0) {
        _securityDepositError = 'Enter a valid security deposit amount';
        valid = false;
      } else {
        _securityDepositError = null;
      }
    });
    return valid;
  }

  void _onSaveAndNext() {
    FocusScope.of(context).unfocus();

    if (!_validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill all required fields',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: Color(0xFF323232),
          behavior: SnackBarBehavior.fixed,
          duration: Duration(seconds: 2),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PreviewSubmitScreen(
          vehicleType: widget.vehicleType,
          brand: widget.brand,
          model: widget.model,
          fuelType: widget.fuelType,
          transmission: widget.transmission,
          year: widget.year,
          kmDriven: widget.kmDriven,
          imagePaths: widget.imagePaths,
          additionalInfo: widget.additionalInfo,
          state: widget.state,
          city: widget.city,
          area: widget.area,
          rcPath: widget.rcPath,
          insurancePath: widget.insurancePath,
          pollutionPath: widget.pollutionPath,
          leaseType: widget.leaseType,
          leaseDuration: widget.leaseDuration,
          noticePeriod: widget.noticePeriod,
          availableFrom: widget.availableFrom,
          monthlyPrice: widget.monthlyPrice,
          securityDeposit: _securityDepositController.text.trim(),
          includedKm: widget.includedKm,
          extraKmCharge: widget.extraKmCharge,
          selectedFeatures: _selectedFeatures.toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
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
                        'Features & Descriptions',
                        style: TextStyle(
                          color: const Color(0xFF01422D),
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        'Select Features',
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // ── Feature chips ───────────────────────────────────
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: _features.map((feature) {
                          final isSelected =
                          _selectedFeatures.contains(feature);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedFeatures.remove(feature);
                                } else {
                                  _selectedFeatures.add(feature);
                                }
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 14.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF005F65)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF005F65)
                                      : const Color(0xFFE2E2E2),
                                ),
                              ),
                              child: Text(
                                feature,
                                style: TextStyle(
                                  fontSize: 12.5.sp,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      SizedBox(height: 20.h),

                      // ── Monthly Lease Price (read-only display) ──────────
                      _buildLabeledTextField(
                        label: 'Monthly Lease Price',
                        controller: TextEditingController(
                            text: widget.monthlyPrice),
                        placeholder: 'Enter amount',
                        prefixText: '₹  ',
                        readOnly: true,
                      ),

                      // ── Security Deposit ─────────────────────────────────
                      _buildLabeledTextField(
                        label: 'Security Deposit',
                        controller: _securityDepositController,
                        placeholder: 'Enter amount',
                        prefixText: '₹  ',
                        error: _securityDepositError,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(7),
                        ],
                        onChanged: (_) =>
                            setState(() => _securityDepositError = null),
                      ),

                      // ── Included KM per Month (read-only display) ────────
                      _buildLabeledTextField(
                        label: 'Included KM per Month',
                        controller:
                        TextEditingController(text: widget.includedKm),
                        placeholder: 'Enter KM',
                        suffixText: 'km',
                        readOnly: true,
                      ),

                      // ── Extra KM Charge (read-only display) ──────────────
                      _buildLabeledTextField(
                        label: 'Extra KM Charge',
                        controller: TextEditingController(
                            text: widget.extraKmCharge),
                        placeholder: 'Enter amount',
                        prefixText: '₹  ',
                        readOnly: true,
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
                                    borderRadius:
                                    BorderRadius.circular(10.r)),
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
                                    borderRadius:
                                    BorderRadius.circular(8.r)),
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

  // ── Labeled text field ──────────────────────────────────────────────────
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
              fillColor: readOnly
                  ? const Color(0xFFF4F4F4)
                  : Colors.white,
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
                borderSide:
                const BorderSide(color: Color(0xFF005F65)),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide:
                const BorderSide(color: Color(0xFFB00020)),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide:
                const BorderSide(color: Color(0xFFB00020)),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide:
                const BorderSide(color: Color(0xFFE2E2E2)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}