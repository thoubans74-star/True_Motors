import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'rental_booking_model.dart';
import 'rental_page_screen.dart';
import 'rental_page3_screen.dart';

class RentalPage2Screen extends StatefulWidget {
  final RentalBookingData bookingData;
  const RentalPage2Screen({super.key, required this.bookingData});

  @override
  State<RentalPage2Screen> createState() => _RentalPage2ScreenState();
}

class _RentalPage2ScreenState extends State<RentalPage2Screen> {
  int currentCardIndex = 0;
  Timer? cardTimer;

  final List<Map<String, dynamic>> infoCards = [
    {'title': 'Well-Maintained Car', 'subtitle': 'Every car is inspected & maintained to perfection. Enjoy a worry-free ride.', 'image': 'assets/rental_screen/Well.png', 'color': const Color(0xFFD85656)},
    {'title': 'Secure Payments', 'subtitle': 'Pay safely with trusted gateways. Fast, encrypted & hassle-free transactions.', 'image': 'assets/rental_screen/Secure.png', 'color': const Color(0xFF005F65)},
    {'title': '24/7 Support', 'subtitle': 'Ride worry-free with our nonstop support team. We\'ve got your back, 24/7.', 'image': 'assets/rental_screen/Support.png', 'color': const Color(0xFF1A3A6B)},
  ];

  final List<String> filterChips = ['Filter', 'Body Type', 'Fuel Type', 'Transmission Types', 'Fuel Plan'];

  final List<Map<String, String>> howItWorks = [
    {'step': '1', 'text': 'Choose Vehicle: Browse available cars & bikes.'},
    {'step': '2', 'text': 'Select Duration: Pick your rental period.'},
    {'step': '3', 'text': 'Book & Pay: Confirm your booking securely.'},
    {'step': '4', 'text': 'Pickup/Delivery: Get your vehicle at your doorstep or pick it up at our hub.'},
  ];

  // Only ONE car in the list per requirement
  final List<Map<String, String>> carList = [
    {'image': 'assets/rental_screen/Hyundai Creta.png', 'name': 'Hyundai Creta', 'price': '1,400/Day', 'rating': '4.5/5', 'location': 'Coimbatore'},
  ];

  @override
  void initState() {
    super.initState();
    startCardTimer();
  }

  void startCardTimer() {
    cardTimer = Timer.periodic(const Duration(milliseconds: 3000), (_) {
      setState(() => currentCardIndex = (currentCardIndex + 1) % infoCards.length);
    });
  }

  @override
  void dispose() {
    cardTimer?.cancel();
    super.dispose();
  }

  // Go back to RentalPageScreen pre-filled with current data for editing
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
        backgroundColor: const Color(0xFFF5F5F5),
        body: Column(
          children: [
            Container(width: double.infinity, height: statusBarHeight, color: Colors.transparent),
            Container(
              width: double.infinity, color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
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
                    SizedBox(height: 12.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text('Rental Vehicle By Truemotors',
                          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 16.sp, color: const Color(0xFF000000))),
                    ),
                    SizedBox(height: 10.h),

                    // ── Booking Summary (from RentalPageScreen data) ──────
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white, borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: const Color(0xFFB5B4B4)),
                        ),
                        padding: EdgeInsets.all(14.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text('Car Name : ${widget.bookingData.carName}',
                                      style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: 13.5.sp, color: const Color(0xFF000000))),
                                ),
                                GestureDetector(
                                  onTap: _goBackToEdit,
                                  child: Row(children: [
                                    Image.asset('assets/rental_screen/Edit.png', width: 14.r, height: 14.r,
                                        errorBuilder: (_, __, ___) => Icon(Icons.edit_outlined, size: 14.r, color: const Color(0xFF005F65))),
                                    SizedBox(width: 4.w),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('Edit', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 12.sp, color: const Color(0xFF01422D))),
                                        Container(height: 1, width: 24.w, color: const Color(0xFF01422D)),
                                      ],
                                    ),
                                  ]),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text('Pickup Date & Time', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: 13.5.sp, color: const Color(0xFF000000))),
                                    SizedBox(height: 2.h),
                                    Text(widget.bookingData.pickupDate, style: TextStyle(fontFamily: 'Poppins', fontSize: 11.5.sp, fontWeight: FontWeight.w500, color: const Color(0xFF3C3C3C))),
                                  ]),
                                ),
                                Expanded(
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text('Return Date & Time', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: 13.5.sp, color: const Color(0xFF000000))),
                                    SizedBox(height: 2.h),
                                    Text(widget.bookingData.returnDate, style: TextStyle(fontFamily: 'Poppins', fontSize: 11.5.sp, fontWeight: FontWeight.w500, color: const Color(0xFF3C3C3C))),
                                  ]),
                                ),
                              ],
                            ),
                            SizedBox(height: 6.h),
                            Text('Location', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: 13.5.sp, color: const Color(0xFF000000))),
                            SizedBox(height: 2.h),
                            Text(widget.bookingData.location, style: TextStyle(fontFamily: 'Poppins', fontSize: 11.5.sp, fontWeight: FontWeight.w500, color: const Color(0xFF333333))),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 12.h),

                    // ── Filter Chips (horizontal scroll) ──────────────────
                    SizedBox(
                      height: 44.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        clipBehavior: Clip.hardEdge,
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                        itemCount: filterChips.length,
                        separatorBuilder: (_, __) => SizedBox(width: 10.w),
                        itemBuilder: (context, index) {
                          final bool isFilter = index == 0;
                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: Colors.white, borderRadius: BorderRadius.circular(14.r),
                              border: Border.all(color: const Color(0xFFE0E0E0)),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 1))],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (isFilter) ...[
                                  Image.asset('assets/rental_screen/Filter.png', width: 16.r, height: 16.r,
                                      errorBuilder: (_, __, ___) => Icon(Icons.filter_list, size: 16.r, color: const Color(0xFF333333))),
                                  SizedBox(width: 6.w),
                                ],
                                Text(filterChips[index], style: TextStyle(fontFamily: 'Poppins', fontSize: 12.5.sp, color: const Color(0xFF333333)), overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    SizedBox(height: 12.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text('03 Car Available in your Location',
                          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 14.sp, color: const Color(0xFF000000))),
                    ),
                    SizedBox(height: 10.h),

                    // ── ONE car card only ─────────────────────────────────
                    ...carList.map((car) => Padding(
                      padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 12.h),
                      child: buildCarCard(car),
                    )),

                    SizedBox(height: 4.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
                        child: buildInfoCard(
                          key: ValueKey(currentCardIndex),
                          title: infoCards[currentCardIndex]['title'],
                          subtitle: infoCards[currentCardIndex]['subtitle'],
                          imagePath: infoCards[currentCardIndex]['image'],
                          bgColor: infoCards[currentCardIndex]['color'],
                        ),
                      ),
                    ),
                    SizedBox(height: 15.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('How Its Work', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w400, fontSize: 16.sp, color: const Color(0xFF14006C))),
                          SizedBox(height: 4.h),
                          Text('Step By Step to Renta vehicle on platform', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w400, fontSize: 13.5.sp, color: const Color(0xFF000000))),
                          SizedBox(height: 12.h),
                          ...howItWorks.map((item) => Padding(
                            padding: EdgeInsets.only(bottom: 10.h),
                            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('${item['step']}. ', style: TextStyle(fontFamily: 'Poppins', fontSize: 13.5.sp, color: const Color(0xFF000000), fontWeight: FontWeight.w400)),
                              Expanded(child: Text(item['text']!, style: TextStyle(fontFamily: 'Poppins', fontSize: 13.5.sp, color: const Color(0xFF000000)))),
                            ]),
                          )),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Center(child: Text('Explore Our Collection Cars', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 14.sp, color: const Color(0xFF000000)), textAlign: TextAlign.center)),
                    SizedBox(height: 12.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white, borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 4, offset: const Offset(0, 3))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                              child: Image.asset('assets/rental_screen/Hyundai.png', width: double.infinity, height: 160.h, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(height: 160.h, color: const Color(0xFFF0F0F0), child: Center(child: Icon(Icons.directions_car, size: 60.r, color: Colors.grey)))),
                            ),
                            Padding(
                              padding: EdgeInsets.all(14.w),
                              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text('Hyundai Grand\ni10 Nios sportz', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: 13.5.sp, color: const Color(0xFF000000))),
                                  SizedBox(height: 6.h),
                                  Row(children: [
                                    Image.asset('assets/rental_screen/Location.png', width: 20.r, height: 20.r, errorBuilder: (_, __, ___) => Icon(Icons.location_on, size: 20.r, color: const Color(0xFF003399))),
                                    SizedBox(width: 4.w),
                                    Text('Coimbatore', style: TextStyle(fontFamily: 'Poppins', fontSize: 11.5.sp, color: const Color(0xFF003399))),
                                  ]),
                                ])),
                                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Row(children: [
                                    Image.asset('assets/rental_screen/Money.png', width: 18.r, height: 18.r, errorBuilder: (_, __, ___) => Icon(Icons.currency_rupee, size: 14.r, color: const Color(0xFF003399))),
                                    SizedBox(width: 1.w),
                                    Text('1400/day', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 13.5.sp, color: const Color(0xFF003399))),
                                  ]),
                                  SizedBox(height: 10.h),
                                  Padding(padding: EdgeInsets.only(left: 33.w), child: Text('4.5/5', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 11.5.sp, color: const Color(0xFF000000)))),
                                ]),
                              ]),
                            ),
                          ],
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

  Widget buildCarCard(Map<String, String> car) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10.r), border: Border.all(color: const Color(0xFFB5B4B4))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(10.r)),
            child: Image.asset(car['image']!, width: double.infinity, height: 160.h, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(height: 160.h, color: const Color(0xFFF0F0F0), child: Center(child: Icon(Icons.directions_car, size: 60.r, color: Colors.grey)))),
          ),
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(car['name']!, style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: 13.5.sp, color: const Color(0xFF000000))),
                    SizedBox(height: 4.h),
                    Row(children: [
                      Image.asset('assets/rental_screen/Star.png', width: 18.r, height: 18.r, errorBuilder: (_, __, ___) => Icon(Icons.star, size: 18.r, color: Colors.amber)),
                      SizedBox(width: 4.w),
                      Text(car['rating']!, style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 11.5.sp, color: const Color(0xFF333333))),
                    ]),
                    SizedBox(height: 4.h),
                    Row(children: [
                      Image.asset('assets/rental_screen/Location.png', width: 20.r, height: 20.r, errorBuilder: (_, __, ___) => Icon(Icons.location_on, size: 20.r, color: const Color(0xFF003399))),
                      SizedBox(width: 4.w),
                      Text(car['location']!, style: TextStyle(fontFamily: 'Poppins', fontSize: 11.5.sp, color: const Color(0xFF003399))),
                    ]),
                  ]),
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Image.asset('assets/rental_screen/Money.png', width: 20.r, height: 20.r, errorBuilder: (_, __, ___) => Icon(Icons.currency_rupee, size: 20.r, color: const Color(0xFF000000))),
                    SizedBox(width: 2.w),
                    Text(car['price']!, style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 13.5.sp, color: const Color(0xFF000000))),
                  ]),
                  SizedBox(height: 8.h),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, PageRouteBuilder(
                        pageBuilder: (_, anim, __) => RentalPage3Screen(bookingData: widget.bookingData),
                        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
                        transitionDuration: const Duration(milliseconds: 300),
                      ));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF01422D), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                      padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 4.h), elevation: 0, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text('Book Now', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 12.5.sp, color: Colors.white)),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoCard({required Key key, required String title, required String subtitle, required String imagePath, required Color bgColor}) {
    return Container(key: key, width: double.infinity, decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12.r)), padding: EdgeInsets.all(16.w),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 18.sp, color: Colors.white)),
          SizedBox(height: 6.h),
          Text(subtitle, style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w400, fontSize: 14.sp, color: Colors.white, height: 1.4)),
        ])),
        SizedBox(width: 12.w),
        Image.asset(imagePath, width: 70.r, height: 70.r, fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Icon(Icons.directions_car, color: Colors.white, size: 50.r)),
      ]),
    );
  }
}