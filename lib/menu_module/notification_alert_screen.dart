import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:shared_preferences/shared_preferences.dart';

class NotificationAlertScreen extends StatefulWidget {
  const NotificationAlertScreen({super.key});

  @override
  State<NotificationAlertScreen> createState() =>
      _NotificationAlertScreenState();
}

class _NotificationAlertScreenState extends State<NotificationAlertScreen> {
  bool _bookingUpdates = false;
  bool _sellerAlerts = false;
  bool _offersPromotions = false;
  bool _accountSecurityAlerts = false;

  static const String _keyBooking = 'notif_booking_updates';
  static const String _keySeller = 'notif_seller_alerts';
  static const String _keyOffers = 'notif_offers_promotions';
  static const String _keyAccount = 'notif_account_security_alerts';

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _bookingUpdates = prefs.getBool(_keyBooking) ?? true;
      _sellerAlerts = prefs.getBool(_keySeller) ?? true;
      _offersPromotions = prefs.getBool(_keyOffers) ?? true;
      _accountSecurityAlerts = prefs.getBool(_keyAccount) ?? true;
    });
  }

  Future<void> _savePref(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Widget _buildAppBar() {
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
          Text(
            'Notifications & Alerts',
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

  // Custom toggle that shows ✓ when ON and ✗ when OFF, matching Figma design
  Widget _buildCustomToggle({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 52.w,
        height: 30.h,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: value
              ? const Color(0xFF6750A4)
              : const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(100.r),
          border: Border.all(
            color: value
                ? const Color(0xFF6750A4)
                : const Color(0xFF6E6E6E),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment:
          value ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Container(
              width: 22.r,
              height: 22.r,
              decoration: BoxDecoration(
                color: value
                    ? Colors.white
                    : const Color(0xFF6E6E6E),
                shape: BoxShape.circle,
              ),
              child: Icon(
                value ? Icons.check : Icons.close,
                size: 15.r,
                color: value
                    ? const Color(0xFF4F378A)
                    : const Color(0xFFDBDBDB),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Each toggle item in its OWN separate white card container
  Widget _buildToggleCard({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.5.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          _buildCustomToggle(value: value, onChanged: onChanged),
        ],
      ),
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
        backgroundColor: const Color(0xFFF5F5F5),
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
                child: Column(
                  children: [
                    _buildAppBar(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notification & Alerts',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              'Stay updated, stay informed.\nGet important updates about your bookings, listings, offers, and account activity — all in one place.',
                              style: TextStyle(
                                fontSize: 13.5.sp,
                                color: Colors.black,
                                height: 1.6,
                              ),
                            ),
                            SizedBox(height: 18.h),
                            // Each item in its own separate container card
                            _buildToggleCard(
                              label: 'Booking Updates',
                              value: _bookingUpdates,
                              onChanged: (v) {
                                setState(() => _bookingUpdates = v);
                                _savePref(_keyBooking, v);
                              },
                            ),
                            _buildToggleCard(
                              label: 'Seller Alerts',
                              value: _sellerAlerts,
                              onChanged: (v) {
                                setState(() => _sellerAlerts = v);
                                _savePref(_keySeller, v);
                              },
                            ),
                            _buildToggleCard(
                              label: 'Offers & Promotions',
                              value: _offersPromotions,
                              onChanged: (v) {
                                setState(() => _offersPromotions = v);
                                _savePref(_keyOffers, v);
                              },
                            ),
                            _buildToggleCard(
                              label: 'Account & Security Alerts',
                              value: _accountSecurityAlerts,
                              onChanged: (v) {
                                setState(() => _accountSecurityAlerts = v);
                                _savePref(_keyAccount, v);
                              },
                            ),
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