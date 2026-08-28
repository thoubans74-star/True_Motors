import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:true_motors/service_vehicle_module/terms_conditions.dart';

class BookingSummeryScreen extends StatelessWidget {
  const BookingSummeryScreen({super.key});

  static const String vehicleName = 'Hyundai Creta (Petrol)';
  static const String servicesSelected = 'General Service, AC Repair';
  static const String pickupAddress = '123, Main Road, Chennai';
  static const String scheduledTime = 'Aug 3, 2025 | 10:00 AM';
  static const String specialInstructions = 'Kindly call before arriving.';

  static const List<String> faqList = [
    'How long does it take to service vehicle?',
    'How long does it take to service vehicle?',
    'How long does it take to service vehicle?',
    'How long does it take to service vehicle?',
  ];

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final horizontalPadding = width * 0.055;
    final scale = width / 360.0;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F2F2),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              height: statusBarHeight, color: Colors.transparent,
            ),
            Container(
              width: double.infinity,
              height: 52.h,
              color: Colors.white,
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
                  SizedBox(width: 15.w),
                  Text(
                    'Booking Summery',
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
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    SizedBox(
                      width: double.infinity,
                      height: 173 * scale,
                      child: Image.asset(
                        'assets/confirm_booking/Booking.png',
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFF1B6B5A),
                          child: const Center(
                            child: Icon(Icons.car_repair,
                                color: Colors.white, size: 48),
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding),
                      child: Column(
                        children: [
                          SizedBox(height: height * 0.02),
                          const Center(
                            child: Text(
                              'Service Booking Confirmed',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                                fontSize: 20,
                                color: Color(0xFF258C00),
                                height: 1.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          SizedBox(height: height * 0.01),
                          const Center(
                            child: Text(
                              'Our executive will contact you shortly.',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: Color(0xFF0D00C0),
                                height: 1.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: height * 0.02),
                        ],
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Booking Summery',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: Color(0xFF000000),
                              ),
                            ),
                            SizedBox(height: height * 0.01,),

                            buildDetailRow(
                                '🚗', 'Vehicle', vehicleName),
                            buildDetailRow(
                                '🔧', 'Services Selected', servicesSelected),
                            buildDetailRow(
                                '📍', 'Pickup', pickupAddress),
                            buildDetailRow(
                                '📅', 'Scheduled', scheduledTime),

                            RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: Color(0xFF000000),
                                  height: 2.14,
                                ),
                                children: [
                                  TextSpan(
                                      text: 'Special Instructions : '),
                                  TextSpan(
                                      text:
                                          'Kindly call before arriving.'),
                                ],
                              ),
                            ),

                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Text(
                                  'View Your Booking',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    color: Color(0xFF24107E),
                                    height: 1.0,
                                  ),
                                ),
                                SizedBox(width: width * 0.015),
                                Icon(Icons.arrow_forward,
                                  size: 16,
                                  color: Color(0xFF24107E),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: height * 0.015),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding),
                      child: GestureDetector(
                        onTap: (){
                          Navigator.push(context,
                            MaterialPageRoute(builder: (context) => TermsCondition())
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          height: 35,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Color(0xFFD59090),
                                Color(0xFFDF7B7B),
                              ],
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0D000000),
                                blurRadius: 4,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'Terms & Conditions For Service Vehicle',
                              style: TextStyle(
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: height * 0.015,),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: const Color(0xFFE2E2E2)),
                        ),
                        child: Column(
                          children: [
                            // FAQ Heading
                            const Padding(
                              padding:
                                  EdgeInsets.fromLTRB(16, 12, 16, 6),
                              child: Text(
                                'Frequently Asked Questions',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: Color(0xFF000000),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),


                            ...List.generate(faqList.length, (index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 4),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${index + 1}. ${faqList[index]}',
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                        color: Color(0xFF000000),
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                    Icon(
                                      Icons.keyboard_arrow_down,
                                      size: 24,
                                      color: Color(0xFF3C3C3C),
                                    ),
                                  ],
                                ),
                              );
                            }),

                            SizedBox(height: height * 0.01,)
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: height * 0.05,)
                  ],
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
      padding: const EdgeInsets.only(bottom: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$emoji ',
            style: const TextStyle(
              fontSize: 14,
              height: 2.14,
            ),
          ),
          Expanded(
            child: Text(
              '$label : $value',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Color(0xFF000000),
                height: 2.14,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}