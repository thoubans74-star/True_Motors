import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:true_motors/lease_module/vehicle_details_screen.dart';

class SelectVehicleTypeScreen extends StatefulWidget {
  const SelectVehicleTypeScreen({super.key});

  @override
  State<SelectVehicleTypeScreen> createState() =>
      _SelectVehicleTypeScreenState();
}

class _SelectVehicleTypeScreenState extends State<SelectVehicleTypeScreen> {
  String? _selectedType;

  final List<Map<String, dynamic>> _vehicleTypes = [
    {
      'type': 'Car',
      'subtitle': 'Four Wheeler Vehicle',
      'image': 'assets/home_image/suv.png',
    },
    {
      'type': 'Van',
      'subtitle': 'Passengers & Cargo Vans',
      'image': 'assets/buy_image/van.png',
    },
    {
      'type': 'Truck',
      'subtitle': 'Commercial Trucks',
      'image': 'assets/buy_image/commercial.png',
    },
    {
      'type': 'Backhoe / Loader',
      'subtitle': 'Construction Vehicles',
      'image': 'assets/buy_image/backhoe.png',
    },
  ];

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
              height: statusBarHeight, color: Colors.transparent,
            ),
            Expanded(
              child: Column(
                children: [
                  _buildAppBar(context),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Vehicle Type',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF01422D),
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            'Choose the type of vehicle you want to Lease',
                            style: TextStyle(
                              fontSize: 13.5.sp,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 18.h),
                          Column(
                            children: List.generate(_vehicleTypes.length, (index) {
                              final item = _vehicleTypes[index];
                              final isSelected = _selectedType == item['type'];

                              return Padding(
                                padding: EdgeInsets.only(bottom: 14.h),
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedType = item['type']),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16.w, vertical: 14.h),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10.r),
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFF005F65)
                                            : const Color(0xFFB4B4B4),
                                        width: isSelected ? 1.2 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          item['image'],
                                          width: 65.w,
                                          height: 46.h,
                                          fit: BoxFit.contain,
                                        ),
                                        SizedBox(width: 16.w),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item['type'] as String,
                                                style: TextStyle(
                                                  fontSize: 15.sp,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              SizedBox(height: 3.h),
                                              Text(
                                                item['subtitle'] as String,
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color: const Color(0xFF989898),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                          const Spacer(),
                          Center(
                            child: SizedBox(
                              width: 280.w,
                              height: 46.h,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_selectedType == null) return;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => VehicleDetailsScreen(
                                        vehicleType: _selectedType!,
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF005F65),
                                  disabledBackgroundColor: const Color(0xFF005F65).withValues(alpha: 0.8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  'Save & Next',
                                  style: TextStyle(
                                    fontSize: 15.sp,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back,
              size: 24.r,
              color: const Color(0xFF01422D),
            ),
          ),
          SizedBox(width: 16.w),
          Text(
            'Add New Vehicle',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF01422D),
            ),
          ),
        ],
      ),
    );
  }
}

