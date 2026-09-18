import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:provider/provider.dart';
import 'package:true_motors/app_drawer_module/home_screen.dart';
import 'package:true_motors/provider/common_dropdown_provider.dart';
import 'package:true_motors/provider/seller_insert_step_provider.dart';
import 'package:true_motors/menu_module/listing_manager.dart';

class SellerInformationScreen extends StatefulWidget {
  // All data passed from previous screens
  final String registrationNumber;
  final String vehicleType;
  final String brand;
  final String model;
  final String fuelType;
  final String transmission;
  final String? category;
  final String? mfgYear;
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
  final String? currentLocation;
  final String? vehicleLocation;
  final String? listingId;
  final String? condition;
  final String? conditionLabel;
  final bool? isNegotiable;
  final String? pucDate;

  const SellerInformationScreen({
    super.key,
    required this.registrationNumber,
    required this.vehicleType,
    required this.brand,
    required this.model,
    required this.fuelType,
    required this.transmission,
    this.category,
    this.mfgYear,
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
    this.currentLocation,
    this.vehicleLocation,
    this.listingId,
    this.condition,
    this.conditionLabel,
    this.isNegotiable,
    this.pucDate,
  });

  @override
  State<SellerInformationScreen> createState() =>
      _SellerInformationScreenState();
}

class _SellerInformationScreenState extends State<SellerInformationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _additionalInfoController =
  TextEditingController();

  // Status: '1' = Available, '0' = Not Available
  String _status = '1';

  // Validation errors
  String? _nameError;
  String? _contactError;
  bool _isSubmittingStep4 = false;

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
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
    });
    return valid;
  }

  Future<void> _onSubmit() async {
    if (!_validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields correctly'),
        ),
      );
      return;
    }

    if (_isSubmittingStep4) return;
    setState(() => _isSubmittingStep4 = true);

    try {
      final stepProvider = context.read<SellerInsertStepProvider>();
      final commonProvider = context.read<CommonDropdownProvider>();
      final activeListingId = widget.listingId ?? stepProvider.currentListingId;

      // Map feature names to feature IDs from commonProvider.featureItems
      final List<String> featureIds = [];
      for (final fName in widget.features) {
        final match = commonProvider.featureItems.where(
          (item) =>
              item.name.toLowerCase() == fName.toLowerCase() ||
              (item.featureName != null &&
                  item.featureName!.toLowerCase() == fName.toLowerCase()),
        ).firstOrNull;
        if (match != null) {
          featureIds.add(match.id.toString());
        } else {
          final parsed = int.tryParse(fName);
          if (parsed != null) {
            featureIds.add(fName);
          }
        }
      }

      Step4Response? step4Res;
      if (activeListingId != null && activeListingId.isNotEmpty) {
        step4Res = await stepProvider.submitStep4(
          listingId: activeListingId,
          status: _status,
          features: featureIds,
          sellerName: _nameController.text.trim(),
          contactNumber: _contactController.text.trim(),
          additionalInfo: _additionalInfoController.text.trim().isNotEmpty
              ? _additionalInfoController.text.trim()
              : widget.additionalInfo,
          vehicleImages: widget.images,
        );
      }

      if (!mounted) return;
      setState(() => _isSubmittingStep4 = false);

      if (step4Res != null || activeListingId == null) {
        // Save listing to pending in ListingManager
        final listing = VehicleListing(
          id: activeListingId ?? ListingManager().generateId(),
          brand: widget.brand,
          model: widget.model,
          fuelType: widget.fuelType,
          transmission: widget.transmission,
          category: widget.category,
          mfgYear: widget.mfgYear,
          regYear: widget.regYear,
          kmDriven: widget.kmDriven,
          location: widget.location,
          rto: widget.rto,
          price: widget.price,
          insuranceDate: widget.insuranceDate,
          features: widget.features,
          images: widget.images,
          allowTestDrive: widget.allowTestDrive,
          additionalInfo: _additionalInfoController.text.trim().isNotEmpty
              ? _additionalInfoController.text.trim()
              : widget.additionalInfo,
          registrationNumber: widget.registrationNumber,
          vehicleType: widget.vehicleType,
          status: 'pending',
          currentLocation: widget.vehicleLocation ?? widget.currentLocation,
          condition: widget.condition,
          conditionLabel: widget.conditionLabel,
          isNegotiable: widget.isNegotiable,
          pucDate: widget.pucDate,
        );
        ListingManager().addListing(listing);
        _showSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(stepProvider.step4Error ??
                'Failed to submit listing. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmittingStep4 = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool _hasNavigatedToStep1 = false;

  void _navigateToStep1() {
    if (_hasNavigatedToStep1) return;
    _hasNavigatedToStep1 = true;
    if (mounted && Navigator.canPop(context)) {
      Navigator.of(context, rootNavigator: true).pop(); // close dialog
    }
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen(initialIndex: 2)),
      (route) => false,
    );
  }

  void _showSuccessDialog() {
    // Reset provider draft state
    context.read<SellerInsertStepProvider>().reset();
    _hasNavigatedToStep1 = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 10.h),
            Container(
              width: 56.r,
              height: 56.r,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: const Color(0xFF2E7D32),
                size: 38.r,
              ),
            ),
            SizedBox(height: 14.h),
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
              style: TextStyle(fontSize: 13.5.sp, color: Colors.black87),
            ),
            SizedBox(height: 12.h),
            Text(
              'Moving to Sell Car...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: SizedBox(
              width: 140.w,
              height: 40.h,
              child: ElevatedButton(
                onPressed: _navigateToStep1,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005F65),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r)),
                ),
                child: Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    // Automatically move to Step 1 screen after 1.8 seconds
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted && !_hasNavigatedToStep1) {
        _navigateToStep1();
      }
    });
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

                      // ── Status ────────────────────────────────────────────
                      _buildSectionLabel('Status'),
                      Container(
                        margin: EdgeInsets.only(bottom: 14.h),
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: const Color(0xFFE2E2E2)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(() => _status = '1'),
                                borderRadius: BorderRadius.circular(6.r),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 20.r,
                                      height: 20.r,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: _status == '1'
                                              ? const Color(0xFF005F65)
                                              : const Color(0xFFB4B4B4),
                                          width: _status == '1' ? 6.r : 1.5.r,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'Available',
                                      style: TextStyle(
                                        fontSize: 13.5.sp,
                                        fontWeight: _status == '1'
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                        color: _status == '1'
                                            ? const Color(0xFF005F65)
                                            : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(() => _status = '0'),
                                borderRadius: BorderRadius.circular(6.r),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 20.r,
                                      height: 20.r,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: _status == '0'
                                              ? const Color(0xFF005F65)
                                              : const Color(0xFFB4B4B4),
                                          width: _status == '0' ? 6.r : 1.5.r,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'Not Available',
                                      style: TextStyle(
                                        fontSize: 13.5.sp,
                                        fontWeight: _status == '0'
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                        color: _status == '0'
                                            ? const Color(0xFF005F65)
                                            : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
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
                              onPressed: _isSubmittingStep4 ? null : _onSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF005F65),
                                padding:
                                EdgeInsets.symmetric(vertical: 12.h),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.r)),
                              ),
                              child: _isSubmittingStep4
                                  ? SizedBox(
                                      width: 22.r,
                                      height: 22.r,
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
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