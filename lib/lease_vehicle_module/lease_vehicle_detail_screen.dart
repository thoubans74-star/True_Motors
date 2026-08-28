import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'lease_vehicle_quote_screen.dart';

class LeaseVehicleDetailScreen extends StatefulWidget {
  final Map<String, dynamic> car;

  const LeaseVehicleDetailScreen({super.key, required this.car});

  @override
  State<LeaseVehicleDetailScreen> createState() =>
      _LeaseVehicleDetailScreenState();
}

class _LeaseVehicleDetailScreenState extends State<LeaseVehicleDetailScreen> {
  int _currentImageIndex = 0;
  bool _isFavorite = false;

  final List<String> _carImages = [
    'assets/lease_image/hyundai.png',
    'assets/lease_image/hyundai.png',
    'assets/lease_image/hyundai.png',
  ];

  final List<Map<String, dynamic>> _features = [
    {'icon': 'assets/my_booking/petrol.png', 'label': 'Petrol'},
    {'icon': 'assets/my_booking/manual.png', 'label': 'Manual'},
    {'icon': 'assets/my_booking/seats.png', 'label': '5 Seats'},
  ];

  final List<String> _checkFeatures = [
    'Crusie Control',
    'Android Auto',
    'GPS system',
    'Air Conditioning',
  ];

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.car['isFavorite'] ?? false;
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
            // AppBar
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
                    SizedBox(height: 16.h),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        'Lease Vehicle By True Motors',
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
                      child: _buildImageSlider(),
                    ),
                    SizedBox(height: 15.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                widget.car['name'] ?? 'Hyundai Creta',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isFavorite = !_isFavorite;
                                  });
                                },
                                child: Icon(
                                  _isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: _isFavorite
                                      ? const Color(0xFFBE000C)
                                      : const Color(0xFF5F6368),
                                  size: 24.r,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Icon(Icons.share_outlined,
                                  color: Colors.black, size: 24.r),
                            ],
                          ),

                          SizedBox(height: 8.h),

                          Row(
                            children: [
                              Image.asset(
                                'assets/lease_image/location.png',
                                width: 22.r,
                                height: 22.r,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                widget.car['location'] ?? 'Coimbatore',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: const Color(0xFF003399),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              Icon(Icons.star_border_purple500,
                                  color: const Color(0xFFFFC107), size: 22.r),
                              SizedBox(width: 4.w),
                              Text(
                                '4.5/5',
                                style: TextStyle(
                                  fontSize: 13.5.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16.h),

                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Features',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),

                          SizedBox(height: 12.h),
                          _buildFeatureChips(),
                          SizedBox(height: 16.h),
                          _buildCheckFeatures(),
                          SizedBox(height: 18.h),

                          Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),

                          SizedBox(height: 8.h),

                          Text(
                            'Experience the perfect blend of style, space, and performance with the Hyundai Creta. Ideal for city rides and weekend getaways, this premium SUV offers a smooth drive, advanced safety features, and a commanding road presence.',
                            style: TextStyle(
                              fontSize: 13.5.sp,
                              color: const Color(0xFF5B5B5B),
                              height: 1.5,
                            ),
                            textAlign: TextAlign.justify,
                          ),

                          SizedBox(height: 10.h),
                          const Divider(color: Color(0xFF8B8B8B)),
                          SizedBox(height: 8.h),

                          Text(
                            'Owner Info',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),

                          SizedBox(height: 12.h),
                          _buildOwnerInfo(),
                          SizedBox(height: 16.h),
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: const Color(0xFFB5B4B4)),
                      ),
                      padding: EdgeInsets.all(16.w),
                      child: _buildPaymentDetailsCard(),
                    ),

                    SizedBox(height: 20.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.w),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  LeaseVehicleQuoteScreen(car: widget.car),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF005F65),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Center(
                            child: Text(
                              'Request a quote',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSlider() {
    return Column(
      children: [
        SizedBox(
          height: 160.h,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: PageView.builder(
              itemCount: _carImages.length,
              onPageChanged: (index) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return Image.asset(
                  _carImages[index],
                  width: double.infinity,
                  height: 160.h,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _carImages.length,
                (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              width: _currentImageIndex == index ? 28.w : 8.w,
              height: 8.h,
              decoration: BoxDecoration(
                color: _currentImageIndex == index
                    ? const Color(0xFF00558B)
                    : const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureChips() {
    return Wrap(
      spacing: 20.0.w,
      runSpacing: 10.0.h,
      children: _features.map((feature) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              feature['icon'],
              width: 18.r,
              height: 18.r,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 6.w),
            Text(
              feature['label'],
              style: TextStyle(
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildCheckFeatures() {
    return Wrap(
      spacing: 24.0.w,
      runSpacing: 8.0.h,
      children: [
        _checkItem('Crusie Control'),
        _checkItem('Android Auto'),
        _checkItem('GPS system'),
        _checkItem('Air Conditioning'),
      ],
    );
  }

  Widget _checkItem(String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check, color: const Color(0xFF2AA644), size: 18.r),
        SizedBox(width: 6.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.black87,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildOwnerInfo() {
    return Row(
      children: [
        CircleAvatar(
          radius: 26.r,
          backgroundImage:
          const AssetImage('assets/lease_image/owner_avatar.png'),
          onBackgroundImageError: (_, __) {},
          backgroundColor: const Color(0xFFF2F2F2),
          child: Icon(Icons.person, size: 30.r, color: Colors.grey),
        ),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Harish',
              style: TextStyle(
                fontSize: 14.5.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Icon(Icons.star_border_purple500, color: const Color(0xFFFFC107), size: 16.r),
                SizedBox(width: 4.w),
                Text(
                  '4.5/5  ',
                  style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w500),
                ),
                Text(
                  '(180 Review)',
                  style: TextStyle(fontSize: 13.5.sp, color: Colors.black),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              'Joined 8 Month Ago',
              style: TextStyle(fontSize: 13.5.sp, color: Colors.black),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentDetailsCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Car Name: Creta',
              style: TextStyle(
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w600
              ),
            ),
          ],
        ),

        SizedBox(height: 8.h),
        Text(
          'Location',
          style: TextStyle(
            fontSize: 13.5.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          '123, Parker Street, Rogers Road, Wanda, \nNowhere - XRT589',
          style: TextStyle(
            fontSize: 13.sp,
            color: const Color(0xFF3C3C3C),
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          'Payment Details',
          style: TextStyle(
            fontSize: 13.5.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),

        SizedBox(height: 10.h),

        _paymentRow('Base Price / Day', '₹ 1,400'),
        SizedBox(height: 6.h),
        _paymentRow('Delivery & pickup charge', '₹ 500'),
        SizedBox(height: 6.h),
        _paymentRow('Refundable security deposit', '₹ 10,000'),

        SizedBox(height: 10.h),

        _paymentRow('Total', '₹ 12,650', isBold: true),
      ],
    );
  }

  Widget _paymentRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.5.sp,
              color: Colors.black,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w400,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13.5.sp,
            color: Colors.black,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}