import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:true_motors/lease_module/listed_vehicles_manager.dart';
import 'package:true_motors/lease_module/select_vehicle_type_screen.dart';

class LeaseVehicleDashboardScreen extends StatefulWidget {
  final String initialTab;

  const LeaseVehicleDashboardScreen({
    super.key,
    this.initialTab = 'dashboard',
  });

  @override
  State<LeaseVehicleDashboardScreen> createState() =>
      _LeaseVehicleDashboardScreenState();
}

class _LeaseVehicleDashboardScreenState
    extends State<LeaseVehicleDashboardScreen> {
  late String _activeTab;

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTab;
    ListedVehiclesManager().addListener(_onVehiclesUpdated);
  }

  @override
  void dispose() {
    ListedVehiclesManager().removeListener(_onVehiclesUpdated);
    super.dispose();
  }

  void _onVehiclesUpdated() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFFDFDFD),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              height: statusBarHeight, color: Colors.transparent,
            ),
            Expanded(
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    _buildAppBar(context),
                    Expanded(
                      child: _activeTab == 'my_vehicles'
                          ? _buildMyVehiclesTab(context)
                          : _buildDashboardTab(context),
                    ),
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
            child: Icon(
              Icons.arrow_back,
              size: 24.r,
              color: const Color(0xFF01422D),
            ),
          ),
          SizedBox(width: 16.w),
          Text(
            'Lease Vehicle Dashboard',
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

  // ── Dashboard tab (original content) ──────────────────────────────────────
  Widget _buildDashboardTab(BuildContext context) {
    final vehicles = ListedVehiclesManager().vehicles;
    return SingleChildScrollView(
      child: Column(
        children: [
          Image.asset('assets/lease_image/lease_banner.png'),

          // Overview Section
          Padding(
            padding:
            EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overview',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    _buildOverviewCard(
                        'My Vehicles', '${vehicles.length}'),
                    SizedBox(width: 10.w),
                    _buildOverviewCard('Active Leases', '02'),
                    SizedBox(width: 10.w),
                    _buildOverviewCard('Total Earnings', '₹1,45,000'),
                  ],
                ),
              ],
            ),
          ),

          // Quick Actions
          Padding(
            padding:
            EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 15.h),
                _buildQuickAction(
                  context,
                  icon: Icons.add_circle_outline,
                  title: 'Add New Vehicle',
                  subtitle: 'List your vehicle for lease',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const SelectVehicleTypeScreen(),
                      ),
                    );
                  },
                ),
                SizedBox(height: 15.h),
                _buildQuickAction(
                  context,
                  icon: Icons.directions_car_outlined,
                  title: 'My Vehicles',
                  subtitle: 'Manage your listed vehicles',
                  onTap: () => setState(() => _activeTab = 'my_vehicles'),
                ),
                SizedBox(height: 15.h),
                _buildQuickAction(
                  context,
                  icon: Icons.description_outlined,
                  title: 'My Leases',
                  subtitle: 'View your lease agreements',
                  onTap: () {},
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  // ── My Vehicles tab ────────────────────────────────────────────────────────
  Widget _buildMyVehiclesTab(BuildContext context) {
    final vehicles = ListedVehiclesManager().vehicles;

    if (vehicles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_car_outlined,
                size: 64.r, color: const Color(0xFFB4B4B4)),
            SizedBox(height: 16.h),
            Text(
              'No vehicles listed yet',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Add a vehicle to start leasing',
              style: TextStyle(fontSize: 13.sp, color: Colors.black38),
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SelectVehicleTypeScreen(),
                  ),
                );
              },
              icon: Icon(Icons.add, size: 20.r),
              label: Text('Add New Vehicle', style: TextStyle(fontSize: 14.sp)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF005F65),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                    horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r)),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding:
          EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Vehicles (${vehicles.length})',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SelectVehicleTypeScreen(),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Icon(Icons.add,
                        size: 18.r, color: const Color(0xFF005F65)),
                    SizedBox(width: 4.w),
                    Text(
                      'Add Vehicle',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: const Color(0xFF005F65),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: vehicles.length,
            itemBuilder: (_, index) =>
                _buildVehicleCard(vehicles[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleCard(ListedVehicle vehicle) {
    Widget imageWidget;
    if (vehicle.imagePaths.isNotEmpty) {
      imageWidget = ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.r),
          bottomLeft: Radius.circular(10.r),
        ),
        child: Image.file(
          File(vehicle.imagePaths.first),
          width: 105.w,
          height: 95.h,
          fit: BoxFit.cover,
        ),
      );
    } else {
      imageWidget = ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.r),
          bottomLeft: Radius.circular(10.r),
        ),
        child: Image.asset(
          _vehicleTypeImage(vehicle.vehicleType),
          width: 105.w,
          height: 95.h,
          fit: BoxFit.contain,
        ),
      );
    }

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          imageWidget,
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${vehicle.brand} ${vehicle.model}',
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${vehicle.kmDriven} km | ${vehicle.fuelType} | ${vehicle.transmission}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 13.r, color: Colors.black38),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          '${vehicle.city}, ${vehicle.state}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.black38,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Monthly Price',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.black38,
                            ),
                          ),
                          Text(
                            '₹ ${vehicle.monthlyPrice}',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF005F65),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF8F0),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          'Active',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: const Color(0xFF005F65),
                            fontWeight: FontWeight.w600,
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

  String _vehicleTypeImage(String vehicleType) {
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

  Widget _buildOverviewCard(String title, String value) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF2FF),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF000000),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15.5.sp,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2FF),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child:
              Icon(icon, color: const Color(0xFF0F4C81), size: 22.r),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey,
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
}