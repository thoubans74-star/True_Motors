import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:true_motors/lease_module/dashboard_screen.dart';
import 'package:true_motors/lease_module/listed_vehicles_manager.dart';
import 'package:true_motors/lease_module/select_vehicle_type_screen.dart';

class PreviewSubmitScreen extends StatelessWidget {
  final String vehicleType;
  final String brand;
  final String model;
  final String fuelType;
  final String transmission;
  final String year;
  final String kmDriven;
  final List<String> imagePaths;
  final String additionalInfo;
  final String state;
  final String city;
  final String area;
  final String rcPath;
  final String insurancePath;
  final String pollutionPath;
  final String leaseType;
  final String leaseDuration;
  final String noticePeriod;
  final String availableFrom;
  final String monthlyPrice;
  final String securityDeposit;
  final String includedKm;
  final String extraKmCharge;
  final List<String> selectedFeatures;

  const PreviewSubmitScreen({
    super.key,
    required this.vehicleType,
    required this.brand,
    required this.model,
    required this.fuelType,
    required this.transmission,
    required this.year,
    required this.kmDriven,
    required this.imagePaths,
    required this.additionalInfo,
    required this.state,
    required this.city,
    required this.area,
    required this.rcPath,
    required this.insurancePath,
    required this.pollutionPath,
    required this.leaseType,
    required this.leaseDuration,
    required this.noticePeriod,
    required this.availableFrom,
    required this.monthlyPrice,
    required this.securityDeposit,
    required this.includedKm,
    required this.extraKmCharge,
    required this.selectedFeatures,
  });

  // ── Vehicle type image asset ───────────────────────────────────────────────
  String _vehicleTypeImage() {
    switch (vehicleType.toLowerCase()) {
      case 'van':
        return 'assets/buy_image/van.png';
      case 'truck':
        return 'assets/buy_image/commercial.png';
      case 'backhoe / loader':
        return 'assets/buy_image/backhoe.png';
      case 'car':
      default:
        return 'assets/home_image/suv.png';
    }
  }

  void _onSubmit(BuildContext context) {
    // Save to manager
    ListedVehiclesManager().addVehicle(
      ListedVehicle(
        vehicleType: vehicleType,
        brand: brand,
        model: model,
        fuelType: fuelType,
        transmission: transmission,
        year: year,
        kmDriven: kmDriven,
        imagePaths: imagePaths,
        state: state,
        city: city,
        area: area,
        leaseType: leaseType,
        leaseDuration: leaseDuration,
        availableFrom: availableFrom,
        monthlyPrice: monthlyPrice,
        securityDeposit: securityDeposit,
        includedKm: includedKm,
        extraKmCharge: extraKmCharge,
        selectedFeatures: selectedFeatures,
        additionalInfo: additionalInfo,
      ),
    );

    // Show success popup
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r)),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/lease_image/thumb.png',
                width: 140.w,
                height: 140.h,
              ),
              SizedBox(height: 16.h),
              Text(
                'Vehicle Added Successfully',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF000A74),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Your vehicle has been listed for lease,\nyou will receive request from\ninterested renters soon.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5.sp,
                  color: const Color(0xFF3C3C3C),
                  height: 1.5,
                ),
              ),
              SizedBox(height: 20.h),
              // Go to my Vehicle button
              SizedBox(
                width: double.infinity,
                height: 44.h,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    // Navigate to dashboard and show My Vehicles tab
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) =>
                        const LeaseVehicleDashboardScreen(
                            initialTab: 'my_vehicles'),
                      ),
                          (route) => route.isFirst,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF005F65),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r)),
                    elevation: 0,
                  ),
                  child: Text(
                    'Go to my Vehicle',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.5.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              // Add New Vehicle button
              SizedBox(
                width: double.infinity,
                height: 44.h,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) =>
                        const SelectVehicleTypeScreen(),
                      ),
                          (route) => route.isFirst,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF005F65)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r)),
                  ),
                  child: Text(
                    'Add New Vehicle',
                    style: TextStyle(
                      color: const Color(0xFF005F65),
                      fontWeight: FontWeight.w600,
                      fontSize: 14.5.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    // Determine displayed image
    Widget vehicleImage;
    if (imagePaths.isNotEmpty) {
      vehicleImage = Image.file(
        File(imagePaths.first),
        width: 85.w,
        height: 65.h,
        fit: BoxFit.cover,
      );
    } else {
      vehicleImage = Image.asset(
        _vehicleTypeImage(),
        width: 85.w,
        height: 65.h,
        fit: BoxFit.contain,
      );
    }

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
              height: statusBarHeight, color: Colors.transparent,
            ),
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Preview & Submit',
                      style: TextStyle(
                        color: const Color(0xFF01422D),
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Please review your details before submitting',
                      style: TextStyle(fontSize: 13.sp, color: Colors.black54),
                    ),
                    SizedBox(height: 16.h),

                    // ── Vehicle card ──────────────────────────────────────
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        children: [
                          // Vehicle Info
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.r),
                                child: vehicleImage,
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$brand $model',
                                      style: TextStyle(
                                        fontSize: 15.5.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      '$kmDriven km | $fuelType | $transmission',
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: const Color(0xFF979797),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 20.h),
                          _buildDetailRow(
                            'Location',
                            '$city, $state',
                          ),
                          _buildDivider(),

                          _buildDetailRow('Lease Type', leaseType),
                          _buildDivider(),

                          _buildDetailRow(
                            'Monthly Price',
                            '₹ ${_formatAmount(monthlyPrice)}',
                          ),
                          _buildDivider(),

                          _buildDetailRow(
                            'Security Deposit',
                            '₹ ${_formatAmount(securityDeposit)}',
                          ),
                          _buildDivider(),

                          _buildDetailRow(
                            'Available From',
                            availableFrom,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 40.h),

                    // ── Edit & Submit buttons ─────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding:
                              EdgeInsets.symmetric(vertical: 12.h),
                              side: const BorderSide(
                                  color: Color(0xFF005F65)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r)),
                            ),
                            child: Text(
                              'Edit',
                              style: TextStyle(
                                color: const Color(0xFF005F65),
                                fontWeight: FontWeight.w700,
                                fontSize: 15.sp,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _onSubmit(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF005F65),
                              padding:
                              EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r)),
                              elevation: 0,
                            ),
                            child: Text(
                              'Submit',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15.sp,
                              ),
                            ),
                          ),
                        ),
                      ],
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

  // ── App bar ────────────────────────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context) {
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
          Text(
            'Add New Vehicle',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF01422D),
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13.sp,
                color: const Color(0xFF969696),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, color: Color(0xFFEEEEEE));
  }

  String _formatAmount(String raw) {
    final num? val = num.tryParse(raw);
    if (val == null) return raw;
    final str = val.toStringAsFixed(0);
    final result = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) result.write(',');
      result.write(str[i]);
      count++;
    }
    return result.toString().split('').reversed.join();
  }
}