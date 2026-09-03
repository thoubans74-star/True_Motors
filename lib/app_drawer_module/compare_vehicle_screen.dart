import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:true_motors/provider/used_vehicle_provider.dart';
import 'package:true_motors/compare_vehicle_module/compare_brand_screen.dart';
import 'package:true_motors/compare_vehicle_module/compare_result_screen.dart';
import 'dart:math' as math;
import 'used_vehicle_screen.dart';
import 'sell_vehicle_screen.dart';

// ── Data model for a selected car ─────────────────────────────────────────────
class SelectedCar {
  final String brand;
  final String model;
  final String variant;
  final String fuelType;
  final String imagePath;

  const SelectedCar({
    required this.brand,
    required this.model,
    required this.variant,
    required this.fuelType,
    required this.imagePath,
  });

  String get displayLabel => '$brand $model\n$variant\n$fuelType';
  String get shortLabel => '$model\n$variant\n$fuelType';
}

class CompareVehicleScreen extends StatefulWidget {
  const CompareVehicleScreen({super.key});

  @override
  State<CompareVehicleScreen> createState() => _CompareVehicleScreenState();
}

class _CompareVehicleScreenState extends State<CompareVehicleScreen> {
  final int _selectedNavIndex = 3;

  // ── Nullable so hint "Select Vehicle" shows when nothing is chosen ─────────
  UsedVehicleCategory? _selectedCategory;

  SelectedCar? _car1;
  SelectedCar? _car2;
  int _selectedCategoryTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UsedVehicleProvider>().fetchUsedVehicleCategories();
    });
  }
  final List<String> _categoryTabs = [
    'SUV', 'Sedan', 'Hatchback', 'Electric/Hybrid'
  ];

  final List<Map<String, dynamic>> _popularComparisons = [
    {
      'car1': {
        'brand': 'Maruti Suzuki', 'model': 'Swift',
        'price': '₹ 6.36 Lakh', 'fuel': 'Petrol',
        'tag': 'Ex Showroom Prize',
        'image': 'assets/compare_image/swift.png',
      },
      'car2': {
        'brand': 'Hyundai', 'model': 'i10 Nios Sportz 1.2',
        'price': '₹ 8.49 Lakh', 'fuel': 'Petrol',
        'tag': 'Ex Showroom Prize',
        'image': 'assets/compare_image/hyundai.png',
      },
    },
    {
      'car1': {
        'brand': 'Maruti Suzuki', 'model': 'Swift',
        'price': '₹ 6.36 Lakh', 'fuel': 'Petrol',
        'tag': 'Ex Showroom Prize',
        'image': 'assets/compare_image/swift.png',
      },
      'car2': {
        'brand': 'Hyundai', 'model': 'i10 Nios Sportz 1.2',
        'price': '₹ 8.49 Lakh', 'fuel': 'Petrol',
        'tag': 'Ex Showroom Prize',
        'image': 'assets/compare_image/hyundai.png',
      },
    },
  ];

  final List<Map<String, dynamic>> _categoryComparisons = [
    {
      'car1': {
        'brand': 'Maruti Suzuki', 'model': 'Swift',
        'price': '₹ 6.36 Lakh', 'fuel': 'Petrol',
        'tag': 'Ex Showroom Prize',
        'image': 'assets/home_image/maruti_suzuki_swift.png',
      },
      'car2': {
        'brand': 'Hyundai', 'model': 'i10 Nios Sportz 1.2',
        'price': '₹ 8.49 Lakh', 'fuel': 'Petrol',
        'tag': 'Ex Showroom Prize',
        'image': 'assets/home_image/maruti_suzuki_baleno.png',
      },
    },
  ];

  final List<Map<String, String>> _faqs = [
    {
      'q': 'Q. Where can I Sell my car?',
      'a': 'You can sell your car through True Motors by visiting our website or app, entering your car details, and getting an instant price quote.',
    },
    {
      'q': 'Q. Which documents are essential for selling my car?',
      'a': 'You will need the RC, valid insurance documents, PUC certificate, original purchase invoice, and a valid ID proof such as Aadhaar or PAN card.',
    },
    {
      'q': 'Q. How soon will I receive payment after selling my car?',
      'a': 'Payment is transferred directly to your bank account before your car is picked up. The process is instant and secure.',
    },
    {
      'q': 'Q. How long does it take to sell my car?',
      'a': 'The entire process typically takes 24 to 48 hours, depending on your location and document readiness.',
    },
  ];
  final List<bool> _faqExpanded = [false, false, false, false];

  // ── Returns the singular label for the selected vehicle type ──────────────
  // When nothing is selected (_selectedCategory == null) returns 'Vehicle'
  String get _vehicleLabel {
    final catName = _selectedCategory?.catName.toLowerCase();
    switch (catName) {
      case 'car':     return 'Car';
      case 'bike':    return 'Bike';
      case 'scooty':  return 'Scooty';
      case 'e - car': return 'E - Car';
      case 'tractor': return 'Tractor';
      default:        return 'Vehicle';
    }
  }

  // ── Returns the plural label used in "Add __s to Compare" heading ─────────
  String get _vehicleLabelPlural {
    final catName = _selectedCategory?.catName.toLowerCase();
    switch (catName) {
      case 'car':     return 'Cars';
      case 'bike':    return 'Bikes';
      case 'scooty':  return 'Scooties';
      case 'e - car': return 'E - Cars';
      case 'tractor': return 'Tractors';
      default:        return 'Vehicles';
    }
  }

  void _onNavTap(int index) {
    if (index == _selectedNavIndex) return;
    if (index == 0) {
      Navigator.popUntil(context, (route) => route.isFirst);
    } else if (index == 1) {
      Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const UsedVehicleScreen()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const SellVehicleScreen()),
      );
    }
  }

  Future<void> _pickCar(int slot) async {
    // Do not allow picking if no vehicle type has been selected yet
    if (_selectedCategory == null) return;

    final result = await Navigator.push<SelectedCar>(
      context,
      MaterialPageRoute(builder: (_) => CompareBrandScreen(slot: slot)),
    );
    if (result != null) {
      setState(() {
        if (slot == 1) {
          _car1 = result;
        } else {
          _car2 = result;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroBanner(),
                    _buildCompareForm(),
                    _buildRentBanner(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Text(
                        'Popular $_vehicleLabel Comparison',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                    _buildPopularComparisons(),
                    _buildSkodaAdBanner(),
                    _buildCategoryComparison(),
                    _buildPopularComparisons(),
                    _buildFAQ(),
                    const SizedBox(height: 16),
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
            onTap: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
            child: const Icon(Icons.arrow_back,
                size: 24, color: Color(0xFF01422D)),
          ),
          const SizedBox(width: 16),
          const Text(
            'Compare Vehicle',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color(0xFF01442D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 180,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/compare_image/vs_car.png',
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildCompareForm() {
    final bool bothSelected = _car1 != null && _car2 != null;

    return Column(
      children: [
        // ── Vehicle type dropdown (hint-based, nullable value) ─────────────
        Consumer<UsedVehicleProvider>(
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

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF000000)),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<UsedVehicleCategory>(
                  dropdownColor: Colors.white,
                  iconEnabledColor: Colors.black,
                  isExpanded: true,
                  // Null value → hint is shown ("Select Vehicle")
                  value: _selectedCategory,
                  hint: const Text(
                    'Select Vehicle',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  items: provider.categories
                      .map((e) => DropdownMenuItem(value: e, child: Text(e.catName)))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedCategory = val;
                      // Reset slots whenever the vehicle type changes
                      _car1 = null;
                      _car2 = null;
                    });
                  },
                ),
              ),
            );
          }
        ),
        const SizedBox(height: 16),

        // ── Add vehicles card ──────────────────────────────────────────────
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Color(0xFFFFFBFB)
            )
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Dynamic heading: "Add Vehicles to Compare" /
              //    "Add Cars to Compare" / "Add Bikes to Compare" etc. ──────
              Text(
                'Add $_vehicleLabelPlural to Compare',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: _buildCarSlot(slot: 1, car: _car1)),
                  Container(
                    width: 40, height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFF005F65),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        'Vs',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  Expanded(child: _buildCarSlot(slot: 2, car: _car2)),
                ],
              ),

              // ── "+ Add More Compare" — only when both slots are filled ───


              const SizedBox(height: 28),
              Center(
                child: SizedBox(
                  width: 260,
                  child: ElevatedButton(
                    onPressed: bothSelected
                        ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CompareResultScreen(
                            car1: _car1!,
                            car2: _car2!,
                          ),
                        ),
                      );
                    }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF005F65),
                      disabledBackgroundColor:
                      const Color(0xFF005F65),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Compare Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),

              if (bothSelected) ...[
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: const [
                      Icon(Icons.add, color: Color(0xFF742B88), size: 20),
                      SizedBox(width: 4),
                      Text(
                        'Add More Compare',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF742B88),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ── Single car slot ────────────────────────────────────────────────────────
  // Empty  → dashed circle with "+" and "Select <Vehicle>"
  // Filled → vehicle image with a red remove badge
  Widget _buildCarSlot({required int slot, required SelectedCar? car}) {
    if (car == null) {
      // ── Empty slot ─────────────────────────────────────────────────────
      return GestureDetector(
        // Disable tap until a vehicle type is selected
        onTap: _selectedCategory == null ? null : () => _pickCar(slot),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomPaint(
              painter: _DashedCirclePainter(
                color: const Color(0xFF929292),
                strokeWidth: 1,
                dashLength: 3.0,
                gapLength: 2.0,
              ),
              child: SizedBox(
                width: 58, height: 58,
                child: Center(
                  child: Text(
                    '+',
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.w300,
                      // Dim the "+" when no vehicle type is chosen yet
                      color: _selectedCategory == null
                          ? const Color(0xFF742B88).withOpacity(0.4)
                          : const Color(0xFF742B88),
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            // "Select Car" / "Select Bike" / "Select Vehicle" etc.
            Text(
              'Select $_vehicleLabel',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      );
    }

    // ── Filled slot ────────────────────────────────────────────────────────
    return GestureDetector(
      onTap: () => _pickCar(slot),
      child: SizedBox(
        width: 120.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Image.asset(
                    'assets/compare_image/alpha_ags.png',
                    width: 90.w, height: 60.h,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Container(
                      width: 90.w, height: 60.h,
                      color: const Color(0xFFEEEEEE),
                      child: Icon(Icons.directions_car,
                          color: Colors.grey, size: 32.r),
                    ),
                  ),
                ),
                // Red remove badge
                Positioned(
                  top: -6.h,
                  right: -6.w,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (slot == 1) _car1 = null;
                        else _car2 = null;
                      });
                    },
                    child: Container(
                      width: 20.r, height: 20.r,
                      decoration: const BoxDecoration(
                        color: Color(0xFFAAAAAA),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close,
                          color: Colors.white, size: 12.r),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              '${car.brand} ${car.model}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            Text(
              car.variant,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.sp, color: const Color(0xFF545151)),
            ),
            Text(
              car.fuelType,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.sp, color: const Color(0xFF545151)),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildRentBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ClipRRect(
        child: SizedBox(
          height: 150,
          width: double.infinity,
          child: Image.asset(
              'assets/home_image/rent_banner.png', fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _buildPopularComparisons() {
    return SizedBox(
      height: 310,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: _popularComparisons
            .map((item) => _buildCompareCard(item))
            .toList(),
      ),
    );
  }

  Widget _buildCompareCard(Map<String, dynamic> item) {
    final car1 = item['car1'] as Map<String, String>;
    final car2 = item['car2'] as Map<String, String>;

    return Container(
      width: 310,
      margin: const EdgeInsets.only(right: 14, bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            offset: const Offset(0, 1.84),
            blurRadius: 1.84,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 100.h,
                      child: Image.asset(car1['image']!, fit: BoxFit.contain),
                    ),
                  ),
                  Container(width: 1, height: 100.h, color: const Color(0xFFE6E6E6)),
                  Expanded(
                    child: SizedBox(
                      height: 100.h,
                      child: Image.asset(car2['image']!, fit: BoxFit.contain),
                    ),
                  ),
                ],
              ),
              Positioned.fill(
                child: Row(
                  children: [
                    Expanded(child: Container()),
                    Center(
                      child: Container(
                        width: 22.r, height: 22.r,
                        decoration: const BoxDecoration(
                          color: Color(0xFF742B88),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.swap_horiz,
                            color: Colors.white, size: 15.r),
                      ),
                    ),
                    Expanded(child: Container()),
                  ],
                ),
              ),
            ],
          ),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(child: _buildCompareCarDetails(car1)),
                Container(width: 1, color: const Color(0xFFE6E6E6)),
                Expanded(child: _buildCompareCarDetails(car2)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompareCarDetails(Map<String, String> car) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(car['brand']!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 13.sp,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500)),
          SizedBox(height: 2.h),
          Text(car['model']!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF545151),
                  fontFamily: 'Inter')),
          SizedBox(height: 4.h),
          Row(
            children: [
              Icon(Icons.currency_rupee,
                  size: 13.r, color: const Color(0xFF5F6368)),
              Expanded(
                child: Text(
                  car['price']!.replaceAll('₹ ', '').replaceAll('₹', ''),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 13.sp,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(car['fuel']!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12.sp, color: Colors.black)),
          SizedBox(height: 2.h),
          Text(car['tag']!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
              TextStyle(fontSize: 11.5.sp, color: Colors.black)),
        ],
      ),
    );
  }

  Widget _buildSkodaAdBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      height: 300,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/compare_image/skoda_banner.png',
          width: double.infinity,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildCategoryComparison() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Car Comparison By Category',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter'),
          ),
        ),
        const SizedBox(height: 5),
        Container(
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_categoryTabs.length, (i) {
              final isSelected = _selectedCategoryTab == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedCategoryTab = i),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected
                              ? const Color(0xFF742B88)
                              : Colors.transparent,
                          width: 4,
                        ),
                      ),
                    ),
                    child: Text(
                      _categoryTabs[i],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildFAQ() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Center(
            child: Text(
              'Frequently Asked Questions',
              style:
              TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        ...List.generate(_faqs.length, (i) {
          return Container(
            margin:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () =>
                      setState(() => _faqExpanded[i] = !_faqExpanded[i]),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _faqs[i]['q']!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Icon(
                          _faqExpanded[i]
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
                if (_faqExpanded[i]) ...[
                  Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.grey.shade200,
                      indent: 14,
                      endIndent: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    child: Text(
                      _faqs[i]['a']!,
                      style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                          height: 1.5),
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
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
      decoration: const BoxDecoration(color: Color(0xFF005F65)),
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
                          color: isSelected
                              ? Colors.white
                              : Colors.white60,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 4,
                        width: isSelected ? 36 : 0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
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

// ── Dashed circle painter ──────────────────────────────────────────────────────
class _DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  const _DashedCirclePainter({
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.gapLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth / 2;
    final circumference = 2 * math.pi * radius;
    final dashGap = dashLength + gapLength;
    final totalDashes = (circumference / dashGap).floor();
    final adjustedDashGap = circumference / totalDashes;
    final adjustedDash = adjustedDashGap * (dashLength / dashGap);
    final adjustedGap = adjustedDashGap * (gapLength / dashGap);

    double startAngle = -math.pi / 2;
    for (int i = 0; i < totalDashes; i++) {
      final sweepAngle = adjustedDash / radius;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle, sweepAngle, false, paint,
      );
      startAngle += sweepAngle + (adjustedGap / radius);
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter old) =>
      old.color != color ||
          old.strokeWidth != strokeWidth ||
          old.dashLength != dashLength ||
          old.gapLength != gapLength;
}