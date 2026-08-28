import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:true_motors/lease_vehicle_module/lease_vehicle_screen.dart';
import 'package:true_motors/rental_module/rental_page_screen.dart';
import 'package:true_motors/service_vehicle_module/vehicle_service_screen.dart';
import 'used_vehicle_screen.dart';
import 'sell_vehicle_screen.dart';
import 'compare_vehicle_screen.dart';
import 'app_drawer.dart';
import 'search_screen.dart';
import 'location_screen.dart';
import 'notification_screen.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';


class HomeScreen extends StatefulWidget {
  final int initialIndex;
  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController searchController = TextEditingController();
  FocusNode searchFocus = FocusNode();

  int hintIndex = 0;
  int _selectedIndex = 0;
  int bannerIndex = 0;

  String _selectedCity = '';

  Timer? bannerTimer;
  Timer? hintTimer;
  bool showHint = true;
  List<String> hints = [
    'Price',
    'Model',
    'Year',
    'Body Type',
    'Fuel Type',
    'Transmission',
    'Owner Count',
    'Kms Driven',
  ];

  final List<String> banners = [
    'assets/home_image/red_banner_car.png',
    'assets/home_image/banner2.png',
    'assets/home_image/banner3.png',
  ];

  final List<Map<String, dynamic>> _trendingCars = [
    {
      'image': 'assets/home_image/maruti_suzuki_swift.png',
      'name': 'Maruti Suzuki Swift',
      'year': '2021',
      'price': '9.2',
      'subtitle': 'Petrol • 18000kms • 1st Owner',
      'save': '85,000'
    },
    {
      'image': 'assets/home_image/maruti_suzuki_swift.png',
      'name': 'Maruti Suzuki Baleno',
      'year': '2021',
      'price': '9.2',
      'subtitle': 'Petrol • 18000kms • 1st Owner',
      'save': '85,000'
    },
  ];

  final List<Map<String, dynamic>> _recommendedNewCars = [
    {
      'image': 'assets/home_image/maruti_suzuki_swift.png',
      'name': 'Maruti Suzuki Swift',
      'subtitle': 'Petrol',
      'price': '9.2',
      'emi': 'EMI Available',
    },
    {
      'image': 'assets/home_image/maruti_suzuki_swift.png',
      'name': 'Maruti Suzuki Swift',
      'subtitle': 'Diesel',
      'price': '9.2',
      'emi': 'EMI Available',
    },
  ];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _loadSavedCity();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
    ));

    bannerTimer = Timer.periodic(
      const Duration(seconds: 2),
          (timer) {
        if (mounted) {
          setState(() {
            bannerIndex = (bannerIndex + 1) % banners.length;
          });
        }
      },
    );

    hintTimer = Timer.periodic(
      const Duration(milliseconds: 700),
          (timer) {
        if (!mounted) return;
        setState(() {
          if (searchFocus.hasFocus || searchController.text.isNotEmpty) {
            showHint = false;
            return;
          }
          if (showHint) {
            showHint = false;
          } else {
            showHint = true;
            hintIndex = (hintIndex + 1) % hints.length;
          }
        });
      },
    );
  }

  Future<void> _loadSavedCity() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedCity = prefs.getString('selected_city') ?? '';
    });
  }

  @override
  void dispose() {
    bannerTimer?.cancel();
    hintTimer?.cancel();
    searchController.dispose();
    searchFocus.dispose();
    super.dispose();
  }

  // Navigate to a screen by changing the selected index
  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // ── Open Search Screen ────────────────────────────────────────────────────
  void _openSearch() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );
    if (result != null && result is String && mounted) {
      searchController.text = result;
      setState(() {});
    }
  }

  // ── Open Location Screen ──────────────────────────────────────────────────
  void _openLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LocationScreen()),
    );
    if (result != null && result is String && mounted) {
      setState(() => _selectedCity = result);
    }
  }

  // ── Open Notification Screen ──────────────────────────────────────────────
  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationScreenPage()),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const UsedVehicleScreen();
      case 2:
        return const SellVehicleScreen();
      case 3:
        return const CompareVehicleScreen();
      default:
        return _buildHomeContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFFDFDFE),
      drawer: AppDrawer(scaffoldKey: _scaffoldKey),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHomeContent() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(),
            _buildSearchBar(),
            _buildCarBanner(),
            _buildCategoryGrid(),
            _buildTrendingCarsSection(),
            _buildRentBanner(),
            _buildRecommendedNewCarsSection(),
            _buildBodyCategorySection(),
            _buildAdBanner(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ── App Bar ───────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return Container(
      color: Color(0xFFFCFDFD),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Hamburger menu
              GestureDetector(
                onTap: () => _scaffoldKey.currentState?.openDrawer(),
                child: const Icon(Icons.menu, color: Color(0xFF01422D), size: 28),
              ),
              const SizedBox(width: 12),
              Image.asset(
                'assets/home_image/home_motors_logo.png',
                height: 34,
                fit: BoxFit.contain,
              ),
            ],
          ),

          // Location + Notification
          Row(
            children: [
              // Location icon
              GestureDetector(
                onTap: _openLocation,
                child: const Icon(Icons.location_on_outlined,
                    color: Color(0xFF01422D), size: 26),
              ),
              const SizedBox(width: 16),
              // Notification icon
              GestureDetector(
                onTap: _openNotifications,
                child: const Icon(Icons.notifications_none,
                    color: Color(0xFF01422D), size: 26),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Search Bar ────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Search field
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
                    color: Color(0xFFB8B8B8)
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
          // Filter icon button
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

  // ── Car Banner ────────────────────────────────────────────────────────────

  Widget _buildCarBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.asset(
          'assets/home_image/blue_car.png',
          width: double.infinity,
          height: 190,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  // ── Category Grid ─────────────────────────────────────────────────────────
  // Figma: single white card with 5 icons in a row — Used, Sell, Rent, Lease, Compare

  Widget _buildCategoryGrid() {
    final List<Map<String, dynamic>> items = [
      {
        'label': 'Buy',
        'image': 'assets/home_image/used.png',
        'screen': const UsedVehicleScreen(),
      },
      {
        'label': 'Sell',
        'image': 'assets/home_image/sell.png',
        'screen': const SellVehicleScreen(),
      },
      {
        'label': 'Rent',
        'image': 'assets/home_image/rent.png',
        'screen': const RentalPageScreen(),
      },
      {
        'label': 'Lease',
        'image': 'assets/home_image/lease.png',
        'screen': const LeaseVehicleScreen(),
      },
      {
        'label': 'Services',
        'image': 'assets/home_image/services.png',
        'screen': const VehicleServiceScreen(),
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFDEDEDE)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: items.map((item) {
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  if (item['screen'] != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => item['screen'] as Widget),
                    );
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 55,
                      height: 55,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF6F8FA),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Image.asset(
                          item['image'] as String,
                          width: 46,
                          height: 46,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        item['label'] as String,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Trending used Cars',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'View all →',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13.sp,
                    color: const Color(0xFF005F65),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 255.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            children: _trendingCars
                .map((car) => _buildCarCard(car, tag: 'Used', tagColor: const Color(0xFFE57373)))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCarCard(Map<String, dynamic> car, {String tag = 'Used', Color tagColor = const Color(0xFFFF5252)}) {
    return Container(
      width: 230.w,
      margin: EdgeInsets.only(right: 14.w),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFEAEAEA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: tagColor,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              Icon(Icons.favorite_border, color: const Color(0xFF4A356A), size: 20.r),
            ],
          ),
          SizedBox(height: 4.h),
          Center(
            child: Image.asset(
              car['image'],
              height: 65.h,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            car['name'] ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            car['subtitle']?.toString().replaceAll(' • ', ' | ') ?? 'Petrol | 18000kms | 1st Owner',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11.sp,
              color: const Color(0xFFA3A3A3),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4.h),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '₹ ',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: const Color(0xFF1E1753),
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                  ),
                ),
                TextSpan(
                  text: car['price'] ?? '',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: const Color(0xFF1E1753),
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                  ),
                ),
                TextSpan(
                  text: ' Lakh',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: const Color(0xFF1E1753),
                    fontWeight: FontWeight.w500,
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            car['save'] != null ? 'Save ₹ ${car['save']}' : (car['emi'] ?? ''),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11.sp,
              color: car['save'] != null ? const Color(0xFF115C3D) : const Color(0xFF005F65),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedNewCarsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recommended New Cars',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'View all →',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.sp,
                    color: const Color(0xFF005F65),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 255.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            children: _recommendedNewCars
                .map((car) => _buildCarCard(car, tag: 'New', tagColor: const Color(0xFF42A5F5)))
                .toList(),
          ),
        ),
      ],
    );
  }


  Widget _buildRentBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ClipRRect(
        child: SizedBox(
          height: 150,
          width: double.infinity,
          child: Image.asset('assets/home_image/rent_banner.png',
              fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _buildBodyCategorySection() {
    final categories = [
      {'label': 'SUV', 'image': 'assets/home_image/suv.png'},
      {'label': 'Sedan', 'image': 'assets/home_image/sedan.png'},
      {'label': 'Hatchbacks', 'image': 'assets/home_image/hatchback.png'},
      {'label': 'e-Bikes', 'image': 'assets/home_image/ebike.png'},
      {'label': 'Bikes', 'image': 'assets/home_image/bike.png'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text('Categories',
              style:
              TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w700)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 0.9,
            children: List.generate(categories.length, (i) {
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEBEBEB)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 8, left: 8, right: 8),
                        child: Image.asset(categories[i]['image']!,
                            fit: BoxFit.contain),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF005F65),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Text(
                        categories[i]['label']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildAdBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          banners[bannerIndex],
          width: double.infinity,
          fit: BoxFit.cover,
        ),
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
              final isSelected = _selectedIndex == i;
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
                      Container(
                        height: 4,
                        width: isSelected ? 36 : 0,
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