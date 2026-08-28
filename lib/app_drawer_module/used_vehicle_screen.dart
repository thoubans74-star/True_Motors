import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:true_motors/provider/used_vehicle_provider.dart';
import 'package:true_motors/used_vehicle_module/buy_car.dart';

import 'sell_vehicle_screen.dart';
import 'compare_vehicle_screen.dart';
import 'dart:async';
import 'search_screen.dart';

class UsedVehicleScreen extends StatefulWidget {
  const UsedVehicleScreen({super.key});

  @override
  State<UsedVehicleScreen> createState() => _UsedVehicleScreenState();
}

class _UsedVehicleScreenState extends State<UsedVehicleScreen> {
  final int _selectedNavIndex = 1;

  final List<Map<String, dynamic>> electricVehicles = [
    {'label': 'e-Car', 'image': 'assets/buy_image/ecar.png'},
    {'label': 'e-Scooty', 'image': 'assets/buy_image/e-scooty.png'},
    {'label': 'e-Bike', 'image': 'assets/buy_image/ebike.png'},
  ];

  final List<Map<String, dynamic>> _trendingCars = [
    {
      'image': 'assets/home_image/maruti_suzuki_swift.png',
      'name': 'Maruti Suzuki Swift',
      'year': '2021',
      'price': '6.98',
    },
    {
      'image': 'assets/home_image/maruti_suzuki_baleno.png',
      'name': 'Maruti Suzuki Baleno',
      'year': '2023',
      'price': '7.00',
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UsedVehicleProvider>().fetchUsedVehicleCategories();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Navigate to another tab screen.
  /// All tab navigations pop back to Home first, then push the new screen.
  /// This ensures the back arrow on any tab screen always goes back to Home.
  void _onNavTap(int index) {
    if (index == _selectedNavIndex) return; // already here

    if (index == 0) {
      // Home — pop all the way back to Home (root)
      Navigator.popUntil(context, (route) => route.isFirst);
    } else if (index == 2) {
      // Sell — replace current screen so back arrow goes to Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SellVehicleScreen()),
      );
    } else if (index == 3) {
      // Compare — replace current screen so back arrow goes to Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CompareVehicleScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _buildSearchBar(),
                    _buildSectionTitle('Lets find your vehicle'),
                    SizedBox(height: 8,),
                    _buildVehicleGrid(),
                    SizedBox(height: 8,),
                    Divider(color: Color(0xFFD4D4D4),),
                    _buildElectricSection(),
                    _buildRentBanner(),
                    SizedBox(height: 8,),
                    _buildTrendingCarsSection(),
                    const SizedBox(height: 25),
                  ],
                ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Row(
        children: [
          GestureDetector(
            // Back arrow always goes to Home (pops to root)
            onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
            child: const Icon(Icons.arrow_back, size: 24, color: Color(0xFF01422D)),
          ),
          const SizedBox(width: 16),
          const Text(
            'Used Vehicle',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFF01422D)),
          ),
        ],
      ),
    );
  }

  void _openSearch() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _openSearch,
              child: Container(
                height: 45,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFB8B8B8)
                  )
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: Color(0xFFBFBFBF)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Search Vehicle by price, model, make',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xFFB3B3B3),
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w400
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            child: Container(
              width: 52,
              height: 45,
              decoration: BoxDecoration(
                color: const Color(0xFF005F65),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.tune, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(title,
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black)),
    );
  }

  Widget _buildVehicleGrid() {
    return Consumer<UsedVehicleProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(color: Color(0xFF005F65)),
            ),
          );
        }

        if (provider.error != null) {
          return Center(child: Text('Error: ${provider.error}'));
        }

        final items = provider.categories;

        if (items.isEmpty) {
          return const Center(child: Text('No categories found.'));
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 15,
              childAspectRatio: 0.80,
            ),
            itemBuilder: (context, index) {
              final cat = items[index];
              return InkWell(
                onTap: () {
                  if (cat.catName.toLowerCase() == 'car') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BuyCarScreen(),
                      ),
                    );
                  }
                },
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 75,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 4,
                            offset: const Offset(0, 4),
                            color: Colors.black.withOpacity(0.15),
                          ),
                        ],
                      ),
                      child: Image.network(
                        cat.image,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(Icons.directions_car, color: Colors.grey),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      cat.catName,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildElectricSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            'Electric Vehicles',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: electricVehicles.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 0.80,
            ),
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Container(
                    width: 80,
                    height: 75,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 4,
                          offset: const Offset(0, 4),
                          color: Colors.black.withOpacity(0.15),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      electricVehicles[index]['image'],
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    electricVehicles[index]['label'],
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRentBanner() {
    return Container(
      child: ClipRRect(
        child: SizedBox(
          height: 150,
          width: double.infinity,
          child: Image.asset('assets/home_image/rent_banner.png', fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _buildTrendingCarsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Text(
            'Trending Cars',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
        SizedBox(
          height: 235.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            children: _trendingCars.map((car) => _buildCarCard(car)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCarCard(Map<String, dynamic> car) {
    return Container(
      width: 250.w,
      margin: EdgeInsets.only(right: 14.w),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFEAEAEA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Image.asset(car['image'], height: 75.h, width: 140.w, fit: BoxFit.contain),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  car['name'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                car['year'] ?? '',
                style: TextStyle(fontSize: 13.sp, color: const Color(0xFF464646)),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Test Drive Available',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.sp, color: const Color(0xFF797979)),
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '₹ ',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 13.sp,
                      ),
                    ),
                    TextSpan(
                      text: car['price'] ?? '',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 13.sp,
                      ),
                    ),
                    TextSpan(
                      text: ' Lakh',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF742B88)),
                borderRadius: BorderRadius.circular(4.r),
              ),

              child: const Text('View Details',
                  style: TextStyle(
                      color: Color(0xFF742B88),
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      {'image': 'assets/icons/home.png', 'label': 'Home'},
      {'image': 'assets/icons/buy.png', 'label': 'Buy'},
      {'image': 'assets/icons/sell.png', 'label': 'Sell'},
      {'image': 'assets/icons/compare.png', 'label': 'Compare'},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF005F65),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 65,
          child: Row(
            children: List.generate(items.length, (i) {
              final isSelected = _selectedNavIndex == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _onNavTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 4),
                      Image.asset(
                        items[i]['image'] as String,
                        width: isSelected ? 28 : 24,
                        height: isSelected ? 28 : 24,
                        fit: BoxFit.contain,
                        color: isSelected ? Colors.white : Colors.white60,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        items[i]['label'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white : Colors.white60,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Active white indicator bar
                      Container(
                        height: 4,
                        width: isSelected ? double.infinity : 0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}