import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'rental_booking_model.dart';
import 'android_large_screen.dart';

class PaymentOptionsScreen extends StatefulWidget {
  final RentalBookingData bookingData;
  const PaymentOptionsScreen({super.key, required this.bookingData});

  @override
  State<PaymentOptionsScreen> createState() => _PaymentOptionsScreenState();
}

class _PaymentOptionsScreenState extends State<PaymentOptionsScreen> {
  int currentImageIndex = 0;
  Timer? imageTimer;
  final PageController imagePageController = PageController();

  @override
  void dispose() {
    imageTimer?.cancel();
    imagePageController.dispose();
    super.dispose();
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
                Text('Payment', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: 18.sp, color: const Color(0xFF01422D))),
              ]),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(height: 10.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Container(
                      width: double.infinity, padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.r)),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Text("Pay", style: TextStyle(fontSize: 22.sp, fontFamily: 'Inter', color: Colors.black, fontWeight: FontWeight.w500)),
                          SizedBox(width: 15.w),
                          Text("₹", style: TextStyle(fontSize: 19.sp, color: Colors.grey, fontWeight: FontWeight.bold)),
                          SizedBox(width: 6.w),
                          Text("3,650", style: TextStyle(fontSize: 18.sp, fontFamily: 'Inter', fontWeight: FontWeight.w500)),
                        ]),
                        SizedBox(height: 20.h),
                        Text("Pay Via UPI App", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16.sp, color: Colors.black)),
                      ]),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(color: const Color(0xFFF2F2F2), borderRadius: BorderRadius.circular(8.r), border: Border.all(color: const Color(0xFF01422D))),
                      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        // GPay — navigates to success page
                        GestureDetector(
                          onTap: () => Navigator.push(context, PageRouteBuilder(
                            pageBuilder: (_, anim, __) => const AndroidLargeScreen(),
                            transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
                            transitionDuration: const Duration(milliseconds: 300),
                          )),
                          child: Row(children: [
                            Image.asset('assets/rental_screen/Gpay.png', width: 24.r, height: 24.r, fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Icon(Icons.g_mobiledata, size: 24.r, color: const Color(0xFF555555))),
                            SizedBox(width: 14.w),
                            Text('GPay', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500, fontSize: 14.5.sp, color: const Color(0xFF000000))),
                          ]),
                        ),
                        SizedBox(height: 20.h),
                        buildPaymentRow(imagePath: 'assets/rental_screen/Phonepay.png', label: 'Phone Pe'),
                        SizedBox(height: 20.h),
                        buildPaymentRow(imagePath: 'assets/rental_screen/Paytm.png', label: 'Paytm'),
                      ]),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 16.w), child: Text('Cards', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: 16.sp, color: const Color(0xFF000000)))),
                  SizedBox(height: 10.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(color: const Color(0xFFF2F2F2), borderRadius: BorderRadius.circular(8.r), border: Border.all(color: const Color(0xFF01422D))),
                      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
                      child: buildPaymentRow(imagePath: 'assets/rental_screen/card.png', label: 'Credit, Debit & ATM cards'),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 16.w), child: Text('More Payment Options', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: 16.sp, color: const Color(0xFF000000)))),
                  SizedBox(height: 10.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r), border: Border.all(color: const Color(0xFF01422D))),
                      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        buildPaymentRow(imagePath: 'assets/rental_screen/Cash.png', label: 'Cash on Pick up'),
                        SizedBox(height: 20.h),
                        buildPaymentRow(imagePath: 'assets/rental_screen/Net.png', label: 'Net Banking'),
                      ]),
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

  Widget buildPaymentRow({required String imagePath, required String label}) {
    return GestureDetector(
      onTap: () {},
      child: Row(children: [
        Image.asset(imagePath, width: 24.r, height: 24.r, fit: BoxFit.contain, errorBuilder: (_, __, ___) => SizedBox(width: 24.r, height: 24.r)),
        SizedBox(width: 14.w),
        Text(label, style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500, fontSize: 14.5.sp, color: const Color(0xFF000000))),
      ]),
    );
  }
}