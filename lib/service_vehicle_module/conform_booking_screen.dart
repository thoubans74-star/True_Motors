import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:true_motors/service_vehicle_module/booking_summery_screen.dart';

class ConformBookingScreen extends StatefulWidget {
  final String vehicleName;
  final int? vehicleId;
  final String servicesSelected;
  final String pickupAddress;
  final String specialInstructions;

  const ConformBookingScreen({
    super.key,
    required this.vehicleName,
    this.vehicleId,
    required this.servicesSelected,
    required this.pickupAddress,
    required this.specialInstructions,
  });

  @override
  State<ConformBookingScreen> createState() => _ConformBookingScreenState();
}

class _ConformBookingScreenState extends State<ConformBookingScreen> {

  int currentVehicleIndex = 0;
  Timer? vehicleTimer;

  final List<String> vehicleSlides = [
    'assets/vehicle_service/Bike.png',
    'assets/vehicle_service/Car.png',
    'assets/vehicle_service/Commercial Vehicle.png',
    'assets/vehicle_service/Tractor.png',
  ];

  final List<String> faqList = [
    'How long does it take to service vehicle?',
    'How long does it take to service vehicle?',
    'How long does it take to service vehicle?',
    'How long does it take to service vehicle?',
  ];

  String get vehicleName => widget.vehicleName;
  String get servicesSelected => widget.servicesSelected;
  String get pickupAddress => widget.pickupAddress.isEmpty ? 'Not Provided' : widget.pickupAddress;
  String get scheduledTime => 'Aug 3, 2025 | 10:00 AM'; // Can be updated if date picker added
  String get specialInstructions => widget.specialInstructions.isEmpty ? 'None' : widget.specialInstructions;

  @override
  void initState() {
    super.initState();
    startVehicleTimer();
  }

  void startVehicleTimer() {
    vehicleTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      setState(() {
        currentVehicleIndex = (currentVehicleIndex + 1) % vehicleSlides.length;
      });
    });
  }

  @override
  void dispose() {
    vehicleTimer?.cancel();
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
        backgroundColor: const Color(0xFFF2F2F2),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              height: statusBarHeight,
              color: Colors.white,
            ),

            Container(
              width: double.infinity,
              height: 56.h,
              color: const Color(0xFFFFFFFF),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back,
                      size: 24.r,
                      color: const Color(0xFF01422D),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Text('Conform Booking',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 18.sp,
                      color: const Color(0xFF01422D),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 170.h,
                        child: Image.asset(
                          'assets/confirm_booking/Booking.png',
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFFF2F2F2),
                            child: Center(
                              child: Icon(Icons.car_repair,
                                  color: const Color(0xFF1B6B5A), size: 48.r),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 16.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Conform Service Booking',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14.sp,
                                  color: const Color(0xFF000000),
                                ),
                              ),

                              SizedBox(height: 8.h),

                              buildDetailRow(
                                  '🚗', 'Vehicle', vehicleName),
                              buildDetailRow(
                                  '🔧', 'Services Selected', servicesSelected),
                              buildDetailRow(
                                  '📍', 'Pickup', pickupAddress),
                              buildDetailRow(
                                  '📅', 'Scheduled', scheduledTime),

                              SizedBox(height: 8.h),
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 13.5.sp,
                                    color: const Color(0xFF000000),
                                    height: 1.6,
                                  ),
                                  children: const [
                                    TextSpan(
                                      text: 'Special Instructions : ',
                                    ),
                                    TextSpan(
                                      text: 'Kindly call before arriving.',
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 16.h),

                              Row(
                                children: [
                                  Expanded(
                                    flex: 165,
                                    child: SizedBox(
                                      height: 40.h,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              pageBuilder: (_, animation, __) =>
                                                  const BookingSummeryScreen(),
                                              transitionsBuilder:
                                                  (_, animation, __, child) {
                                                return FadeTransition(
                                                  opacity: animation,
                                                  child: child,
                                                );
                                              },
                                              transitionDuration: const Duration(
                                                  milliseconds: 300),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF005F65),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.r),
                                          ),
                                          elevation: 0,
                                          padding: EdgeInsets.zero,
                                        ),
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            'Conform Booking',
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13.5.sp,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10.w),

                                  Expanded(
                                    flex: 120,
                                    child: SizedBox(
                                      height: 40.h,
                                      child: ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pop(context),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF005F65),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.r),
                                          ),
                                          elevation: 0,
                                          padding: EdgeInsets.zero,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.edit_outlined,
                                                color: Colors.white,
                                                size: 14.r),
                                            SizedBox(width: 4.w),
                                            Text('Edit',
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13.5.sp,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
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

                      SizedBox(height: 16.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Text(
                                  'Why Choose Us',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14.sp,
                                    color: const Color(0xFF000000),
                                  ),
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'Our certified and trained technicians ensure that your vehicle gets the care it deserves. From routine servicing to complex repairs, your car is in safe hands.',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12.sp,
                                  color: const Color(0xFF000000),
                                ),
                              ),

                              SizedBox(height: 10.h),
                              buildWhyItem('Expert Technicians:',
                                  'Certified professionals for every service.'),
                              buildWhyItem('Genuine Parts:',
                                  'Guaranteed quality and reliability.'),
                              buildWhyItem('Transparent Pricing:',
                                  'No hidden charges, upfront estimates.'),
                              buildWhyItem('Convenience:',
                                  'Home pickup & drop for hassle-free servicing.'),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 16.h),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 16.w, bottom: 8.h),
                        child: Text(
                          'Popular Service Vehicles:',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                            fontSize: 14.sp,
                            color: const Color(0xFF000000),
                          ),
                        ),
                      ),

                      SizedBox(height: 8.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 600),
                          transitionBuilder: (child, animation) =>
                              FadeTransition(opacity: animation, child: child),
                          child: ClipRRect(
                            key: ValueKey(currentVehicleIndex),
                            borderRadius: BorderRadius.circular(10.r),
                            child: Image.asset(
                              vehicleSlides[currentVehicleIndex],
                              width: double.infinity,
                              height: 140.h,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 140.h,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFBEBE),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 16.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 6.h),
                                child: Text(
                                  'Frequently Asked Questions',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14.sp,
                                    color: const Color(0xFF000000),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                              ...List.generate(faqList.length, (index) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16.w, vertical: 6.h),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${index + 1}. ${faqList[index]}',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12.sp,
                                          color: const Color(0xFF000000),
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                      Image.asset(
                                        'assets/vehicle_service/Down Arrow.png',
                                        width: 22.r,
                                        height: 22.r,
                                        errorBuilder: (_, __, ___) =>
                                            Icon(
                                          Icons.keyboard_arrow_down,
                                          size: 22.r,
                                          color: const Color(0xFF555555),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),

                              SizedBox(height: 8.h),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 24.h),
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

  Widget buildDetailRow(String emoji, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$emoji ',
            style: TextStyle(
              fontSize: 13.5.sp,
              height: 1.5,
            ),
          ),
          Expanded(
            child: Text(
              '$label : $value',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                fontSize: 13.5.sp,
                color: const Color(0xFF000000),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildWhyItem(String title, String subtitle) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              fontFamily: 'Poppins',
              color: const Color(0xFF000000),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    fontSize: 12.sp,
                    color: const Color(0xFF000000),
                    height: 1.4,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    fontSize: 12.sp,
                    color: const Color(0xFF000000),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}