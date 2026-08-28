import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:true_motors/login_module/login_screen.dart';


class OnboardScreen extends StatefulWidget {
  const OnboardScreen({super.key});

  @override
  State<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> {
  final PageController _controller = PageController();
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final primaryColor = const Color(0xFF005F65);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // PageView (occupies full screen)
          PageView(
            controller: _controller,
            onPageChanged: (value) {
              setState(() {
                currentPage = value;
              });
            },
            children: [
              SingleChildScrollView(child: _buildFirstPage(width, height, primaryColor)),
              SingleChildScrollView(child: _buildSecondPage(width, height, primaryColor)),
            ],
          ),

          // Skip Button (Top Right)
          if (currentPage == 0)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8.h,
              right: 20.w,
              child: InkWell(
                onTap: () {
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Skip',
                      style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          color: primaryColor),
                    ),
                    SizedBox(width: 4.w),
                    Icon(Icons.arrow_forward_ios, size: 14.r, color: primaryColor)
                  ],
                ),
              ),
            ),

          // Bottom Controls (Page Indicator + Swipe Button)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              bottom: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Page Indicators
                  if (currentPage == 0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(2, (index) {
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 4.w),
                          width: currentPage == index ? 30.w : 10.w,
                          height: 10.h,
                          decoration: BoxDecoration(
                              color: currentPage == index ? primaryColor : const Color(0xFFD9D9D9),
                              borderRadius: BorderRadius.circular(10.r)),
                        );
                      }),
                    ),

                  SizedBox(height: 8.h),

                  // Swipe >> or Swipe to start
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52.h,
                      child: currentPage == 0
                          ? Center(
                              child: InkWell(
                                onTap: () {
                                  _controller.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut,
                                  );
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Swipe',
                                      style: TextStyle(
                                          color: primaryColor,
                                          fontSize: 20.sp,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Icon(Icons.keyboard_double_arrow_right, color: primaryColor, size: 28.r),
                                  ],
                                ),
                              ),
                            )
                          : SwipeToStartButton(
                              primaryColor: primaryColor,
                              buttonHeight: 52.h,
                              onSwipeRight: () {
                                Navigator.pushReplacement(
                                    context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                              },
                            ),
                    ),
                  ),
                  SizedBox(height: 20.h)
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFirstPage(double width, double height, Color primaryColor) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20.h,
        bottom: 90.h,
      ),
      child: Column(
        children: [
          // Logo
          Image.asset(
            'assets/login_image/true_motors_logo.png',
            height: 60.h,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                Text("TRUE MOTORS", style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: const Color(0xFF005F65))),
          ),
          SizedBox(height: 12.h),
          
          // Title
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, fontFamily: 'Poppins', height: 1.3),
              children: [
                const TextSpan(text: 'All Your Vehicle Needs,\n', style: TextStyle(color: Color(0xFF0A1931))),
                const TextSpan(text: 'All in One ', style: TextStyle(color: Color(0xFF1E3A8A))),
                TextSpan(text: 'Place', style: TextStyle(color: primaryColor)),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Central Graphic Area
          SizedBox(
            height: 320.h,
            width: 340.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Gradient Ring
                Container(
                  width: 280.w,
                  height: 280.h,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        Color(0xFF4C66C3),
                        Color(0xFFC77B63),
                        Color(0xFF4CAF50),
                        Color(0xFF1E3A8A),
                        Color(0xFF4C66C3),
                      ],
                    )
                  ),
                  child: Center(
                    child: Container(
                      width: 264.w,
                      height: 264.h,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                
                // Central Car Image (now perfectly centered inside the circle)
                Align(
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/onboarding_image/onboard_main.png',
                    width: 240.w,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(Icons.directions_car, size: 90.r, color: primaryColor),
                  ),
                ),

                // Floating Cards perfectly placed on the ring
                Align(
                  alignment: const Alignment(0, -1.08),
                  child: _buildFloatingCard('Buy', 'assets/onboarding_image/onboard_buy.png', Colors.green, width),
                ),
                Align(
                  alignment: const Alignment(-1.05, -0.32),
                  child: _buildFloatingCard('Sell', 'assets/onboarding_image/onboard_sell.png', const Color(0xFF1E3A8A), width),
                ),
                Align(
                  alignment: const Alignment(1.05, -0.32),
                  child: _buildFloatingCard('Compare', '', const Color(0xFF1E3A8A), width),
                ),
                Align(
                  alignment: const Alignment(-0.68, 0.85),
                  child: _buildFloatingCard('Lease', 'assets/home_image/lease.png', Colors.orange, width),
                ),
                Align(
                  alignment: const Alignment(0.68, 0.85),
                  child: _buildFloatingCard('Rent','assets/home_image/rent.png', Colors.teal, width),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Bottom Features
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFeatureImage('assets/onboarding_image/verified 1.png', 'Verified Listings', '100% Trusted'),
                _buildFeatureImage('assets/onboarding_image/badge 1.png', 'Best Deals', 'Every Day'),
                _buildFeatureImage('assets/onboarding_image/online-support 1.png', '24/7 Support', "We're Here"),
              ],
            ),
          ),
          
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildFloatingCard(String title, String imagePath, Color titleColor, double width) {
    return Container(
      width: 85.w,
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 2.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          title == 'Compare'
              ? SizedBox(
                  width: 52.w,
                  height: 40.h,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        right: -4.w,
                        top: 2.h,
                        child: Image.asset('assets/onboarding_image/compare_2.png', width: 30.w, fit: BoxFit.contain, errorBuilder: (c,e,s) => const SizedBox()),
                      ),
                      Positioned(
                        left: -2.w,
                        bottom: 0,
                        child: Image.asset('assets/onboarding_image/compare_1.png', width: 36.w, fit: BoxFit.contain, errorBuilder: (c,e,s) => Icon(Icons.directions_car, color: titleColor, size: 26.r)),
                      ),
                    ],
                  ),
                )
              : Image.asset(imagePath, width: 44.w, height: 44.h, fit: BoxFit.contain, errorBuilder: (c,e,s) => Icon(Icons.image, color: titleColor, size: 44.r)),
          SizedBox(height: 4.h),
          Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.sp, fontFamily: 'Poppins', color: titleColor)),
        ],
      ),
    );
  }

  Widget _buildFeatureImage(String imagePath, String title, String subtitle) {
    return Column(
      children: [
        Image.asset(
          imagePath,
          width: 40.w,
          height: 40.h,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported, size: 36.r),
        ),
        SizedBox(height: 6.h),
        Text(title, style: TextStyle(fontSize: 11.sp, fontFamily: 'Poppins', color: Colors.black, fontWeight: FontWeight.bold)),
        SizedBox(height: 2.h),
        Text(subtitle, style: TextStyle(fontSize: 10.sp, fontFamily: 'Poppins', color: Colors.black87)),
      ],
    );
  }

  Widget _buildSecondPage(double width, double height, Color primaryColor) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Column(
          children: [
            // Main Image (Dealership)
            Image.asset(
              'assets/onboarding_image/onboard_2.jpg',
              width: width,
              fit: BoxFit.fitWidth,
              errorBuilder: (context, error, stackTrace) => Icon(Icons.store, size: 90.r, color: primaryColor),
            ),
          SizedBox(height: 16.h),

          // Cards
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                _buildInfoCard(
                  icon: Icons.search,
                  iconColor: const Color(0xFF0D6EFD), // Blue
                  title: 'Find Verified Dealers',
                  subtitle: 'Connect with trusted dealers\nnear you.',
                ),
                SizedBox(height: 8.h),
                _buildInfoCard(
                  icon: Icons.verified_user_outlined,
                  iconColor: const Color(0xFF00BFA5), // Teal/Green
                  title: 'Verified & Reliable',
                  subtitle: 'All dealers are verified for your\nsafety and confidence.',
                ),
                SizedBox(height: 8.h),
                _buildInfoCard(
                  icon: Icons.group,
                  iconColor: const Color(0xFF6610F2), // Purple
                  title: 'Better Deals, Better Choice',
                  subtitle: 'Compare offers and choose\nthe best for you.',
                ),
              ],
            ),
          ),
          SizedBox(height: 90.h),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required IconData icon, required Color iconColor, required String title, required String subtitle}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46.r,
            height: 46.r,
            decoration: BoxDecoration(
              color: iconColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 26.r),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    color: Colors.black54,
                    fontFamily: 'Poppins',
                    height: 1.3,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class SwipeToStartButton extends StatefulWidget {
  final VoidCallback onSwipeRight;
  final Color primaryColor;
  final double buttonHeight;

  const SwipeToStartButton({
    Key? key,
    required this.onSwipeRight,
    required this.primaryColor,
    required this.buttonHeight,
  }) : super(key: key);

  @override
  _SwipeToStartButtonState createState() => _SwipeToStartButtonState();
}

class _SwipeToStartButtonState extends State<SwipeToStartButton> {
  double _dragPosition = 0.0;
  bool _isSwiped = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxDrag = constraints.maxWidth - widget.buttonHeight;
        return Container(
          height: widget.buttonHeight,
          decoration: BoxDecoration(
            color: widget.primaryColor,
            borderRadius: BorderRadius.circular(widget.buttonHeight / 2),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                'Swipe to start',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15.sp,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                ),
              ),
              Positioned(
                left: _dragPosition + 6.w,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    if (!_isSwiped) {
                      setState(() {
                        _dragPosition += details.delta.dx;
                        if (_dragPosition < 0) _dragPosition = 0;
                        if (_dragPosition > maxDrag) {
                          _dragPosition = maxDrag;
                          _isSwiped = true;
                          widget.onSwipeRight();
                        }
                      });
                    }
                  },
                  onHorizontalDragEnd: (details) {
                    if (!_isSwiped) {
                      setState(() {
                        _dragPosition = 0.0;
                      });
                    }
                  },
                  child: Container(
                    width: widget.buttonHeight - 12.h,
                    height: widget.buttonHeight - 12.h,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.keyboard_double_arrow_right, color: widget.primaryColor, size: 24.r),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}