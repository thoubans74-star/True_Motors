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
  final TextEditingController _additionalInfoController =
  TextEditingController();
  bool _allowTestDrive = false;

  // Validation
  String? _photoError;

  static const int _maxWordCount = 200;

  int get _wordCount {
    final text = _additionalInfoController.text.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  }

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
            price: widget.price,
            insuranceDate: widget.insuranceDate,
            features: widget.features,
            images: _selectedImages,
            allowTestDrive: _allowTestDrive,
            additionalInfo: _additionalInfoController.text.trim(),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _additionalInfoController.dispose();
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

                      // Title
                      Text(
                        'Sell Vehicle - ${widget.registrationNumber}',
                        style: TextStyle(
                            fontSize: 15.sp, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 14.h),

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
                        child: Row(
                          children: [
                            Icon(Icons.add, color: const Color(0xFF742B88), size: 20.r),
                            SizedBox(width: 6.w),
                            Text(
                              'Add more images',
                              style: TextStyle(
                                fontFamily: 'Lato',
                                  color: const Color(0xFF742B88),
                                  fontSize: 14.5.sp,
                                  fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // ── Terms & Conditions button ─────────────────────────
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const TermsAndConditionsScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.r),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFD59090),
                                  Color(0xFFDF7B7B),
                                ],
                              ),
                            ),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              alignment: Alignment.center,
                              child: Text(
                                'Terms & Conditions For Sell Vehicle',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14.sp,
                                  fontFamily: 'Lato'
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // ── Allow Test Drive ──────────────────────────────────
                      Row(
                        children: [
                          SizedBox(
                            width: 22.r,
                            height: 22.r,
                            child: Checkbox(
                              value: _allowTestDrive,
                              activeColor: const Color(0xFF005F65),
                              side: const BorderSide(
                                width: 1.2,
                                color: Color(0xFF742B88)
                              ),
                              onChanged: (v) =>
                                  setState(() => _allowTestDrive = v ?? false),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Allow Test drive',
                            style: TextStyle(
                                fontSize: 13.5.sp, color: Colors.black),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      // ── Additional Info ───────────────────────────────────
                      Text(
                        'Additional Info (Optional)',
                        style: TextStyle(
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      ),
                      SizedBox(height: 8.h),
                      TextField(
                        controller: _additionalInfoController,
                        maxLines: 5,
                        style: TextStyle(fontSize: 13.5.sp),
                        onChanged: (text) {
                          final words = text
                              .trim()
                              .split(RegExp(r'\s+'))
                              .where((w) => w.isNotEmpty)
                              .toList();
                          if (words.length > _maxWordCount) {
                            final trimmed =
                            words.take(_maxWordCount).join(' ');
                            _additionalInfoController.value =
                                TextEditingValue(
                                  text: trimmed,
                                  selection: TextSelection.collapsed(
                                      offset: trimmed.length),
                                );
                          }
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          hintText:
                          'Describe your vehicle',
                          hintStyle: TextStyle(
                              color: Colors.grey, fontSize: 13.sp),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide:
                            const BorderSide(color: Color(0xFFD4D4D4)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide:
                            const BorderSide(color: Color(0xFFD4D4D4)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: const BorderSide(
                                color: Color(0xFF005F65)),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.all(12.w),
                        ),
                      ),
                      // Word counter
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: EdgeInsets.only(top: 4.h),
                          child: Text(
                            '$_wordCount / $_maxWordCount words',
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              color: _wordCount >= _maxWordCount
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // ── Navigation buttons ────────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                    vertical: 12.h),
                                side: const BorderSide(
                                    color: Color(0xFF005F65)),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r)),
                              ),
                              child: Text(
                                'Previous',
                                style: TextStyle(
                                    color: const Color(0xFF005F65),
                                    fontWeight: FontWeight.w700, fontSize: 14.5.sp),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _onSaveAndNext,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF005F65),
                                padding: EdgeInsets.symmetric(
                                    vertical: 12.h),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r)),
                              ),
                              child: Text(
                                'Save & Next',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14.5.sp),
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

  // ── Dashed upload box — always visible, matches Figma exactly ────────────
  Widget _buildDashedUploadBox() {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: const Color(0xFF005F65),
        borderRadius: 12.r,
        dashWidth: 10.w,
        dashSpace: 8.w,
        strokeWidth: 3.w,
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 40.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Text first (matches Figma order)
            Text(
              'Tap to upload your photo',
              style: TextStyle(
                fontSize: 14.5.sp,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),

            // Cloud icon — tapping opens file picker
            GestureDetector(
              onTap: _openFilePicker,
              child: Image.asset('assets/sell_image/cloud.png',
                height: 44.r,
                width: 44.r,
              )
            ),
            SizedBox(height: 8.h),

            // Max size label
            Text(
              'Maximum 5 MB file size',
              style: TextStyle(fontSize: 13.5.sp, color: Colors.black),
            ),
            SizedBox(height: 14.h),

            // Divider with "or"
            Row(
              children: [
                const Expanded(
                  child: Divider(
                      color: Color(0xFFBABABA), thickness: 1),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Text(
                    'or',
                    style: TextStyle(fontSize: 13.5.sp, color: Colors.black),
                  ),
                ),
                const Expanded(
                  child: Divider(
                      color: Color(0xFFBABABA), thickness: 1),
                ),
              ],
            ),
            SizedBox(height: 14.h),

            // Open Camera button
            SizedBox(
              width: 170.w,
              child: ElevatedButton(
                onPressed: _openCamera,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005F65),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                ),
                child: Text(
                  'Open Camera',
                  style: TextStyle(
                      fontSize: 14.5.sp, fontWeight: FontWeight.w700),
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