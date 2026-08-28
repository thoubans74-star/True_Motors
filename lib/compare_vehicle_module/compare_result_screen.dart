import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:true_motors/app_drawer_module/home_screen.dart';
import 'package:true_motors/app_drawer_module/compare_vehicle_screen.dart';

// ── Spec data ─────────────────────────────────────────────────────────────────
class _SpecSection {
  final String title;
  final List<_SpecRow> rows;
  bool isExpanded;

  _SpecSection({
    required this.title,
    required this.rows,
    this.isExpanded = false,
  });
}

class _SpecRow {
  final String label;
  final String val1;
  final String val2;

  const _SpecRow(this.label, this.val1, this.val2);
}

// ── Fake spec data — replace with real API data as needed ─────────────────────
Map<String, dynamic> _fakeSpecs(String brand, String model) {
  if (brand == 'Maruti Suzuki') {
    return {
      'price': '9.2 Lakh',
      'seating': '5',
      'mileage': '20.1',
      'engine': '1197cc',
      'fuel': 'Petrol',
      'transmission': 'Manual',
    };
  }
  if (brand == 'TATA') {
    return {
      'price': '10.2 Lakh',
      'seating': '5',
      'mileage': '18.1',
      'engine': '1199cc',
      'fuel': 'Petrol',
      'transmission': 'Automatic',
    };
  }
  return {
    'price': '8.0 Lakh',
    'seating': '5',
    'mileage': '17.0',
    'engine': '1200cc',
    'fuel': 'Petrol',
    'transmission': 'Manual',
  };
}

class CompareResultScreen extends StatefulWidget {
  final SelectedCar car1;
  final SelectedCar car2;

  const CompareResultScreen({
    super.key,
    required this.car1,
    required this.car2,
  });

  @override
  State<CompareResultScreen> createState() => _CompareResultScreenState();
}

class _CompareResultScreenState extends State<CompareResultScreen> {
  late final Map<String, dynamic> _specs1;
  late final Map<String, dynamic> _specs2;
  late final List<_SpecSection> _sections;

  bool _isFavorite = false;
  int _selectedTabIndex = 0;

  final List<String> _tabs = [
    'Basic Information',
    'Engine & Transmission',
    'Fuel & Performance',
    'Safety & Security',
    'Entertainment & Infotainment',
    'Interior',
    'Exterior',
  ];

  @override
  void initState() {
    super.initState();
    _specs1 = _fakeSpecs(widget.car1.brand, widget.car1.model);
    _specs2 = _fakeSpecs(widget.car2.brand, widget.car2.model);

    _sections = [
      _SpecSection(
        title: 'Engine & Transmission',
        rows: [
          _SpecRow('Engine Type', 'Z12E', '1.2 Revotron'),
          _SpecRow('Displacement (cc)', '1197', '1199'),
          _SpecRow('No of Cylinders', '3', '3'),
          _SpecRow('Transmission Type', 'Manual', 'Manual'),
        ],
      ),
      _SpecSection(
        title: 'Fuel & Performance',
        rows: [
          _SpecRow('Fuel Type', _specs1['fuel'], _specs2['fuel']),
          _SpecRow('Mileage (kmpl)', _specs1['mileage'], _specs2['mileage']),
          _SpecRow('Fuel Tank Capacity', '37', '37'),
          _SpecRow('Emission Norm', 'BS VI 2.0', 'BS VI 2.0'),
        ],
      ),
      _SpecSection(
        title: 'Safety & Security',
        rows: [
          _SpecRow('Airbags', '6', '6'),
          _SpecRow('ABS', 'Yes', 'Yes'),
          _SpecRow('EBD', 'Yes', 'Yes'),
        ],
      ),
      _SpecSection(
        title: 'Entertainment & Infotainment',
        rows: [
          _SpecRow('Touchscreen Size', '9 inch', '10.25 inch'),
          _SpecRow('Android Auto', 'Yes', 'Yes'),
          _SpecRow('Apple CarPlay', 'Yes', 'Yes'),
        ],
      ),
      _SpecSection(
        title: 'Interior',
        rows: [
          _SpecRow('Seating Capacity', _specs1['seating'], _specs2['seating']),
          _SpecRow('Sunroof', 'No', 'Yes'),
          _SpecRow('Gear Indicator', 'Yes', 'Yes'),
        ],
      ),
      _SpecSection(
        title: 'Exterior',
        rows: [
          _SpecRow('Alloy Wheels', 'Yes', 'Yes'),
          _SpecRow('LED DRLs', 'Yes', 'Yes'),
          _SpecRow('Fog Lamps', 'Yes', 'Yes'),
        ],
      ),
    ];
  }

  // ── Returns the rows to display in the table for the selected tab ──────────
  List<_SpecRow> _getTabRows() {
    switch (_selectedTabIndex) {
      case 0: // Basic Information
        return [
          _SpecRow('Price', _specs1['price'] as String, _specs2['price'] as String),
          _SpecRow('Seating', _specs1['seating'] as String, _specs2['seating'] as String),
          _SpecRow('Mileage', _specs1['mileage'] as String, _specs2['mileage'] as String),
          _SpecRow('Engine', _specs1['engine'] as String, _specs2['engine'] as String),
          _SpecRow('Fuel', _specs1['fuel'] as String, _specs2['fuel'] as String),
          _SpecRow('Transmission', _specs1['transmission'] as String, _specs2['transmission'] as String),
        ];
      case 1: // Engine & Transmission
        return _sections[0].rows;
      case 2: // Fuel & Performance
        return _sections[1].rows;
      case 3: // Safety & Security
        return _sections[2].rows;
      case 4: // Entertainment & Infotainment
        return _sections[3].rows;
      case 5: // Interior
        return _sections[4].rows;
      case 6: // Exterior
        return _sections[5].rows;
      default:
        return [];
    }
  }

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
              height: statusBarHeight,
              color: Colors.white,
            ),
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildCarHeader(),
                    _buildTabsAndTable(),
                    _buildRentBanner(),
                    ..._sections.map((s) => _buildAccordionSection(s)),
                    _buildLatestNews(),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(),
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
            child: Icon(Icons.arrow_back,
                size: 24.r, color: const Color(0xFF01422D)),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              'Compare Vehicle',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF01442D),
              ),
            ),
          ),
          Icon(Icons.share_outlined,
              size: 22.r, color: const Color(0xFF01422D)),
        ],
      ),
    );
  }

  // ── Car Header ────────────────────────────────────────────────────────────
  Widget _buildCarHeader() {
    final double bgHeight = 85.h;
    final double imgHeight = 135.h;
    final double stackHeight = imgHeight;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: stackHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Background halves
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: bgHeight,
                child: Row(
                  children: [
                    Expanded(child: Container(color: const Color(0xFFEB4D4D))),
                    Expanded(child: Container(color: const Color(0xFF4D4C4C))),
                  ],
                ),
              ),
              // Heart toggle
              Positioned(
                top: 8.h,
                right: 15.w,
                child: GestureDetector(
                  onTap: () => setState(() => _isFavorite = !_isFavorite),
                  child: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    size: 20.r,
                    color: _isFavorite ? Colors.red : Colors.white,
                  ),
                ),
              ),
              // Car images
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: imgHeight,
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 10.w, right: 5.w),
                        child: Image.asset(
                          'assets/compare_image/alpha_ags.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 5.w, right: 10.w),
                        child: Image.asset(
                          'assets/compare_image/tata_curvv.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Car name labels
        Row(
          children: [
            Expanded(child: _buildCarNameLabel(widget.car1)),
            Expanded(child: _buildCarNameLabel(widget.car2)),
          ],
        ),
      ],
    );
  }

  Widget _buildCarNameLabel(SelectedCar car) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            TextSpan(
              text: '${car.brand} ',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14.5.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            TextSpan(
              text: car.model,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tabs (outside) + Table (separate below) ───────────────────────────────
  Widget _buildTabsAndTable() {
    final rows = _getTabRows();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Horizontally scrollable gradient tab bar — standalone ──
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFFFFFFFF), Color(0xFFFFEAA4)],
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_tabs.length, (i) {
                  return _buildTabChip(_tabs[i], _selectedTabIndex == i, i);
                }),
              ),
            ),
          ),

          SizedBox(height: 14.h),

          // ── Table — separate container with border ──
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFF9A9A9A), width: 1),
              ),
              child: Column(
                children: rows.asMap().entries.map((entry) {
                  final i = entry.key;
                  final row = entry.value;
                  final isLast = i == rows.length - 1;
                  final isPriceRow = row.label == 'Price';
                  return _buildTableRow(
                    label: row.label,
                    val1: row.val1,
                    val2: row.val2,
                    isLast: isLast,
                    isPriceRow: isPriceRow,
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabChip(String label, bool selected, int index) {
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? const Color(0xFF742B88) : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Text(label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13.5.sp,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildTableRow({
    required String label,
    required String val1,
    required String val2,
    bool isLast = false,
    bool isPriceRow = false,
  }) {
    final valueStyle = TextStyle(
      fontSize: 12.5.sp,
      fontWeight: FontWeight.w400,
      color: const Color(0xFF040084),
    );
    final labelStyle = TextStyle(
      fontSize: 12.5.sp,
      color: Colors.black,
      fontWeight: FontWeight.w500
    );
    const borderColor = Color(0xFF9A9A9A);

    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
          bottom: BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            SizedBox(
              width: 100.w,
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 6.w, vertical: 10.h),
                child: Text(label, style: labelStyle, maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
            ),
            // Vertical divider
            Container(width: 1, color: borderColor),
            // Val 1
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 8.w, vertical: 10.h),
                child: isPriceRow
                    ? RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '₹ ',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF040084),
                              ),
                            ),
                            TextSpan(text: val1, style: valueStyle),
                          ],
                        ),
                      )
                    : Text(val1, style: valueStyle, textAlign: TextAlign.center),
              ),
            ),
            // Vertical divider
            Container(width: 1, color: borderColor),
            // Val 2
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 8.w, vertical: 10.h),
                child: isPriceRow
                    ? RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '₹ ',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF040084),
                              ),
                            ),
                            TextSpan(text: val2, style: valueStyle),
                          ],
                        ),
                      )
                    : Text(val2, style: valueStyle, textAlign: TextAlign.center),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRentBanner() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h),
      child: ClipRRect(
        child: SizedBox(
          height: 140.h,
          width: double.infinity,
          child: Image.asset('assets/home_image/rent_banner.png',
              fit: BoxFit.cover),
        ),
      ),
    );
  }

  // ── Accordion sections ────────────────────────────────────────────────────
  Widget _buildAccordionSection(_SpecSection section) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFFACA9A9)
        ),
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () =>
                setState(() => section.isExpanded = !section.isExpanded),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    section.title,
                    style: TextStyle(
                      fontSize: 14.5.sp,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  Icon(
                    section.isExpanded ? Icons.remove : Icons.add,
                    color: Colors.black,
                    size: 20.r,
                  ),
                ],
              ),
            ),
          ),
          if (section.isExpanded) ...[
            const Divider(height: 1, thickness: 1, color: Color(0xFFACA9A9)),
            Container(
              margin: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFCAC1C1)),
                borderRadius: BorderRadius.circular(5.r),
              ),
              child: Column(
                children: section.rows.asMap().entries.map((entry) {
                  final i = entry.key;
                  final row = entry.value;
                  final isLast = i == section.rows.length - 1;
                  return Column(
                    children: [
                      IntrinsicHeight(
                        child: Row(
                          children: [
                            SizedBox(
                              width: 110.w,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 8.h),
                                child: Text(
                                  row.label,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12.5.sp,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF808080),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                                width: 1, color: const Color(0xFFCAC1C1)),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 8.h),
                                child: Text(
                                  row.val1,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12.5.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                                width: 1, color: const Color(0xFFCAC1C1)),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 8.h),
                                child: Text(
                                  row.val2,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12.5.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isLast)
                        const Divider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xFFCAC1C1)),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Latest News ──────────────────────────────────────────────────────────
  Widget _buildLatestNews() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 10.h),
          child: Text(
            'Latest News & Updates',
            style: TextStyle(fontSize: 15.5.sp, fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(
          height: 195.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            children: [
              _buildNewsCard(
                'assets/compare_image/suzuki_vitara.png',
                'The Maruti Suzuki e VITARA is equipped with an armada of safety features.',
              ),
              _buildNewsCard(
                'assets/compare_image/suzuki_jeep.png',
                'The Maruti Suzuki Jimmy is equipped with an armada of safety features.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNewsCard(String imagePath, String text) {
    return Container(
      width: 210.w,
      margin: EdgeInsets.only(right: 14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
            color: const Color(0xFFC4BEBE)),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
            BorderRadius.vertical(top: Radius.circular(8.r)),
            child: Image.asset(
              imagePath,
              height: 85.h,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 85.h,
                color: Colors.grey.shade200,
                child: Icon(Icons.directions_car, size: 36.r, color: Colors.grey),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: TextStyle(fontSize: 11.sp, height: 1.4, fontWeight: FontWeight.w500),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6.h),
                Text(
                  'Learn More......',
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    color: const Color(0xFF742B88),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom nav ───────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    const selectedIndex = 3;
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
          height: 60.h,
          child: Row(
            children: List.generate(items.length, (i) {
              final isSelected = selectedIndex == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (i == 3) {
                      Navigator.pop(context);
                    } else {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HomeScreen(initialIndex: i),
                        ),
                        (route) => false,
                      );
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 4.h),
                      Image.asset(
                        items[i]['image'] as String,
                        width: isSelected ? 26.r : 22.r,
                        height: isSelected ? 26.r : 22.r,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        items[i]['label'] as String,
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          color: isSelected ? Colors.white : Colors.white60,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Container(
                        height: 3.h,
                        width: isSelected ? 36.w : 0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2.r),
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