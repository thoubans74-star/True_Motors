import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:true_motors/used_vehicle_module/filter_bottom_sheet.dart';

import 'used_vehicle_detail_screen.dart';
import 'package:true_motors/menu_module/favourites_manager.dart';

class CarListing {
  final String name;
  final int km;
  final String fuel;
  final String transmission;
  final double price;
  final double emi;
  final String location;
  final String imagePath;

  const CarListing({
    required this.name,
    required this.km,
    required this.fuel,
    required this.transmission,
    required this.price,
    required this.emi,
    required this.location,
    required this.imagePath,
  });
}

// ─── Sample Data ─────────────────────────────────────────────────────────────

final List<CarListing> sampleCars = List.generate(
  6,
      (_) => const CarListing(
    name: 'Maruti Suzuki Swift VXI 2021',
    km: 25000,
    fuel: 'Petrol',
    transmission: 'Manual',
    price: 9.2,
    emi: 13470,
    location: 'Coimbatore',
    imagePath: 'assets/buy_car/suzuki.png',
  ),
);

// ─── Buy Car Screen ───────────────────────────────────────────────────────────

class BuyCarScreen extends StatefulWidget {
  const BuyCarScreen({super.key});

  @override
  State<BuyCarScreen> createState() => _BuyCarScreenState();
}

class _BuyCarScreenState extends State<BuyCarScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
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
                    _TopBar(),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),
                            const _AnimatedSearchBar(),
                            const SizedBox(height: 14),
                            _SegmentedControl(),
                            const SizedBox(height: 16),
                            _SectionHeader(
                              title: 'Find the right Cars by',
                              trailing: _SortByButton(),
                            ),
                            const SizedBox(height: 10),
                            _ResultsLabel(count: 170, location: 'Coimbatore'),
                            const SizedBox(height: 10),
                            _CarListings(cars: sampleCars),
                            const SizedBox(height: 24),
                          ],
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
    );
  }
}

// ─── Top Bar ─────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: const Icon(Icons.arrow_back, size: 24,
                color: Color(0xFF01442D)),
          ),
          const SizedBox(width: 12),
          const Text(
            'Buy Car',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color(0xFF01422D),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Animated Search Bar ─────────────────────────────────────────────────────

class _AnimatedSearchBar extends StatefulWidget {
  const _AnimatedSearchBar();

  @override
  State<_AnimatedSearchBar> createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<_AnimatedSearchBar>
    with SingleTickerProviderStateMixin {
  static const List<String> _hints = [
    'Price', 'Model', 'Year', 'Body Type',
    'Fuel Type', 'Transmission', 'Owner Count', 'Kms Driven',
  ];

  int _currentIndex = 0;
  late AnimationController _animController;
  late Animation<Offset> _slideOutAnimation;
  late Animation<Offset> _slideInAnimation;
  late Animation<double> _fadeOutAnimation;
  late Animation<double> _fadeInAnimation;
  Timer? _hintTimer;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideOutAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1.5),
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    ));

    _fadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _slideInAnimation = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    ));

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _hintTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isAnimating) _triggerTransition();
    });
  }

  void _triggerTransition() async {
    _isAnimating = true;
    await _animController.forward();
    setState(() {
      _currentIndex = (_currentIndex + 1) % _hints.length;
    });
    _animController.reset();
    _isAnimating = false;
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF742B88)),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            const Icon(Icons.search, color: Color(0xFF5F6368), size: 20),
            const SizedBox(width: 8),
            const Text(
              'Search Cars by ',
              style: TextStyle(color: Color(0xFF676767), fontSize: 16, fontFamily: 'Inter'),
            ),
            Expanded(
              child: ClipRect(
                child: AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    return Stack(
                      clipBehavior: Clip.hardEdge,
                      children: [
                        SlideTransition(
                          position: _slideOutAnimation,
                          child: FadeTransition(
                            opacity: _fadeOutAnimation,
                            child: Text(
                              '"${_hints[_currentIndex]}"',
                              style: const TextStyle(
                                color: Color(0xFF742B88),
                                fontSize: 16,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        SlideTransition(
                          position: _slideInAnimation,
                          child: FadeTransition(
                            opacity: _fadeInAnimation,
                            child: Text(
                              '"${_hints[(_currentIndex + 1) % _hints.length]}"',
                              style: const TextStyle(
                                color: Color(0xFF742B88),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Segmented Control ───────────────────────────────────────────────────────

class _SegmentedControl extends StatefulWidget {
  @override
  State<_SegmentedControl> createState() => _SegmentedControlState();
}

class _SegmentedControlState extends State<_SegmentedControl> {
  int selectedIndex = 0;
  final List<String> segments = ['All', 'New', 'Used'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFC4C4C4)),
        ),
        child: Row(
          children: List.generate(segments.length, (index) {
            final isSelected = selectedIndex == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => selectedIndex = index),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF005F65) : Colors.transparent,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Center(
                    child: Text(
                      segments[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF676767),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ─── Section Header ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget trailing;
  const _SectionHeader({required this.title, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF000000),
              )),
          const SizedBox(height: 8),
          trailing,
        ],
      ),
    );
  }
}

class _SortByButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showFilterBottomSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFD4D4D4)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.filter_list, size: 18, color: Color(0xFF005F65)),
            const SizedBox(width: 6),
            const Text('Filter',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF005F65),
                )),
          ],
        ),
      ),
    );
  }
}

// ─── Results Label ───────────────────────────────────────────────────────────

class _ResultsLabel extends StatelessWidget {
  final int count;
  final String location;
  const _ResultsLabel({required this.count, required this.location});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text('$count used cars in $location',
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 15,
          color: Colors.black,
        ),
      ),
    );
  }
}

// ─── Car Listings ─────────────────────────────────────────────────────────────

class _CarListings extends StatefulWidget {
  final List<CarListing> cars;
  const _CarListings({required this.cars});

  @override
  State<_CarListings> createState() => _CarListingsState();
}

class _CarListingsState extends State<_CarListings> {
  final FavoritesManager _manager = FavoritesManager.instance;

  @override
  void initState() {
    super.initState();
    _manager.addListener(_onFavoritesChanged);
  }

  @override
  void dispose() {
    _manager.removeListener(_onFavoritesChanged);
    super.dispose();
  }

  void _onFavoritesChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < widget.cars.length; i++) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CarListingCard(
              car: widget.cars[i],
              isFav: _manager.isFavorite(widget.cars[i]),
              onFavToggle: () => _manager.toggle(widget.cars[i]),
              onViewDetails: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UsedVehicleDetailScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          if (i == 2) ...[
            const _RentNowBanner(),
            const SizedBox(height: 10),
          ],
        ],
      ],
    );
  }
}

// ─── Shared Car Listing Card (used across all screens) ───────────────────────

class CarListingCard extends StatelessWidget {
  final CarListing car;
  final bool isFav;
  final VoidCallback onFavToggle;
  final VoidCallback onViewDetails;

  const CarListingCard({
    super.key,
    required this.car,
    required this.isFav,
    required this.onFavToggle,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Car image + details row ──────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image
              Padding(
                padding: const EdgeInsets.all(12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    car.imagePath,
                    width: 110,
                    height: 85,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Container(
                      width: 110,
                      height: 90,
                      color: const Color(0xFFEEEEEE),
                      child: const Icon(Icons.directions_car,
                          color: Colors.grey, size: 36),
                    ),
                  ),
                ),
              ),

              // Details column (right side)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                      top: 10.h, right: 10.w, bottom: 10.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: RichText(
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                children: [
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: Container(
                                      margin: EdgeInsets.only(right: 6.w),
                                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF8B8B),
                                        borderRadius: BorderRadius.circular(4.r),
                                      ),
                                      child: Text(
                                        'Used',
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  TextSpan(
                                    text: car.name,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFF2101AF),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 4.w),
                          GestureDetector(
                            onTap: onFavToggle,
                            child: Icon(
                              isFav
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 20.r,
                              color: isFav
                                  ? const Color(0xFFE53935)
                                  : const Color(0xFF742B88),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      // km | fuel | transmission
                      RichText(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11.5.sp,
                            color: const Color(0xFF000000),
                          ),
                          children: [
                            TextSpan(text:
                            '${_fmtKm(car.km)} km | ${car.fuel} | ',
                            ),
                            TextSpan(
                              text: car.transmission,
                              style: const TextStyle(
                                color: Color(0xFF742B88),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 6.h),
                      // Price
                      Text(
                        '₹ ${car.price} Lakh',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF040084),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      // EMI + location
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'EMI ₹${_fmtEmi(car.emi)}/mo',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  color: const Color(0xFF040084)),
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/buy_car/pin.png',
                                width: 14.r,
                                height: 14.r,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.location_on,
                                  size: 13.r,
                                  color: const Color(0xFFE53935),
                                ),
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                car.location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 12.sp,
                                    color: const Color(0xFF3C3C3C)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Dashed divider ────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: _DashedDivider(),
          ),

          // ── View Seller Details button ────────────────────────────────────
          TextButton(
            onPressed: onViewDetails,
            style: TextButton.styleFrom(
              minimumSize: Size(double.infinity, 38.h),
              padding: EdgeInsets.zero,
            ),
            child: Text(
              'View Seller Details',
              style: TextStyle(
                fontSize: 14.sp,

                fontWeight: FontWeight.w500,
                color: Color(0xFF742B88),
              ),
            ),
          ),
        ],
      ),
    ),
    // Blue teardrop/leaf badge top-left
    Positioned(
      top: 0,
      left: 0,
      child: Image.asset(
        'assets/buy_car/badge.png',
        width: 36,
        height: 36,
        errorBuilder: (_, __, ___) => Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: Color(0xFF003399),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              bottomRight: Radius.circular(36),
            ),
          ),
        ),
      ),
    ),
  ],
);
  }

  String _fmtKm(int km) {
    if (km >= 1000) {
      return '${(km / 1000).toStringAsFixed(0)},000';
    }
    return km.toString();
  }

  String _fmtEmi(double emi) => emi
      .toStringAsFixed(0)
      .replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}

// ─── Dashed Divider ───────────────────────────────────────────────────────────

class _DashedDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 6.0;
        const dashSpace = 4.0;
        final totalWidth = constraints.maxWidth;
        final count = (totalWidth / (dashWidth + dashSpace)).floor();
        return Row(
          children: List.generate(count, (_) {
            return Row(
              children: [
                Container(
                  width: dashWidth,
                  height: 1.2,
                  color: const Color(0xFF000000),
                ),
                const SizedBox(width: dashSpace),
              ],
            );
          }),
        );
      },
    );
  }
}

// ─── Rent Now Banner ─────────────────────────────────────────────────────────

class _RentNowBanner extends StatelessWidget {
  const _RentNowBanner();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: SizedBox(
        height: 150,
        width: double.infinity,
        child: Image.asset(
          'assets/home_image/rent_banner.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}