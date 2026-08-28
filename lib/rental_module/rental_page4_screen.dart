import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'rental_booking_model.dart';
import 'rental_page_screen.dart';
import 'payment_options_screen.dart';

class RentalPage4Screen extends StatefulWidget {
  final RentalBookingData bookingData;
  const RentalPage4Screen({super.key, required this.bookingData});

  @override
  State<RentalPage4Screen> createState() => _RentalPage4ScreenState();
}

class _RentalPage4ScreenState extends State<RentalPage4Screen> {
  static const List<Map<String, String>> priceRows = [
    {'label': 'Base Price', 'value': '₹ 2,150'},
    {'label': 'Delivery & pickup charge', 'value': '₹ 500'},
    {'label': 'Refundable security deposit', 'value': '₹ 1,000'},
    {'label': 'Total', 'value': '₹ 3,650'},
  ];

  void _goBackToEdit() {
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (_, anim, __) => RentalPageScreen(existingData: widget.bookingData),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
          (route) => route.isFirst,
    );
  }

  void showImportantPointsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) => ImportantPointsSheet(bookingData: widget.bookingData),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double hp = screenWidth * 0.055;
    final double scale = screenWidth / 360.0;
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.white, statusBarIconBrightness: Brightness.dark),
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F2F2),
        body: Column(
          children: [
            Container(width: double.infinity, height: statusBarHeight, color: Colors.transparent),
            Container(
              width: double.infinity, color: const Color(0xFFFFFFFF),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(children: [
                GestureDetector(onTap: () => Navigator.pop(context), child: Icon(Icons.arrow_back, size: 24.r, color: const Color(0xFF01422D))),
                SizedBox(width: 15.w),
                Text('Booking Summary', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: 18.sp, color: const Color(0xFF01422D))),
              ]),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(height: 12.h),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text('Rental Vehicle By Truemotors', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: 16.sp, color: const Color(0xFF000000)))),
                  SizedBox(height: 10.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: ClipRRect(borderRadius: BorderRadius.circular(10.r),
                        child: Image.asset('assets/rental_screen/Hyundai Creta.png', width: double.infinity, height: 170.h, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(height: 170.h, decoration: BoxDecoration(color: const Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(10.r)),
                                child: Center(child: Icon(Icons.directions_car, size: 60.r, color: Colors.grey))))),
                  ),
                  SizedBox(height: 12.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Expanded(child: Text('Hyundai Creta', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: 16.sp, color: const Color(0xFF000000)))),
                        Image.asset('assets/rental_screen/Like.png', width: 22.r, height: 22.r, errorBuilder: (_, __, ___) => Icon(Icons.favorite_border, size: 22.r, color: const Color(0xFF666666))),
                        SizedBox(width: 12.w),
                        Image.asset('assets/rental_screen/Share.png', width: 22.r, height: 22.r, errorBuilder: (_, __, ___) => Icon(Icons.share_outlined, size: 22.r, color: const Color(0xFF666666))),
                      ]),
                      SizedBox(height: 6.h),
                      Row(children: [
                        Image.asset('assets/rental_screen/Location.png', width: 20.r, height: 20.r, errorBuilder: (_, __, ___) => Icon(Icons.location_on, size: 20.r, color: const Color(0xFF003399))),
                        SizedBox(width: 4.w),
                        Text('Coimbatore', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: 13.5.sp, color: const Color(0xFF003399))),
                        const Spacer(),
                        Image.asset('assets/rental_screen/Star.png', width: 20.r, height: 20.r, errorBuilder: (_, __, ___) => Icon(Icons.star, size: 20.r, color: Colors.amber)),
                        SizedBox(width: 4.w),
                        Text('4.5/5', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: 13.sp, color: const Color(0xFF000000))),
                      ]),
                    ]),
                  ),
                  SizedBox(height: 12.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10.r), border: Border.all(color: const Color(0xFFB5B4B4))),
                      padding: EdgeInsets.all(14.w),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Expanded(child: Text('Car Name : ${widget.bookingData.carName}',
                              style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: 13.5.sp, color: const Color(0xFF000000)))),
                          GestureDetector(onTap: _goBackToEdit, child: Row(children: [
                            Image.asset('assets/rental_screen/Edit.png', width: 14.r, height: 14.r, errorBuilder: (_, __, ___) => Icon(Icons.edit_outlined, size: 14.r, color: const Color(0xFF01422D))),
                            SizedBox(width: 4.w),
                            Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                              Text('Edit', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 12.sp, color: const Color(0xFF01422D))),
                              Container(height: 1, width: 24.w, color: const Color(0xFF01422D)),
                            ]),
                          ])),
                        ]),
                        SizedBox(height: 10.h),
                        Row(children: [
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Pickup Date & Time', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: 13.5.sp, color: const Color(0xFF000000))),
                            SizedBox(height: 2.h),
                            Text(widget.bookingData.pickupDate, style: TextStyle(fontFamily: 'Poppins', fontSize: 11.5.sp, fontWeight: FontWeight.w500, color: const Color(0xFF3C3C3C))),
                          ])),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Return Date & Time', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: 13.5.sp, color: const Color(0xFF000000))),
                            SizedBox(height: 2.h),
                            Text(widget.bookingData.returnDate, style: TextStyle(fontFamily: 'Poppins', fontSize: 11.5.sp, fontWeight: FontWeight.w500, color: const Color(0xFF3C3C3C))),
                          ])),
                        ]),
                        SizedBox(height: 10.h),
                        Text('Location', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: 13.5.sp, color: const Color(0xFF000000))),
                        SizedBox(height: 2.h),
                        Text(widget.bookingData.location, style: TextStyle(fontFamily: 'Poppins', fontSize: 11.5.sp, fontWeight: FontWeight.w500, color: const Color(0xFF3C3C3C))),
                        SizedBox(height: 12.h),
                        ...priceRows.map((row) {
                          final bool isTotal = row['label'] == 'Total';
                          return Padding(padding: EdgeInsets.only(bottom: 8.h), child: Row(children: [
                            Expanded(child: Text(row['label']!, style: TextStyle(fontFamily: 'Inter', fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400, fontSize: 13.sp, color: const Color(0xFF000000)))),
                            Text(row['value']!, style: TextStyle(fontFamily: 'Inter', fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400, fontSize: 13.5.sp, color: const Color(0xFF000000))),
                          ]));
                        }),
                      ]),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Center(
                    child: SizedBox(
                      width: 280.w, height: 42.h,
                      child: ElevatedButton(
                        onPressed: () => showImportantPointsSheet(context),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF005F65), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)), elevation: 0),
                        child: Text('Pay Now', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 15.sp, color: Colors.white)),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Important Points Sheet ────────────────────────────────────────────────────

class ImportantPointsSheet extends StatefulWidget {
  final RentalBookingData bookingData;
  const ImportantPointsSheet({super.key, required this.bookingData});

  @override
  State<ImportantPointsSheet> createState() => _ImportantPointsSheetState();
}

class _ImportantPointsSheetState extends State<ImportantPointsSheet> {
  bool isChecked = false;

  static const List<Map<String, String>> points = [
    {'title': 'Driver License', 'subtitle': 'Passport, national ID, or government-issued photo identification.'},
    {'title': 'Identity Proof', 'subtitle': 'Passport, national ID, or government-issued photo identification.'},
    {'title': '21 + Years of age', 'subtitle': 'Minimum age for driving (usually 21 or 25 depending on the country).'},
  ];

  Future<void> _saveBooking() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> existing = prefs.getStringList('my_rental_bookings') ?? [];
    final Map<String, String> booking = {
      'carName': widget.bookingData.carName,
      'pickupDate': widget.bookingData.pickupDate,
      'returnDate': widget.bookingData.returnDate,
      'location': widget.bookingData.location,
      'total': '₹ 3,650',
      'status': 'Confirmed',
      'bookedAt': DateTime.now().toIso8601String(),
    };
    existing.insert(0, jsonEncode(booking));
    await prefs.setStringList('my_rental_bookings', existing);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 24.h),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          GestureDetector(onTap: () => Navigator.pop(context),
              child: Image.asset('assets/rental_screen/Arrow.png', width: 22.r, height: 22.r, errorBuilder: (_, __, ___) => Icon(Icons.arrow_back_ios, size: 18.r, color: const Color(0xFF000000)))),
          SizedBox(width: 9.w),
          Text('Important points for booking', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 15.sp, color: const Color(0xFF000000))),
        ]),
        SizedBox(height: 16.h),
        Text('You must be physically present to receive the car and provide the required documents to our delivery agent.',
            style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w400, fontSize: 14.sp, color: const Color(0xFF000000), height: 1.5)),
        SizedBox(height: 16.h),
        ...points.map((point) => Padding(padding: EdgeInsets.only(bottom: 14.h), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Image.asset('assets/rental_screen/Group.png', width: 22.r, height: 22.r, errorBuilder: (_, __, ___) => Icon(Icons.badge_outlined, size: 22.r, color: const Color(0xFF555555))),
          SizedBox(width: 10.w),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(point['title']!, style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500, fontSize: 14.5.sp, color: const Color(0xFF000000))),
            SizedBox(height: 2.h),
            Text(point['subtitle']!, style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w400, fontSize: 12.5.sp, color: const Color(0xFF4E4E4E))),
          ])),
        ]))),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () => setState(() => isChecked = !isChecked),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r), border: Border.all(color: isChecked ? const Color(0xFF005F65) : const Color(0xFFBDBDBD))),
            padding: EdgeInsets.all(12.w),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200), width: 18.r, height: 18.r,
                decoration: BoxDecoration(color: isChecked ? const Color(0xFF005F65) : Colors.transparent,
                    border: Border.all(color: isChecked ? const Color(0xFF005F65) : const Color(0xFFBDBDBD), width: 1.5), borderRadius: BorderRadius.circular(4.r)),
                child: isChecked ? Icon(Icons.check, size: 12.r, color: Colors.white) : null,
              ),
              SizedBox(width: 10.w),
              Expanded(child: Text('I understand that if the required documents are not provided at the time of delivery, the car will not be handed over, and cancellation charges may apply.',
                  style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w400, fontSize: 11.5.sp, color: const Color(0xFF000000), height: 1.5))),
            ]),
          ),
        ),
        SizedBox(height: 20.h),
        SizedBox(
          width: double.infinity, height: 46.h,
          child: ElevatedButton(
            onPressed: isChecked ? () async {
              await _saveBooking();
              Navigator.pop(context);
              Navigator.push(context, PageRouteBuilder(
                pageBuilder: (_, anim, __) => PaymentOptionsScreen(bookingData: widget.bookingData),
                transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
                transitionDuration: const Duration(milliseconds: 300),
              ));
            } : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF005F65), disabledBackgroundColor: const Color(0xFF005F65).withValues(alpha: 0.8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)), elevation: 0,
            ),
            child: Text('Agree And continue', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 15.sp, color: Colors.white)),
          ),
        ),
      ]),
    );
  }
}