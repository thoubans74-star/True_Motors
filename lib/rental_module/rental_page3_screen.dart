import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'rental_booking_model.dart';
import 'rental_page_screen.dart';
import 'rental_page4_screen.dart';

class RentalPage3Screen extends StatefulWidget {
  final RentalBookingData bookingData;
  const RentalPage3Screen({super.key, required this.bookingData});

  @override
  State<RentalPage3Screen> createState() => _RentalPage3ScreenState();
}

class _RentalPage3ScreenState extends State<RentalPage3Screen> {
  final List<String> carImages = ['assets/rental_screen/Hyundai Creta.png', 'assets/rental_screen/Car2.png', 'assets/rental_screen/Car3.png'];
  int currentImageIndex = 0;
  Timer? imageTimer;
  final PageController imagePageController = PageController();

  final List<Map<String, String>> featureIcons = [
    {'image': 'assets/rental_screen/Petrol.png', 'label': 'Petrol'},
    {'image': 'assets/rental_screen/Manual.png', 'label': 'Manual'},
    {'image': 'assets/rental_screen/Seat.png', 'label': '5 Seats'},
  ];
  final List<String> featureChecks = ['Crusie Control', 'Android Auto', 'GPS system', 'Air Conditioning'];

  final List<Map<String, String>> priceRows = [
    {'label': 'Base Price', 'value': '₹ 2,150'},
    {'label': 'Delivery & pickup charge', 'value': '₹ 500'},
    {'label': 'Refundable security deposit', 'value': '₹ 1,000'},
    {'label': 'Total', 'value': '₹ 3,650'},
  ];

  @override
  void initState() {
    super.initState();
    startImageTimer();
  }

  void startImageTimer() {
    imageTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      final int nextIndex = (currentImageIndex + 1) % carImages.length;
      imagePageController.animateToPage(nextIndex, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
      setState(() => currentImageIndex = nextIndex);
    });
  }

  @override
  void dispose() {
    imageTimer?.cancel();
    imagePageController.dispose();
    super.dispose();
  }

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
              width: double.infinity, height: 52.h, color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(children: [
                GestureDetector(onTap: () => Navigator.pop(context), child: Icon(Icons.arrow_back, size: 24.r, color: const Color(0xFF01422D))),
                SizedBox(width: 15.w),
                Text('Rental', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: 18.sp, color: const Color(0xFF01422D))),
              ]),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
                        child: Text('Rental Vehicle By Truemotors', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 16.sp, color: const Color(0xFF000000)))),
                    SizedBox(
                      height: 150.h,
                      child: PageView.builder(
                        controller: imagePageController, itemCount: carImages.length,
                        onPageChanged: (index) => setState(() => currentImageIndex = index),
                        itemBuilder: (context, index) => Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: ClipRRect(borderRadius: BorderRadius.circular(10.r),
                              child: Image.asset(carImages[index], width: double.infinity, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(color: const Color(0xFFE0E0E0), child: Center(child: Icon(Icons.directions_car, size: 60.r, color: Colors.grey))))),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(carImages.length, (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      width: currentImageIndex == i ? 20.w : 8.w, height: 8.h,
                      decoration: BoxDecoration(color: currentImageIndex == i ? const Color(0xFF005F65) : const Color(0xFFBDBDBD), borderRadius: BorderRadius.circular(4.r)),
                    ))),
                    SizedBox(height: 12.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Expanded(child: Text('Hyundai Creta', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 16.sp, color: const Color(0xFF000000)))),
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
                          Text('4.5/5', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: 13.5.sp, color: const Color(0xFF000000))),
                        ]),
                      ]),
                    ),
                    SizedBox(height: 12.h),
                    // Features card
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Container(
                        width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10.r)),
                        padding: EdgeInsets.all(14.w),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Features', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: 13.5.sp, color: const Color(0xFF000000))),
                          SizedBox(height: 12.h),
                          Row(children: featureIcons.map((item) => Expanded(child: Row(children: [
                            Image.asset(item['image']!, width: 18.r, height: 18.r, errorBuilder: (_, __, ___) => Icon(Icons.info_outline, size: 18.r, color: const Color(0xFF555555))),
                            SizedBox(width: 6.w),
                            Text(item['label']!, style: TextStyle(fontFamily: 'Poppins', fontSize: 11.5.sp, color: const Color(0xFF333333))),
                          ]))).toList()),
                          SizedBox(height: 6.h),
                          GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), childAspectRatio: 5.5, mainAxisSpacing: 2, crossAxisSpacing: 4,
                            children: featureChecks.map((feature) => Row(children: [
                              Image.asset('assets/rental_screen/Tick.png', width: 20.r, height: 20.r, errorBuilder: (_, __, ___) => Icon(Icons.check, size: 20.r, color: const Color(0xFF005F65))),
                              SizedBox(width: 6.w),
                              Expanded(child: Text(feature, style: TextStyle(fontFamily: 'Inter', fontSize: 11.5.sp, color: const Color(0xFF333333)), overflow: TextOverflow.ellipsis)),
                            ])).toList(),
                          ),
                          SizedBox(height: 14.h),
                          Text('Description', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: 13.5.sp, color: const Color(0xFF000000))),
                          SizedBox(height: 8.h),
                          Text('Experience the perfect blend of style, space, and performance with the Hyundai Creta. Ideal for city rides and weekend getaways, this premium SUV offers a smooth drive, advanced safety features, and a commanding road presence.',
                              style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: 11.5.sp, color: const Color(0xFF5B5B5B), height: 1.6), textAlign: TextAlign.justify, maxLines: 5, overflow: TextOverflow.ellipsis),
                          SizedBox(height: 10.h),
                          Center(child: Container(width: double.infinity, height: 1, color: const Color(0xFF8B8B8B))),
                          SizedBox(height: 8.h),
                          Text('Owner Info', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 13.5.sp, color: const Color(0xFF000000))),
                          SizedBox(height: 8.h),
                          Row(children: [
                            ClipOval(child: Image.asset('assets/rental_screen/Harish.png', width: 50.r, height: 50.r, fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => CircleAvatar(radius: 25.r, backgroundColor: const Color(0xFFE0E0E0), child: Icon(Icons.person, size: 28.r, color: const Color(0xFF888888))))),
                            SizedBox(width: 12.w),
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('Harish', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: 12.sp, color: const Color(0xFF000000))),
                              SizedBox(height: 4.h),
                              Row(children: [
                                Image.asset('assets/rental_screen/Star.png', width: 18.r, height: 18.r, errorBuilder: (_, __, ___) => Icon(Icons.star, size: 16.r, color: Colors.amber)),
                                SizedBox(width: 4.w),
                                Text('4.5/5  (180 Review)', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: 11.5.sp, color: const Color(0xFF000000))),
                              ]),
                              SizedBox(height: 4.h),
                              Text('Joined 8 Month Ago', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: 11.5.sp, color: const Color(0xFF000000))),
                            ]),
                          ]),
                        ]),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    // Booking summary with booking data + Edit
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
                              Text(widget.bookingData.pickupDate, style: TextStyle(fontFamily: 'Poppins', fontSize: 11.5.sp, color: const Color(0xFF3C3C3C))),
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
                              Expanded(child: Text(row['label']!, style: TextStyle(fontFamily: 'Inter', fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400, fontSize: 13.5.sp, color: const Color(0xFF000000)))),
                              Text(row['value']!, style: TextStyle(fontFamily: 'Inter', fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400, fontSize: 13.5.sp, color: const Color(0xFF000000))),
                            ]));
                          }),
                        ]),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Center(
                      child: SizedBox(
                        width: 280.w, height: 42.h,
                        child: ElevatedButton(
                          onPressed: () => Navigator.push(context, PageRouteBuilder(
                            pageBuilder: (_, anim, __) => RentalPage4Screen(bookingData: widget.bookingData),
                            transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
                            transitionDuration: const Duration(milliseconds: 300),
                          )),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF005F65), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)), elevation: 0),
                          child: Text('Proceed', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 15.sp, color: Colors.white)),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}