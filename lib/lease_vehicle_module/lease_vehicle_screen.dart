import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:provider/provider.dart';
import 'package:true_motors/provider/used_vehicle_provider.dart';
import 'lease_vehicle_detail_screen.dart';

class LeaseVehicleScreen extends StatefulWidget {
  const LeaseVehicleScreen({super.key});

  @override
  State<LeaseVehicleScreen> createState() => _LeaseVehicleScreenState();
}

class _LeaseVehicleScreenState extends State<LeaseVehicleScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _leasedCars = [
    {
      'name': 'Hyundai Creta',
      'location': 'Coimbatore',
      'price': '1,400',
      'leaseType': 'Monthly Lease',
      'image': 'assets/rental_screen/Hyundai Creta.png',
      'isFavorite': false,
    },
    {
      'name': 'Hyundai Creta',
      'location': 'Coimbatore',
      'price': '1,400',
      'leaseType': 'Monthly Lease',
      'image': 'assets/rental_screen/Hyundai Creta.png',
      'isFavorite': false,
    },
  ];

  int currentCardIndex = 0;
  Timer? cardTimer;

  final List<Map<String, dynamic>> infoCards = [
    {
      'title': 'Well-Maintained Car',
      'subtitle':
      'Every car is inspected & maintained to perfection. Enjoy a worry-free ride.',
      'image': 'assets/rental_screen/Well.png',
      'color': const Color(0xFFD85656),
    },
    {
      'title': 'Secure Payments',
      'subtitle':
      'Pay safely with trusted gateways. Fast, encrypted & hassle-free transactions.',
      'image': 'assets/rental_screen/Secure.png',
      'color': const Color(0xFF006C4D),
    },
    {
      'title': '24/7 Support',
      'subtitle':
      'Lease worry-free with our nonstop support team. We\'ve got your back 24/7.',
      'image': 'assets/rental_screen/Support.png',
      'color': const Color(0xFF20529D),
    },
  ];

  void startCardTimer() {
    cardTimer = Timer.periodic(
      const Duration(seconds: 3),
          (_) {
        setState(() {
          currentCardIndex = (currentCardIndex + 1) % infoCards.length;
        });
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UsedVehicleProvider>().fetchUsedVehicleCategories();
    });
    startCardTimer();
  }

  @override
  void dispose() {
    cardTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F2F2),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              height: statusBarHeight, color: Colors.transparent,
            ),

            // ── AppBar ────────────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back,
                        color: const Color(0xFF01422D), size: 24.r),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Lease Vehicle',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF01422D),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopBanner(),
                    SizedBox(height: 16.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        'Lease Vehicle By Truemotors',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),

                    SizedBox(height: 12.h),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Container(
                        height: 46.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: const Color(0xFF01422D)),
                        ),
                        child: Row(
                          children: [
                            SizedBox(width: 12.w),
                            Icon(Icons.search,
                                color: const Color(0xFF5F6368), size: 20.r),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                cursorColor: const Color(0xFF01422D),
                                style: TextStyle(fontSize: 14.sp),
                                decoration: InputDecoration(
                                  hintText: 'Look for your favorite vehicle',
                                  hintStyle: TextStyle(
                                    color: const Color(0xFF000000),
                                    fontSize: 13.5.sp,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    Center(
                      child: Text(
                        'Or choose a category',
                        style: TextStyle(
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),
                    _buildCategoryRow(),
                    SizedBox(height: 16.h),
                    _buildFilterChips(),
                    SizedBox(height: 16.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Our Hyundai leased cars ',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: '(2 Results)',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF1B21D6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 12.h),
                    ..._leasedCars.asMap().entries.map((entry) {
                      final index = entry.key;
                      final car = entry.value;
                      return _buildCarCard(car, index);
                    }),
                    Image.asset('assets/lease_image/vehicle_banner.png'),
                    SizedBox(height: 16.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) =>
                            FadeTransition(opacity: animation, child: child),
                        child: buildInfoCard(
                          key: ValueKey(currentCardIndex),
                          title: infoCards[currentCardIndex]['title'],
                          subtitle: infoCards[currentCardIndex]['subtitle'],
                          imagePath: infoCards[currentCardIndex]['image'],
                          bgColor: infoCards[currentCardIndex]['color'],
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),
                    _buildHowItWorks(),
                    SizedBox(height: 30.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBanner() {
    return Image.asset(
      'assets/lease_image/lease_banner.png',
    );
  }

  Widget _buildCategoryRow() {
    return Consumer<UsedVehicleProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(color: Color(0xFF005F65)),
          ));
        }
        if (provider.error != null) {
          return Center(child: Text('Error: ${provider.error}', style: const TextStyle(color: Colors.red)));
        }
        if (provider.categories.isEmpty) {
          return const Center(child: Text('No categories available'));
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: provider.categories.map((cat) {
              return Padding(
                padding: EdgeInsets.only(right: 16.w),
                child: Column(
                  children: [
                    Container(
                      width: 66.r,
                      height: 66.r,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x40000000),
                            offset: Offset(0, 4),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Image.network(
                          cat.image,
                          width: 50.r,
                          height: 50.r,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Icon(Icons.directions_car, color: Colors.grey, size: 30.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      cat.catName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildFilterChips() {
    final chips = ['Sort By'];
    final icons = [
      Icons.sort,
    ];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: List.generate(chips.length, (i) {
          return Padding(
            padding: EdgeInsets.only(right: i < chips.length - 1 ? 10.w : 0),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: const Color(0xFFBEBEBE)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icons[i], size: 16.r, color: const Color(0xFF9E9E9E)),
                  SizedBox(width: 4.w),
                  Text(
                    chips[i],
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCarCard(Map<String, dynamic> car, int index) {
    return Container(
      margin: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFB5B4B4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                BorderRadius.vertical(top: Radius.circular(10.r)),
                child: Image.asset(
                  car['image'],
                  width: double.infinity,
                  height: 165.h,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 160.h,
                    color: const Color(0xFFEEEEEE),
                    child: Center(
                      child: Icon(Icons.directions_car,
                          size: 60.r, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10.h,
                right: 10.w,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _leasedCars[index]['isFavorite'] =
                      !_leasedCars[index]['isFavorite'];
                    });
                  },
                  child: Container(
                    width: 24.r,
                    height: 24.r,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF2F2F2),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2))
                      ],
                    ),
                    child: Icon(
                      car['isFavorite']
                          ? Icons.favorite
                          : Icons.favorite_border,
                      size: 14.r,
                      color: car['isFavorite']
                          ? const Color(0xFFBE000C)
                          : const Color(0xFF882B2B),
                    ),
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        car['name'],
                        style: TextStyle(
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Image.asset(
                            'assets/lease_image/location.png',
                            width: 20.r,
                            height: 20.r,
                          ),
                          SizedBox(width: 5.w),
                          Text(
                            car['location'],
                            style: TextStyle(
                              fontSize: 13.5.sp,
                              color: const Color(0xFF003399),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEBBBB),
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                        child: Text(
                          car['leaseType'],
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            color: const Color(0xFF003399),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.currency_rupee,
                            size: 16.r, color: Colors.black),
                        Text(
                          car['price'],
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          '/Day',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF000000),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                LeaseVehicleDetailScreen(car: car),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 7.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF01422D),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          'Lease Details',
                          style: TextStyle(
                            fontSize: 13.sp,
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
        ],
      ),
    );
  }

  Widget buildInfoCard({
    required Key key,
    required String title,
    required String subtitle,
    required String imagePath,
    required Color bgColor,
  }) {
    return Container(
      key: key,
      width: double.infinity,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Image.asset(
            imagePath,
            width: 70.r,
            height: 70.r,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Icon(
              Icons.directions_car,
              color: Colors.white,
              size: 50.r,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorks() {
    final steps = [
      'Choose Vehicle: Browse available Vehicle',
      'Select Duration: Pick your Lease period.',
      'Book & Pay: Confirm your booking securely.',
      'Pickup/Delivery: Get your vehicle at your doorstep or pick it up at our hub.',
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How Its Work',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF14006C),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Step By Step to Lease vehicle on platform',
            style: TextStyle(fontSize: 13.5.sp, color: Colors.black),
          ),
          SizedBox(height: 10.h),
          ...steps.asMap().entries.map((e) => Padding(
            padding: EdgeInsets.only(left: 8.w, bottom: 6.h),
            child: Text(
              '${e.key + 1}. ${e.value}',
              style: TextStyle(
                  fontSize: 13.5.sp, color: Colors.black, height: 1.6),
            ),
          )),
        ],
      ),
    );
  }
}