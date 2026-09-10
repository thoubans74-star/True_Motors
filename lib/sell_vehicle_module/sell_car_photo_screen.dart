import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import 'package:file_picker/file_picker.dart';
import 'seller_information_screen.dart';
import 'terms_and_conditions_screen.dart';

class SellCarPhotoScreen extends StatefulWidget {
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

  const SellCarPhotoScreen({
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
  });

  @override
  State<SellCarPhotoScreen> createState() => _SellCarPhotoScreenState();
}

class _SellCarPhotoScreenState extends State<SellCarPhotoScreen> {
  final ImagePicker _picker = ImagePicker();
  final List<File> _selectedImages = [];
  final TextEditingController _priceController = TextEditingController();
  bool _isNegotiable = true;

  // Validation
  String? _photoError;

  // ── Image picking ─────────────────────────────────────────────────────────

  Future<void> _openCamera() async {
    try {
      final XFile? photo =
      await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
      if (photo != null) {
        setState(() {
          _selectedImages.add(File(photo.path));
          _photoError = null;
        });
      }
    } catch (e) {
      _showError('Camera not available. Please check permissions.');
    }
  }

  Future<void> _openGallery() async {
    try {
      final List<XFile> photos =
      await _picker.pickMultiImage(imageQuality: 85);
      if (photos.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(photos.map((p) => File(p.path)));
          _photoError = null;
        });
      }
    } catch (e) {
      _showError('Gallery not available. Please check permissions.');
    }
  }

  Future<void> _openFilePicker() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );
      if (result != null) {
        setState(() {
          _selectedImages.addAll(result.files.map((f) => File(f.path!)));
          _photoError = null;
        });
      }
    } catch (e) {
      _showError('File picker not available.');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  void _removeImage(int index) {
    setState(() => _selectedImages.removeAt(index));
  }

  // ── Validation & navigation ───────────────────────────────────────────────

  bool _validate() {
    setState(() {
      _photoError =
      _selectedImages.isEmpty ? 'Please add at least one photo' : null;
    });
    return _photoError == null;
  }

  void _onSaveAndNext() {
    if (_validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SellerInformationScreen(
            registrationNumber: widget.registrationNumber,
            vehicleType: widget.vehicleType,
            brand: widget.brand,
            model: widget.model,
            fuelType: widget.fuelType,
            transmission: widget.transmission,
            regYear: widget.regYear,
            kmDriven: widget.kmDriven,
            location: widget.location,
            rto: widget.rto,
            price: _priceController.text.trim(),
            insuranceDate: widget.insuranceDate,
            features: widget.features,
            images: _selectedImages,
            allowTestDrive: false,
            additionalInfo: '',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
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
                      SizedBox(height: 12.h),

                      Text(
                        'Photos & price',
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Listings with 4+ photos and a clear price get more genuine enquiries.',
                        style: TextStyle(
                            fontSize: 12.sp, color: Colors.black54),
                      ),
                      SizedBox(height: 16.h),

                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F3F3),
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          widget.registrationNumber,
                          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
                        ),
                      ),
                      SizedBox(height: 20.h),

                      Text(
                        'Vehicle photos',
                        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Up to 5MB per image · JPG or PNG',
                        style: TextStyle(fontSize: 12.sp, color: Colors.black54),
                      ),
                      SizedBox(height: 12.h),

                      // ── Dashed upload box (always visible) ────────────────
                      _buildDashedUploadBox(),

                      if (_photoError != null)
                        Padding(
                          padding: EdgeInsets.only(top: 6.h),
                          child: Text(
                            _photoError!,
                            style: TextStyle(
                                color: Colors.red, fontSize: 11.5.sp),
                          ),
                        ),

                      SizedBox(height: 14.h),

                      // ── Selected images (shown below the box) ─────────────
                      if (_selectedImages.isNotEmpty) _buildImageGrid(),

                      SizedBox(height: 12.h),

                      // ── Add more images ───────────────────────────────────
                      GestureDetector(
                        onTap: _openGallery,
                        child: Text(
                          '+ Add More photo',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF005F65),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // ── Price ─────────────────────────────────────────────
                      Text(
                        'Price',
                        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Expected selling price',
                        style: TextStyle(fontSize: 12.sp, color: Colors.black54),
                      ),
                      SizedBox(height: 8.h),
                      TextField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: TextStyle(fontSize: 14.sp),
                        decoration: InputDecoration(
                          hintText: 'e.g.698000',
                          hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey),
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(12.w),
                            child: Text(
                              '₹',
                              style: TextStyle(fontSize: 16.sp, color: const Color(0xFF005F65), fontWeight: FontWeight.w600),
                            ),
                          ),
                          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: const BorderSide(color: Color(0xFFE2E2E2)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: const BorderSide(color: Color(0xFF005F65)),
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // ── Price negotiable? ─────────────────────────────────
                      Text(
                        'Price negotiable?',
                        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => _isNegotiable = true),
                            child: Container(
                              width: 70.w,
                              height: 36.h,
                              decoration: BoxDecoration(
                                color: _isNegotiable ? const Color(0xFF742B88) : Colors.white,
                                border: Border.all(
                                    color: _isNegotiable
                                        ? const Color(0xFF742B88)
                                        : const Color(0xFFE2E2E2)),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Yes',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: _isNegotiable ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() => _isNegotiable = false),
                            child: Container(
                              width: 70.w,
                              height: 36.h,
                              decoration: BoxDecoration(
                                color: !_isNegotiable ? const Color(0xFF742B88) : Colors.white,
                                border: Border.all(
                                    color: !_isNegotiable
                                        ? const Color(0xFF742B88)
                                        : const Color(0xFFE2E2E2)),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'No',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: !_isNegotiable ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 40.h),

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
                              'Submit',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.sp),
                            ),
                          ),
                        ),
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

  // ── App bar ───────────────────────────────────────────────────────────────
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
          Text('Sell car',
              style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF01422D))),
        ],
      ),
    );
  }

  // ── Promo banner ──────────────────────────────────────────────────────────
  Widget _buildPromoBanner() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF00274B),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 12.w, bottom: 4.h, top: 4.h),
            child: Image.asset(
              'assets/sell_image/red_car.png',
              width: 130.w,
              height: 120.h,
              fit: BoxFit.contain,
            ),
          ),
          Expanded(
            child: Padding(
              padding:
              EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
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
                  SizedBox(height: 8.h),
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
          ),
        ],
      ),
    );
  }

  Widget _buildDashedUploadBox() {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: const Color(0xFF742B88),
        borderRadius: 12.r,
        dashWidth: 10.w,
        dashSpace: 8.w,
        strokeWidth: 2.w,
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 40.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Icon(Icons.add_photo_alternate_outlined, size: 48.r, color: Colors.black87),
            SizedBox(height: 12.h),

            // Max size label
            Text(
              'Maximum 5 MB file size',
              style: TextStyle(fontSize: 14.sp, color: Colors.black),
            ),
            SizedBox(height: 16.h),

            // Upload Image button
            SizedBox(
              width: 140.w,
              child: ElevatedButton(
                onPressed: _openGallery,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF742B88),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.r)),
                ),
                child: Text(
                  'Upload Image',
                  style: TextStyle(
                      fontSize: 13.sp, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Selected images shown below the dashed box ────────────────────────────
  Widget _buildImageGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Horizontal scrollable thumbnails
        SizedBox(
          height: 90.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _selectedImages.length,
            itemBuilder: (_, i) {
              return Stack(
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 10.w),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Image.file(
                        _selectedImages[i],
                        width: 90.w,
                        height: 90.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4.h,
                    right: 14.w,
                    child: GestureDetector(
                      onTap: () => _removeImage(i),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(3),
                        child: Icon(Icons.close,
                            color: Colors.white, size: 14.r),
                      ),
                    ),
                  ),
                ],
              );
            },
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