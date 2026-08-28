import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:true_motors/menu_module/listing_manager.dart';

class SellerInformationScreen extends StatefulWidget {
  // All data passed from previous screens
  final String registrationNumber;
  final String vehicleType;
  final String brand;
  final String model;
  final String fuelType;
  final String transmission;
  final String regYear;
  final String kmDriven;
  final String location;
  final String rto;
  final String price;
  final String insuranceDate;
  final List<String> features;
  final List<File> images;
  final bool allowTestDrive;
  final String additionalInfo;

  const SellerInformationScreen({
    super.key,
    required this.registrationNumber,
    required this.vehicleType,
    required this.brand,
    required this.model,
    required this.fuelType,
    required this.transmission,
    required this.regYear,
    required this.kmDriven,
    required this.location,
    required this.rto,
    required this.price,
    required this.insuranceDate,
    required this.features,
    required this.images,
    required this.allowTestDrive,
    required this.additionalInfo,
  });

  @override
  State<SellerInformationScreen> createState() =>
      _SellerInformationScreenState();
}

class _SellerInformationScreenState extends State<SellerInformationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _additionalInfoController =
  TextEditingController();

  // Validation errors
  String? _nameError;
  String? _contactError;
  String? _cityError;

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _cityController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }

  bool _validate() {
    bool valid = true;
    setState(() {
      // Seller name
      if (_nameController.text.trim().isEmpty) {
        _nameError = 'Please enter your name';
        valid = false;
      } else if (_nameController.text.trim().length < 3) {
        _nameError = 'Name must be at least 3 characters';
        valid = false;
      } else {
        _nameError = null;
      }

      // Contact number
      final contact = _contactController.text.trim();
      if (contact.isEmpty) {
        _contactError = 'Please enter a contact number';
        valid = false;
      } else if (!RegExp(r'^[6-9]\d{9}$').hasMatch(contact)) {
        _contactError = 'Enter a valid 10-digit Indian mobile number';
        valid = false;
      } else {
        _contactError = null;
      }

      // City
      if (_cityController.text.trim().isEmpty) {
        _cityError = 'Please enter your city';
        valid = false;
      } else {
        _cityError = null;
      }
    });
    return valid;
  }

  void _onSubmit() {
    if (_validate()) {
      // Save listing to pending in ListingManager
      final listing = VehicleListing(
        id: ListingManager().generateId(),
        brand: widget.brand,
        model: widget.model,
        fuelType: widget.fuelType,
        transmission: widget.transmission,
        regYear: widget.regYear,
        kmDriven: widget.kmDriven,
        location: widget.location,
        rto: widget.rto,
        price: widget.price,
        insuranceDate: widget.insuranceDate,
        features: widget.features,
        images: widget.images,
        allowTestDrive: widget.allowTestDrive,
        additionalInfo: widget.additionalInfo,
        registrationNumber: widget.registrationNumber,
        vehicleType: widget.vehicleType,
        status: 'pending',
      );
      ListingManager().addListing(listing);
      _showSuccessDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields correctly'),
        ),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 16.h),
            Text(
              'Vehicle Listed Successfully!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 17.5.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF005F65)),
            ),
            SizedBox(height: 8.h),
            Text(
              'Your ${widget.vehicleType} (${widget.registrationNumber}) has been listed. Our team will contact you shortly.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.5.sp, color: Colors.black),
            ),
          ],
        ),
        actions: [
          Center(
            child: SizedBox(
              width: 150.w,
              height: 44.h,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // close dialog
                  Navigator.popUntil(
                      context, (route) => route.isFirst); // go to home
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005F65),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                ),
                child: Text('Go to Home',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ],
      ),
    );
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
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F3F3),
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
                      // Page title
                      Text(
                        'Seller Information',
                        style: TextStyle(
                            fontSize: 15.5.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF000000)),
                      ),
                      SizedBox(height: 16.h),

                      // ── Seller Name ───────────────────────────────────────
                      _buildSectionLabel('Seller Name'),
                      _buildTextField(
                        controller: _nameController,
                        hint: 'Enter your full name',
                        error: _nameError,
                        keyboardType: TextInputType.name,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z\s]')),
                        ],
                        onChanged: (_) => setState(() => _nameError = null),
                      ),

                      // ── Contact Number ────────────────────────────────────
                      _buildSectionLabel('Contact Number'),
                      _buildTextField(
                        controller: _contactController,
                        hint: 'Enter 10-digit mobile number',
                        error: _contactError,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (_) => setState(() => _contactError = null),
                      ),

                      // ── City ──────────────────────────────────────────────
                      _buildSectionLabel('City'),
                      _buildTextField(
                        controller: _cityController,
                        hint: 'Enter your city',
                        error: _cityError,
                        keyboardType: TextInputType.text,
                        onChanged: (_) => setState(() => _cityError = null),
                      ),

                      // ── Additional Info (Optional) ────────────────────────
                      _buildSectionLabel('Additional Info (Optional)'),
                      TextField(
                        controller: _additionalInfoController,
                        maxLines: 4,
                        style: TextStyle(fontSize: 13.5.sp),
                        decoration: InputDecoration(
                          hintText: 'Any additional notes',
                          hintStyle: TextStyle(
                              color: Colors.grey, fontSize: 13.sp),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide:
                            const BorderSide(color: Color(0xFFA7A7A7)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide:
                            const BorderSide(color: Color(0xFFA7A7A7)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide:
                            const BorderSide(color: Color(0xFF005F65)),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.all(12.w),
                        ),
                      ),
                      SizedBox(height: 36.h),

                      // ── Navigation buttons ────────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding:
                                EdgeInsets.symmetric(vertical: 12.h),
                                side: const BorderSide(
                                    color: Color(0xFF005F65)),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.r)),
                              ),
                              child: Text(
                                'Previous',
                                style: TextStyle(
                                    color: const Color(0xFF005F65),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15.sp),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _onSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF005F65),
                                padding:
                                EdgeInsets.symmetric(vertical: 12.h),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.r)),
                              ),
                              child: Text(
                                'Submit',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15.sp),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back,
                size: 24.r, color: const Color(0xFF01422D)),
          ),
          SizedBox(width: 16.w),
          Text('Seller Information',
              style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF01422D))),
        ],
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF052243),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 10.w, top: 8.h, bottom: 8.h),
            child: Image.asset(
              'assets/sell_image/red_car.png',
              width: 130.w,
              fit: BoxFit.contain,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 14.w, top: 12.h, bottom: 12.h, left: 4.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Sell your car instantly',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Calistoga',
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15.5.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Best price.Free inspection',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Calistoga',
                        color: Colors.white,
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      'Get Free Quote',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Calistoga',
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 13.5.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required String? error,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLength: maxLength,
        inputFormatters: inputFormatters,
        onChanged: onChanged,
        style: TextStyle(fontSize: 13.5.sp),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
          TextStyle(color: const Color(0xFFB4B4B4), fontSize: 13.5.sp),
          errorText: error,
          errorStyle: TextStyle(fontSize: 11.5.sp),
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: const BorderSide(color: Color(0xFFE2E2E2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide(
                color: error != null ? Colors.red : const Color(0xFFE2E2E2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide(
              color: error != null ? Colors.red : const Color(0xFF005F65),
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
          EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        ),
      ),
    );
  }
}