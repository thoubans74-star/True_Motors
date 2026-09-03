import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:true_motors/provider/subscription_provider.dart';


// ─── Subscription Screen ──────────────────────────────────────────────────────

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _isYearly = false; // false = Monthly, true = Yearly

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SubscriptionProvider>(context, listen: false).fetchPlans();
    });
  }

  _PlanData _mapToPlanData(SubscriptionPlan plan) {
    final nameLower = plan.planName.toLowerCase();
    
    // Default styling (Free style)
    String tagline = 'Get Started for free';
    _ButtonStyle buttonStyle = _ButtonStyle.outlined;
    String imageAsset = 'assets/subscription/month.png';
    Color iconColor = const Color(0xFF5F6368);
    Color backgroundColor = const Color(0xFFF1ECFD);
    bool isMostPopular = false;
    bool isCurrent = false;

    if (nameLower.contains('premium')) {
      tagline = 'Sell faster with more exposure';
      buttonStyle = _ButtonStyle.purple;
      imageAsset = 'assets/subscription/premium.png';
      iconColor = const Color(0xFF742B88);
      backgroundColor = const Color(0xFF6939DF);
      isMostPopular = true;
    } else if (nameLower.contains('dealer')) {
      tagline = 'For Dealers & Businesses';
      buttonStyle = _ButtonStyle.orange;
      imageAsset = 'assets/subscription/dealer.png';
      iconColor = const Color(0xFFE65100);
      backgroundColor = const Color(0xFFF78B01);
    } else if (nameLower.contains('free')) {
      isCurrent = true;
    }

    final List<String> features = [
      '${plan.listings} Active Listings',
      '${plan.coins} Coins Included',

    ];

    return _PlanData(
      name: plan.planName,
      tagline: tagline,
      price: plan.price.toString(),
      period: plan.validity == 30 ? '/month' : '/yearly',
      originalPrice: null,
      isMostPopular: isMostPopular,
      isCurrent: isCurrent,
      buttonLabel: isCurrent ? 'Current Plan' : 'Choose ${plan.planName}',
      buttonStyle: buttonStyle,
      imageAsset: imageAsset,
      iconColor: iconColor,
      backgroundColor: backgroundColor,
      features: features,
    );
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
        backgroundColor: const Color(0xFFFFFFFF),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              height: statusBarHeight,
              color: Colors.white,
            ),
            Expanded(
              child: SafeArea(
                top: false,
                child: Consumer<SubscriptionProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (provider.errorMessage != null) {
                      return Center(child: Text(provider.errorMessage!));
                    }

                    final dynamicPlans = _isYearly ? provider.yearlyPlans : provider.monthlyPlans;
                    final activePlans = dynamicPlans.map((p) => _mapToPlanData(p)).toList();

                    return Column(
                      children: [
                        _buildTopBar(context),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                // ── Banner ──────────────────────────────────────────────
                                _buildBanner(),
                                SizedBox(height: 5.h),

                                // ── Monthly / Yearly toggle ─────────────────────────────
                                _buildToggle(),
                                SizedBox(height: 18.h),

                                // ── Plan label ─────────────────────────────────────────
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Choose your Plan',
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF000000),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10.h),

                                // ── Plan cards ─────────────────────────────────────────
                                ...activePlans.map((plan) => _buildPlanCard(plan)),
                                SizedBox(height: 10.h),

                                // ── All Plans Include section ───────────────────────────
                                _buildAllPlansInclude(),
                                SizedBox(height: 10.h),

                                // ── Secure payment note ─────────────────────────────────
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.lock_outline,
                                          size: 14.r, color: const Color(0xFF3C3C3C)),
                                      SizedBox(width: 6.w),
                                      Text(
                                        '100% Secure Payment',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: const Color(0xFF3C3C3C),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 20.h),
                              ],
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

  // ── Top bar ─────────────────────────────────────────────────────────────────

  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: const Color(0xFFFBF8F8),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back,
                size: 24.r, color: const Color(0xFF01442D)),
          ),
          SizedBox(width: 12.w),
          Text(
            'Subscription',
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

  // ── Banner ──────────────────────────────────────────────────────────────────

  Widget _buildBanner() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Image.asset(
          'assets/drawer_image/subscription.png',
          height: 140.h,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // ── Monthly / Yearly toggle ──────────────────────────────────────────────────

  Widget _buildToggle() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(
            color: const Color(0xFF6E6E6E),
          ),
        ),
        child: Row(
          children: [
            _toggleOption('Monthly', !_isYearly),
            _toggleOption('Yearly', _isYearly),
          ],
        ),
      ),
    );
  }

  Widget _toggleOption(String label, bool isActive) {
    return Expanded(
      child: GestureDetector(
        onTap: () =>
            setState(() => _isYearly = label == 'Yearly'),
        child: Container(
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF005F65) : Colors.transparent,
            borderRadius: BorderRadius.circular(26.r),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: isActive? FontWeight.w700 : FontWeight.w500,
              color: isActive ? Colors.white : const Color(0xFF000000),
            ),
          ),
        ),
      ),
    );
  }

  // ── Plan card ────────────────────────────────────────────────────────────────

  Widget _buildPlanCard(_PlanData plan) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: const Color(0xFFCECECE),
                width: 1,
              ),
            ),
            padding: EdgeInsets.fromLTRB(10.w, 15.h, 10.w, 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Plan header row ───────────────────────────────────────
                Row(
                  children: [
                    // Icon
                    Container(
                      width: 38.r,
                      height: 38.r,
                      decoration: BoxDecoration(
                        color: plan.backgroundColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Image.asset(
                          plan.imageAsset,
                          width: 22.r,
                          height: 22.r,
                          errorBuilder: (_, __, ___) => Icon(
                            plan.name == 'Free'
                                ? Icons.flash_on
                                : plan.name == 'Premium'
                                ? Icons.workspace_premium
                                : Icons.business_center,
                            size: 20.r,
                            color: plan.iconColor,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.name,
                            style: TextStyle(
                              fontSize: 15.5.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF000000),
                            ),
                          ),
                          Text(
                            plan.tagline,
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              color: const Color(0xFFB1B1B1),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Current Plan badge (only for Free)
                    if (plan.isCurrent)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 5.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF3FD),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          'Current Plan',
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF003399),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 12.h),

                // ── Price row ─────────────────────────────────────────────
                Row(
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Image.asset('assets/my_booking/rupee.png',
                      height: 12.h,
                      color: const Color(0xFF000000),
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      '${plan.price} ',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF000000),
                      ),
                    ),
                    Text(
                      plan.period,
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: const Color(0xFF000000),
                      ),
                    ),
                    if (plan.originalPrice != null) ...[
                      SizedBox(width: 8.w),
                      Row(
                        children: [
                          Image.asset('assets/my_booking/rupee.png',
                            height: 10.h,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            plan.originalPrice!,
                            style: TextStyle(
                              fontSize: 12.5.sp,
                              color: const Color(0xFF5F6368),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 12.h),

                // ── Features list ─────────────────────────────────────────
                SizedBox(
                  height: (plan.features.length > 3) ? 60.h : 28.h,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: plan.features.length,
                    gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 10,
                      crossAxisSpacing: 2.w,
                      mainAxisSpacing: 4.h,
                    ),
                    itemBuilder: (context, index) {
                      return _featureChip(plan.features[index]);
                    },
                  ),
                ),
                SizedBox(height: 10.h),

                // ── Action button ─────────────────────────────────────────
                if (!plan.isCurrent) _buildPlanButton(plan),
              ],
            ),
          ),

          // ── MOST POPULAR badge ────────────────────────────────────────────
          if (plan.isMostPopular)
            Positioned(
              top: -12.h,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 14.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6A3BDF),
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                  child: Text(
                    'MOST POPULAR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _featureChip(String label) {
    return Row(
      children: [
        Icon(
          Icons.check_circle_outline,
          size: 14.r,
          color: const Color(0xFF01422D),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.sp,
              color: const Color(0xFF5F6368),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanButton(_PlanData plan) {
    if (plan.buttonStyle == _ButtonStyle.outlined) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFF005F65)),
            padding: EdgeInsets.symmetric(vertical: 12.h),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r)),
          ),
          child: Text(
            plan.buttonLabel,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF005F65),
            ),
          ),
        ),
      );
    }

    final Color btnColor = plan.buttonStyle == _ButtonStyle.purple
        ? const Color(0xFF6939DF)
        : const Color(0xFFF68E01);

    return Center(
      child: SizedBox(
        width: 260.w,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: btnColor,
            padding: EdgeInsets.symmetric(vertical: 12.h),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r)),
            elevation: 0,
          ),
          child: Text(
            plan.buttonLabel,
            style: TextStyle(
              fontSize: 14.5.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // ── All Plans Include ────────────────────────────────────────────────────────

  Widget _buildAllPlansInclude() {
    final benefits = [
      'Secure\nPayments',
      'Verified\nusers',
      'Data\nProtection',
      '24/7\nSupport',
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          Text(
            'All Plans Include',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF000000),
            ),
          ),
          SizedBox(height: 16.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: benefits
                .map((title) => _benefitCard(title))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _benefitCard(String title) {
    return Container(
      width: 75.w,
      height: 55.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            offset: Offset(0, 4),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Center(
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11.5.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF000000),
          ),
        ),
      ),
    );
  }
}

// ─── Data Models ──────────────────────────────────────────────────────────────

enum _ButtonStyle { outlined, purple, orange }

class _PlanData {
  final String name;
  final String tagline;
  final String price;
  final String period;
  final String? originalPrice;
  final bool isMostPopular;
  final bool isCurrent;
  final String buttonLabel;
  final _ButtonStyle buttonStyle;
  final String imageAsset;
  final Color iconColor;
  final Color backgroundColor;
  final List<String> features;

  const _PlanData({
    required this.name,
    required this.tagline,
    required this.price,
    required this.period,
    this.originalPrice,
    required this.isMostPopular,
    required this.isCurrent,
    required this.buttonLabel,
    required this.buttonStyle,
    required this.imageAsset,
    required this.iconColor,
    required this.backgroundColor,
    required this.features,
  });
}
