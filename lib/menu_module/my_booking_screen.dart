import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:shared_preferences/shared_preferences.dart';

class MyBookingScreen extends StatefulWidget {
  const MyBookingScreen({super.key});

  @override
  State<MyBookingScreen> createState() => _MyBookingScreenState();
}

class _MyBookingScreenState extends State<MyBookingScreen> {
  int _selectedTab = 0; // 0 = Rental Vehicle, 1 = Service Vehicle

  List<Map<String, String>> _rentalBookings = [];
  bool _isLoading = true;

  final List<String> _sortChips = [
    'Sort by',
    'Booking Status',
    'Vehicle Type',
    'Rental Type',
    'Date Range',
  ];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    final prefs = await SharedPreferences.getInstance();

    // ── Clear bookings on every fresh app session ─────────────────────────
    // We use a session flag stored in memory (not prefs) to detect restarts.
    // On first load each session, clear the saved list so it starts empty.
    final bool sessionStarted = _sessionStarted;
    if (!sessionStarted) {
      await prefs.remove('my_rental_bookings');
      _sessionStarted = true;
    }

    final List<String> raw =
        prefs.getStringList('my_rental_bookings') ?? [];
    setState(() {
      _rentalBookings = raw.map((e) {
        final decoded = jsonDecode(e);
        return Map<String, String>.from(decoded as Map);
      }).toList();
      _isLoading = false;
    });
  }

  // Static flag lives only in memory — resets to false on every app restart
  static bool _sessionStarted = false;

  // ── Sample service bookings (static placeholder) ──────────────────────────
  final List<Map<String, String>> _serviceBookings = [
    {
      'carName': 'Tata Nexon',
      'service': 'General Service',
      'pickup': 'Yes',
      'serviceDate': 'Aug 05, 2025',
      'workshop': 'ABC Auto Care',
      'bookingId': '#TRMS12345',
      'status': 'Completed',
      'image': 'assets/rental_screen/Hyundai Creta.png',
    },
    {
      'carName': 'Tata Nexon',
      'service': 'General Service',
      'pickup': 'Yes',
      'serviceDate': 'Aug 05, 2025',
      'workshop': 'ABC Auto Care',
      'bookingId': '#TRMS12345',
      'status': 'Completed',
      'image': 'assets/rental_screen/Hyundai Creta.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              height: statusBarHeight,
              color: Colors.white,
            ),

            // ── AppBar ────────────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(
                  horizontal: 16.w, vertical: 14.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back,
                        color: const Color(0xFF01422D), size: 24.r),
                  ),
                  SizedBox(width: 14.w),
                  Text(
                    'My Booking',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      fontSize: 18.sp,
                      color: const Color(0xFF01422D),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(
                  child: CircularProgressIndicator(
                      color: Color(0xFF005F65)))
                  : SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Rent Now Banner ───────────────────────────
                    _buildRentBanner(),

                    SizedBox(height: 14.h),

                    // ── "My Booking" heading ──────────────────────
                    Padding(
                      padding:
                      EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        'My Booking',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                          color: const Color(0xFF000000),
                        ),
                      ),
                    ),

                    SizedBox(height: 12.h),

                    // ── Tabs ──────────────────────────────────────
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Row(
                        children: [
                          Expanded(child: _buildTab('Rental Vehicle', 0)),
                          SizedBox(width: 16.w),
                          Expanded(child: _buildTab('Service Vehicle', 1)),
                        ],
                      ),
                    ),

                    SizedBox(height: 12.h),

                    // ── Sort / Filter chips ───────────────────────
                    Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 8.h),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(
                              color: Color(0xFFB2A8A8)),
                          bottom: BorderSide(
                              color: Color(0xFFB2A8A8)),
                        ),
                      ),
                      child: SizedBox(
                        height: 50.h,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 8.h),
                          itemCount: _sortChips.length,
                          separatorBuilder: (_, __) =>
                          SizedBox(width: 8.w),
                          itemBuilder: (context, index) {
                            final bool isSort = index == 0;
                            return Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 14.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                BorderRadius.circular(6.r),
                                border: Border.all(
                                    color:
                                    const Color(0xFF005F65)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isSort) ...[
                                    Icon(Icons.sort,
                                        size: 14.r,
                                        color:
                                        const Color(0xFF434343)),
                                    SizedBox(width: 4.w),
                                  ],
                                  Text(
                                    _sortChips[index],
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF000000),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    SizedBox(height: 12.h),

                    // ── Booking list ──────────────────────────────
                    if (_selectedTab == 0)
                      _rentalBookings.isEmpty
                          ? _buildEmptyState(
                          'No rental bookings yet.\nBook a vehicle to see it here.')
                          : Column(
                        children: _rentalBookings
                            .map((b) =>
                            _buildRentalCard(b))
                            .toList(),
                      )
                    else
                      Column(
                        children: _serviceBookings
                            .map((b) => _buildServiceCard(b))
                            .toList(),
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

  // ── Tab button ─────────────────────────────────────────────────────────────
  Widget _buildTab(String label, int index) {
    final bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF005F65)
              : const Color(0xFFE5E3E3),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF005F65)
                : const Color(0xFFCECECE),
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : const Color(0xFF000000),
            ),
          ),
        ),
      ),
    );
  }

  // ── Rent Now Banner ────────────────────────────────────────────────────────
  Widget _buildRentBanner() {
    return SizedBox(
      height: 140.h,
      width: double.infinity,
      child: Image.asset(
        'assets/home_image/rent_banner.png',
        fit: BoxFit.cover,
      ),
    );
  }

  // ── Rental booking card — Figma layout ────────────────────────────────────
  Widget _buildRentalCard(Map<String, String> booking) {
    return Container(
      margin: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFDED3D3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/my_booking/hyundai_sandro.png',
            width: 130.w,
            height: 130.h,
            fit: BoxFit.contain,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: 4.w, right: 14.w, top: 10.h, bottom: 10.h,),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking['carName'] ?? 'Hyundai Santro MT',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 14.5.sp,
                      color: const Color(0xFF000000),
                    ),
                  ),
                  SizedBox(height: 6.h),

                  Row(
                    children: [
                      _specChip(
                          'assets/my_booking/petrol.png', 'Petrol'),
                      SizedBox(width: 10.w),
                      _specChip(
                          'assets/my_booking/manual.png', 'Manual'),
                    ],
                  ),
                  SizedBox(height: 4.h),

                  Text(
                    '438 kms included, Without fuel',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12.sp,
                      color: const Color(0xFF000000),
                    ),
                  ),

                  Row(
                    children: [
                      Text(
                        'Extra Kms @ ',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11.5.sp,
                          color: const Color(0xFF000000),
                        ),
                      ),
                      Icon(Icons.currency_rupee,
                          size: 11.r, color: const Color(0xFF5F6368)),
                      Text(
                        ' 20/Km',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11.5.sp,
                          color: const Color(0xFF000000),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10.h),

                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF005F65),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          'View Details',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
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

  // ── Service booking card ───────────────────────────────────────────────────
  Widget _buildServiceCard(Map<String, String> booking) {
    return Container(
      margin: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFDED3D3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset('assets/my_booking/tata_nexon.png',
            width: 135.w,
            height: 130.h,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Container(
              width: 110.w,
              height: 120.h,
              color: const Color(0xFFEEEEEE),
              child: Icon(Icons.directions_car,
                  color: Colors.grey, size: 36.r),
            ),
          ),

          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                top: 10.h, bottom: 10.h, left: 0, right: 14.w,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking['carName'] ?? '',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      color: const Color(0xFF000000),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Service Date: ${booking['serviceDate'] ?? ''}',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12.sp,
                        color: const Color(0xFF000000)),
                  ),
                  Text(
                    'Workshop: ${booking['workshop'] ?? ''}',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12.sp,
                        color: const Color(0xFF000000)),
                  ),
                  Text(
                    'Booking ID: ${booking['bookingId'] ?? ''}',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12.sp,
                        color: const Color(0xFF000000)),
                  ),
                  Text(
                    'Status: Completed',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12.sp,
                        color: const Color(0xFF29A702)),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      const Spacer(),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 14.w, vertical: 5.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF005F65),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            'View Details',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Widget _specChip(String imagePath, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          imagePath,
          width: 14.r,
          height: 14.r,
          errorBuilder: (_, __, ___) => Icon(
              Icons.circle,
              size: 12.r,
              color: const Color(0xFF555555)),
        ),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12.sp,
            color: const Color(0xFF000000),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding:
      EdgeInsets.symmetric(vertical: 40.h, horizontal: 32.w),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.directions_car_outlined,
                size: 56.r, color: const Color(0xFFB2A8A8)),
            SizedBox(height: 14.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13.5.sp,
                color: const Color(0xFFB2A8A8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}