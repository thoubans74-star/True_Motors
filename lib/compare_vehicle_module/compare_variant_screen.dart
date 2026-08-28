import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:true_motors/app_drawer_module/compare_vehicle_screen.dart';

// ── Variant data per brand+model ───────────────────────────────────────────────
class _VariantData {
  final String variant;
  final String fuelType;
  final String imagePath;

  const _VariantData({
    required this.variant,
    required this.fuelType,
    required this.imagePath,
  });
}

// ── Static variant catalogue ───────────────────────────────────────────────────
// Add more brand/model combos here as needed.
final Map<String, List<_VariantData>> _variantCatalogue = {
  'Maruti Suzuki_Baleno': [
    _VariantData(
      variant: 'Alpha AGS',
      fuelType: 'Petrol',
      imagePath: 'assets/compare_image/baleno_alpha_ags.png',
    ),
    _VariantData(
      variant: 'Alpha MT',
      fuelType: 'Petrol',
      imagePath: 'assets/compare_image/baleno_alpha_mt.png',
    ),
    _VariantData(
      variant: 'Zeta CNG MT',
      fuelType: 'CNG',
      imagePath: 'assets/compare_image/baleno_zeta_cng.png',
    ),
    _VariantData(
      variant: 'Delta MT',
      fuelType: 'Petrol',
      imagePath: 'assets/compare_image/baleno_delta_mt.png',
    ),
  ],
  'Maruti Suzuki_Swift': [
    _VariantData(
      variant: 'VXI AMT',
      fuelType: 'Petrol',
      imagePath: 'assets/compare_image/swift.png',
    ),
    _VariantData(
      variant: 'ZXI+',
      fuelType: 'Petrol',
      imagePath: 'assets/compare_image/swift.png',
    ),
  ],
  'Maruti Suzuki_Brezza': [
    _VariantData(
      variant: 'LXI',
      fuelType: 'Petrol',
      imagePath: 'assets/compare_image/swift.png',
    ),
    _VariantData(
      variant: 'ZXI+',
      fuelType: 'Petrol',
      imagePath: 'assets/compare_image/swift.png',
    ),
  ],
  'TATA_Curvv': [
    _VariantData(
      variant: 'Smart',
      fuelType: 'Petrol',
      imagePath: 'assets/compare_image/tata_curvv_smart.png',
    ),
    _VariantData(
      variant: 'Pure +',
      fuelType: 'Petrol',
      imagePath: 'assets/compare_image/tata_curvv_pure.png',
    ),
    _VariantData(
      variant: 'Creative S',
      fuelType: 'CNG',
      imagePath: 'assets/compare_image/tata_curvv_creative.png',
    ),
    _VariantData(
      variant: 'Accomplished S',
      fuelType: 'CNG',
      imagePath: 'assets/compare_image/tata_curvv_accomplished.png',
    ),
  ],
  'TATA_Nexon': [
    _VariantData(
      variant: 'Smart',
      fuelType: 'Petrol',
      imagePath: 'assets/compare_image/hyundai.png',
    ),
    _VariantData(
      variant: 'Pure',
      fuelType: 'Diesel',
      imagePath: 'assets/compare_image/hyundai.png',
    ),
  ],
};

// ── Fallback variants when specific data isn't in the catalogue ───────────────
List<_VariantData> _fallbackVariants(String brand, String model) => [
  _VariantData(
    variant: 'Base Variant',
    fuelType: 'Petrol',
    imagePath: 'assets/compare_image/swift.png',
  ),
  _VariantData(
    variant: 'Mid Variant',
    fuelType: 'Petrol',
    imagePath: 'assets/compare_image/swift.png',
  ),
  _VariantData(
    variant: 'Top Variant',
    fuelType: 'Diesel',
    imagePath: 'assets/compare_image/swift.png',
  ),
];

class CompareVariantScreen extends StatefulWidget {
  final int slot;
  final String brand;
  final String model;

  const CompareVariantScreen({
    super.key,
    required this.slot,
    required this.brand,
    required this.model,
  });

  @override
  State<CompareVariantScreen> createState() => _CompareVariantScreenState();
}

class _CompareVariantScreenState extends State<CompareVariantScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<_VariantData> get _variants {
    final key = '${widget.brand}_${widget.model}';
    return _variantCatalogue[key] ??
        _fallbackVariants(widget.brand, widget.model);
  }

  List<_VariantData> get _filtered {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return _variants;
    return _variants
        .where((v) =>
    v.variant.toLowerCase().contains(q) ||
        v.fuelType.toLowerCase().contains(q))
        .toList();
  }

  void _selectVariant(_VariantData v) {
    final car = SelectedCar(
      brand: widget.brand,
      model: widget.model,
      variant: v.variant,
      fuelType: v.fuelType,
      imagePath: v.imagePath,
    );
    Navigator.pop(context, car);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F3F3),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              height: statusBarHeight,
              color: Colors.white,
            ),

            // ── App bar ──────────────────────────────────────────────────
            Container(
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
                    'Compare Vehicle',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF01442D),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 140.h,
                      child: ClipRRect(
                        child: Image.asset(
                          'assets/compare_image/select_car.jpg',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey.shade200,
                            child: Center(
                              child: Text(
                                'CARS FOR ALL NEEDS',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15.sp),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 5.h),
                          // ── Search bar ───────────────────────────────────────
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: const Color(0xFF01422D),
                                width: 1,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x40000000),
                                  offset: Offset(0, 4),
                                  blurRadius: 4,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (_) => setState(() {}),
                              style: TextStyle(fontSize: 13.5.sp),
                              decoration: InputDecoration(
                                hintText: 'Search variant',
                                hintStyle: TextStyle(
                                    color: const Color(0xFF5F6368), fontSize: 13.5.sp),
                                prefixIcon:
                                Icon(Icons.search, size: 20.r, color: const Color(0xFF5F6368)),
                                border: InputBorder.none,
                                contentPadding:
                                EdgeInsets.symmetric(vertical: 12.h),
                              ),
                            ),
                          ),
                          SizedBox(height: 16.h),

                          // ── Selected brand / model header ────────────────────
                          Text(
                            'Select Variants',
                            style: TextStyle(
                                fontSize: 15.sp, fontWeight: FontWeight.w400),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '${widget.brand} / ${widget.model}',
                            style: TextStyle(
                              fontSize: 13.5.sp,
                              color: const Color(0xFF1B00B5),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 5.h),

                          // ── Divider + variant list ───────────────────────────
                          if (filtered.isEmpty)
                            Padding(
                              padding: EdgeInsets.only(top: 32.h),
                              child: Center(
                                child: Text(
                                  'No variants found',
                                  style: TextStyle(color: Colors.grey, fontSize: 13.5.sp),
                                ),
                              ),
                            )
                          else
                            ...filtered.map((v) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    onTap: () => _selectVariant(v),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 12.h),
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            v.variant,
                                            style: TextStyle(
                                              fontSize: 15.5.sp,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                            ),
                                          ),
                                          SizedBox(height: 2.h),
                                          Text(
                                            v.fuelType,
                                            style: TextStyle(
                                              fontSize: 12.5.sp,
                                              color: const Color(0xFF918A8A),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Divider(
                                      height: 1,
                                      thickness: 1,
                                      color: Colors.black),
                                ],
                              );
                            }).toList(),
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
}