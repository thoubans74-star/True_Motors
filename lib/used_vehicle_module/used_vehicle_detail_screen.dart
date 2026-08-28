import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:true_motors/provider/used_vehicle_provider.dart';
import 'package:true_motors/app_drawer_module/sell_vehicle_screen.dart';
import 'dealers_near_you_screen.dart';
import 'test_drive_screen.dart';
import 'buy_car.dart'; // for CarListingCard, _DashedDivider, CarListing, sampleCars
import 'package:true_motors/menu_module/favourites_manager.dart';

// ─── Used Vehicle Detail Screen ───────────────────────────────────────────────

class UsedVehicleDetailScreen extends StatefulWidget {
  const UsedVehicleDetailScreen({super.key});

  @override
  State<UsedVehicleDetailScreen> createState() =>
      _UsedVehicleDetailScreenState();
}

class _UsedVehicleDetailScreenState extends State<UsedVehicleDetailScreen> {
  bool _showAllSpecs = false;
  bool _showAllFeatures = false;
  final List<bool> _faqExpanded = [false, false, false, false];

  final FavoritesManager _manager = FavoritesManager.instance;

  // The car being displayed on this detail screen
  final CarListing _detailCar = sampleCars.first;

  // EMI Calculator state
  double _downPayment = 122000;
  double _loanPayment = 710000;
  double _interestRate = 10;
  double _tenure = 48;

  double get _emiAmount {
    final p = _loanPayment;
    final r = _interestRate / 100 / 12;
    final n = _tenure;
    if (r == 0) return p / n;
    return p * r * (1 + r).toDouble().pow(n) /
        ((1 + r).toDouble().pow(n) - 1);
  }

  double get _totalPayment => _emiAmount * _tenure;

  @override
  void initState() {
    super.initState();
    _manager.addListener(_onFavoritesChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UsedVehicleProvider>().fetchUsedVehicleCategories();
    });
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
                    _buildTopBar(context),
                    Expanded(
                      child: Stack(
                        children: [
                          SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildCarImageSection(),
                                _buildCarHeader(),
                                const SizedBox(height: 8),
                                _buildCategoriesSection(),
                                const SizedBox(height: 8),
                                _buildCarOverview(),
                                const SizedBox(height: 8),
                                _buildCarSpecifications(),
                                const SizedBox(height: 8),
                                _buildTopFeatures(),
                                const SizedBox(height: 8),
                                _buildEmiCalculator(),
                                const SizedBox(height: 8),
                                _buildSellCarBanner(),
                                _buildSimilarCars(context),
                                _buildFAQ(),
                                const SizedBox(height: 100),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: _buildBottomButtons(context),
                          ),
                        ],
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

  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Icon(Icons.arrow_back, size: 24.r,
                color: const Color(0xFF01422D)),
          ),
          SizedBox(width: 12.w),
          Text(
            'Buy',
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

  Widget _buildCarImageSection() {
    final isFav = _manager.isFavorite(_detailCar);
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(top: 16.h, left: 16.w, right: 16.w, bottom: 8.h),
      child: Stack(
        children: [
          SizedBox(
            height: 190.h,
            width: double.infinity,
            child: Image.asset(
              'assets/buy_car/suzuki.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Center(
                child: Icon(Icons.directions_car,
                    size: 80.r, color: const Color(0xFFCCCCCC)),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _manager.toggle(_detailCar),
                  child: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    size: 22.r,
                    color: isFav
                        ? const Color(0xFFE53935)
                        : const Color(0xFF742B88),
                  ),
                ),
                SizedBox(width: 12.w),
                Icon(Icons.share_outlined,
                    size: 22.r, color: const Color(0xFF742B88)),
              ],
            ),
          ),
          Positioned(
            bottom: 20.h,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF742B88)),
              ),
              child: Icon(Icons.threesixty,
                  size: 16.r, color: const Color(0xFF742B88)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Maruti Suzuki Swift VX',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF2101AF),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8B8B),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Used',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF000000),
                fontFamily: 'Inter',
              ),
              children: [
                TextSpan(text: '25,000 km | Petrol | '),
                TextSpan(
                  text: 'Manual',
                  style: TextStyle(color: Color(0xFF742B88)),
                ),
                TextSpan(text: ' | 2021'),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'EMI  ₹13,470/mo',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF040084),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text(
                '₹ 9.2 Lakh',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFE53935),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Image.asset(
                    'assets/buy_car/pin.png',
                    width: 16,
                    height: 16,
                    errorBuilder: (_, __, ___) => const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Color(0xFFE53935)),
                  ),
                  const SizedBox(width: 4),
                  const Text('Coimbatore',
                      style: TextStyle(
                          fontSize: 14, color: Color(0xFF3C3C3C))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Consumer<UsedVehicleProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ));
        }
        if (provider.error != null) {
          return Center(child: Text('Error: ${provider.error}'));
        }
        if (provider.categories.isEmpty) {
          return const SizedBox.shrink();
        }
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Categories',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF000000))),
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: provider.categories.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final cat = provider.categories[index];
                    return Column(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: const Color(0xFFF0F0F0),
                          backgroundImage: NetworkImage(cat.image),
                          onBackgroundImageError: (_, __) => const Icon(Icons.error),
                        ),
                        const SizedBox(height: 8),
                        Text(cat.catName, style: const TextStyle(fontSize: 12)),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCarOverview() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Car overview',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF000000),
              )),
          const SizedBox(height: 12),
          _buildOverviewGridRow('Make year', 'Mar 2015', 'Reg year', 'Jun 2015'),
          _buildOverviewGridRow('Fuel', 'Petrol', 'Kilometers driven', '10000'),
          _buildOverviewGridRow('Transmission', 'Manual(Regular)', 'No.of Owners', '1st owner'),
          _buildOverviewGridRow('RTO', 'TN43', 'Car Location', 'Coimbatore'),
          _buildOverviewGridRow('Insurance Validity', 'Jun 2025', 'Insurance Type', 'Comprehensive'),
        ],
      ),
    );
  }

  Widget _buildOverviewGridRow(String t1, String v1, String t2, String v2) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _overviewCell(t1, v1)),
          const SizedBox(width: 40),
          Expanded(child: _overviewCell(t2, v2)),
        ],
      ),
    );
  }

  Widget _overviewCell(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontFamily: 'Inter', fontSize: 13, color: Color(0xFF8C8C8C))),
        const SizedBox(height: 5),
        Text(value,
            style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF000000))),
      ],
    );
  }

  Widget _buildCarSpecifications() {
    final specs = [
      ['Mileage', '18.6kmpl', 'Displacement', '1197cc'],
      ['Ground clearance', '170mm', 'No. of cylinders', '4 units'],
      ['Boot Space', '285 litres', 'Steering type', 'Power'],
      ['Seating capacity', '5 units', 'No.of gears', '5 units'],
      ['Fuel tank capacity', '45 litres', 'Front brake type', 'Disc'],
    ];
    final visible = _showAllSpecs ? specs : specs.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Car specifications',
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF000000))),
          const SizedBox(height: 12),
          ...visible.map((s) => _buildSpecGridRow(s[0], s[1], s[2], s[3])),
          const SizedBox(height: 12),
          Center(
            child: OutlinedButton(
              onPressed: () =>
                  setState(() => _showAllSpecs = !_showAllSpecs),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF742B88)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding:
                const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
              ),
              child: Text(
                _showAllSpecs
                    ? 'View less specification'
                    : 'View all specification',
                style: const TextStyle(
                    color: Color(0xFF000000),
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w400),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecGridRow(String t1, String v1, String t2, String v2) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(child: _overviewCell(t1, v1)),
          SizedBox(width: MediaQuery.of(context).size.width * 0.15),
          Expanded(child: _overviewCell(t2, v2)),
        ],
      ),
    );
  }

  Widget _buildTopFeatures() {
    final categories = [
      _FeatureCategory('Safety',
          ['Airbags', 'Rear camera', 'Parking sensors']),
      _FeatureCategory('Entertainment & communication', [
        'Integrated(in dash)music system',
        'Touch screen infotainment system',
        'GPS navigation system'
      ]),
      _FeatureCategory('Exterior', ['Rear defogger']),
      _FeatureCategory('Comfort & convenience',
          ['Steering mounted controls', 'Driver height adjustable seat']),
    ];
    final visible =
    _showAllFeatures ? categories : categories.take(2).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Top Features',
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF000000))),
          const SizedBox(height: 12),
          ...visible.map((cat) => _buildFeatureCategory(cat)),
          const SizedBox(height: 8),
          Center(
            child: OutlinedButton(
              onPressed: () =>
                  setState(() => _showAllFeatures = !_showAllFeatures),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF742B88)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding:
                const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
              ),
              child: Text(
                _showAllFeatures
                    ? 'View less Features'
                    : 'View all Features',
                style: const TextStyle(
                    color: Color(0xFF000000),
                    fontSize: 14,
                    fontWeight: FontWeight.w400),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCategory(_FeatureCategory category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(category.name,
                style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8C8C8C),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500)),
            const SizedBox(width: 15),
            Expanded(child: Container(height: 1, color: const Color(0xFF8C8C88))),
          ],
        ),
        const SizedBox(height: 8),
        ...category.features.map((f) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(f,
              style: const TextStyle(
                  fontSize: 13, fontFamily: 'Inter', color: Color(0xFF000000))),
        )),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildEmiCalculator() {
    final emi = _emiAmount.isNaN || _emiAmount.isInfinite ? 0.0 : _emiAmount;
    final total =
    _totalPayment.isNaN || _totalPayment.isInfinite ? 0.0 : _totalPayment;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('EMI Calculator',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF742B88))),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildSliderRow('Down Payment', _downPayment, 0, 1000000,
                        '₹', (v) => setState(() => _downPayment = v)),
                    _buildSliderRow('Loan Payment', _loanPayment, 100000,
                        1000000, '₹', (v) => setState(() => _loanPayment = v)),
                    _buildSliderRow('Interest Rate', _interestRate, 5, 20, '%',
                            (v) => setState(() => _interestRate = v)),
                    _buildSliderRow('Tenure', _tenure, 12, 72, 'Months',
                            (v) => setState(() => _tenure = v)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 180,
                child: Column(
                  children: [
                    SizedBox(
                      height: 101.5,
                      width: 101.5,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'assets/buy_car/emi_circle.png',
                            height: 101.5,
                            width: 101.5,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) =>
                                CircularProgressIndicator(
                                  value: _loanPayment /
                                      (_loanPayment + _downPayment + 1),
                                  strokeWidth: 10,
                                  backgroundColor: const Color(0xFF1A3A5C),
                                  valueColor:
                                  const AlwaysStoppedAnimation<Color>(
                                      Color(0xFF4CAF50)),
                                ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Total EMI',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF742B88),
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text(emi.toStringAsFixed(0),
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 35,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF742B88),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('EMI Amount',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 7,
                                              fontWeight: FontWeight.w600)),
                                      Text(emi.toStringAsFixed(0),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 7,
                                              fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Total Payment',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 7,
                                              fontWeight: FontWeight.w600)),
                                      Text(total.toStringAsFixed(0),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 7,
                                              fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            width: 55,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Apply',
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700)),
                                SizedBox(width: 3),
                                Icon(Icons.arrow_forward, size: 10),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSliderRow(String label, double value, double min, double max,
      String unit, ValueChanged<double> onChanged) {
    String displayValue;
    if (unit == '₹') {
      displayValue =
      '₹ ${(value / 1000).toStringAsFixed(0)},${(value % 1000).toStringAsFixed(0).padLeft(3, '0')}';
    } else if (unit == '%') {
      displayValue = '${value.toStringAsFixed(0)}%';
    } else {
      displayValue = '${value.toStringAsFixed(0)} Months';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            return FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Container(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            fontSize: 10, fontFamily: 'Inter', color: Color(0xFF5F5F5F))),
                    const SizedBox(width: 4),
                    Text(displayValue,
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF742B88),
                            fontFamily: 'Inter')),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 5),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 1,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 3),
            overlayShape: SliderComponentShape.noOverlay,
            activeTrackColor: const Color(0xFF742B88),
            inactiveTrackColor: const Color(0xFFCDCDCD),
            thumbColor: const Color(0xFF742B88),
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatMinMax(min, unit),
                  style: const TextStyle(
                      fontSize: 9, color: Color(0xFF5F5F5F), fontFamily: 'Inter')),
              Text(_formatMinMax(max, unit),
                  style: const TextStyle(
                      fontSize: 9, fontFamily: 'Inter', color: Color(0xFF5F6368))),
            ],
          ),
        ),
        const SizedBox(height: 5),
      ],
    );
  }

  String _formatMinMax(double value, String unit) {
    if (unit == '₹') {
      return '₹ ${value.toInt().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
    }
    if (unit == '%') return '${value.toInt()}%';
    return '${value.toInt()} months';
  }

  Widget _buildSellCarBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      color: const Color(0xFFFFE9F3),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Do You Want to Sell a Car ?',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF050B20))),
          const SizedBox(height: 4),
          const Text(
            'We are committed to providing our customers with exceptional service.',
            style: TextStyle(fontSize: 13, color: Color(0xFF050B20)),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SellVehicleScreen()));
              },
              child: Container(
                padding:
                const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF7B2C02),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('Sell a Car',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Calistoga',
                        fontSize: 13)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarCars(BuildContext context) {
    final similarCars = sampleCars.take(3).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text('Similar Cars',
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF000000))),
          ),
          const SizedBox(height: 15),
          ...List.generate(similarCars.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CarListingCard(
                car: similarCars[i],
                isFav: _manager.isFavorite(similarCars[i]),
                onFavToggle: () => _manager.toggle(similarCars[i]),
                onViewDetails: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const UsedVehicleDetailScreen(),
                    ),
                  );
                },
              ),
            );
          }),
          Center(
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF742B88)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text('View all',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      color: Color(0xFF000000),
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQ() {
    const faqs = [
      'When and where can I take a test drive?',
      'What documents are required for buying a used car?',
      'How is the car price determined?',
      'Is there a warranty on used cars?',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text('Frequently Asked Questions',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF000000))),
          ),
          const SizedBox(height: 15),
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16)),
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            child: Column(
              children: List.generate(faqs.length, (i) {
                return Column(
                  children: [
                    InkWell(
                      onTap: () => setState(
                              () => _faqExpanded[i] = !_faqExpanded[i]),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text('Q. ${faqs[i]}',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Inter',
                                      color: Color(0xFF000000))),
                            ),
                            Icon(
                              _faqExpanded[i]
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: const Color(0xFF5F6368),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_faqExpanded[i])
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text(
                          'You can schedule a test drive at our nearest dealership. Please contact us or use the Free Test Drive option to book your preferred date and time.',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFF777777)),
                        ),
                      ),
                    if (i < faqs.length - 1)
                      const Divider(height: 1, color: Color(0xFFF0F0F0)),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const DealersNearYouScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF005F65),
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r)),
              ),
              child: Text('Find Dealer',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp)),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const TestDriveScreen()),
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF742B88), width: 1.5),
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r)),
              ),
              child: Text('Free Test Drive',
                  style: TextStyle(
                      color: const Color(0xFF742B88),
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Helper Models ────────────────────────────────────────────────────────────

class _FeatureCategory {
  final String name;
  final List<String> features;
  _FeatureCategory(this.name, this.features);
}

extension DoubleExtension on double {
  double pow(double exponent) {
    if (exponent == 0) return 1;
    double result = 1;
    double base = this;
    int n = exponent.toInt();
    for (int i = 0; i < n; i++) {
      result *= base;
    }
    return result;
  }
}