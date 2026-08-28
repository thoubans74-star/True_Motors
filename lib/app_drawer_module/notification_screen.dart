import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class NotificationScreenPage extends StatefulWidget {
  const NotificationScreenPage({super.key});

  @override
  State<NotificationScreenPage> createState() => _NotificationScreenPageState();
}

class _NotificationScreenPageState extends State<NotificationScreenPage> {
  int _selectedTab = 0;

  // ── Notification data ──────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _buyNotifications = [
    {
      'badge': 'New Vehicle Alert',
      'badgeColor': Color(0xFFDD4545),
      'message': 'Hyundai Creta 2023 Diesel just listed near you.',
      'time': '30 mins ago',
    },
    {
      'badge': 'Booking Update',
      'badgeColor': Color(0xFFDD4545),
      'message': 'Your test drive for Tata Nexon is confirmed on Aug 3, 10 AM.',
      'time': 'Yesterday',
    },
  ];

  final List<Map<String, dynamic>> _sellNotifications = [
    {
      'badge': 'Enquiry Received',
      'badgeColor': Color(0xFF01422D),
      'message': 'You have 3 new enquiries for your posted vehicle – Honda City 2018.',
      'time': '2 hours ago',
    },
    {
      'badge': 'Booking Update',
      'badgeColor': Color(0xFF01422D),
      'message': 'Your Maruti Baleno listing expires in 2 days. Renew to stay visible.',
      'time': 'Today',
    },
  ];

  final List<Map<String, dynamic>> _rentalNotifications = [];
  final List<Map<String, dynamic>> _offerNotifications = [];
  final List<Map<String, dynamic>> _serviceNotifications = [];
  final List<Map<String, dynamic>> _systemNotifications = [];

  List<Map<String, dynamic>> get _allNotifications => [
    ..._buyNotifications,
    ..._sellNotifications,
    ..._rentalNotifications,
    ..._offerNotifications,
    ..._serviceNotifications,
    ..._systemNotifications,
  ];

  List<Map<String, dynamic>> get _currentNotifications {
    switch (_selectedTab) {
      case 0:
        return _allNotifications;
      case 1:
        return _buyNotifications;
      case 2:
        return _sellNotifications;
      case 3:
        return _rentalNotifications;
      case 4:
        return _offerNotifications;
      case 5:
        return _serviceNotifications;
      case 6:
        return _systemNotifications;
      default:
        return [];
    }
  }

  Widget _buildAppBar() {
    return Container(
      color: Color(0xFFFBF8F8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back,
                size: 24, color: Color(0xFF01422D)),
          ),
          const SizedBox(width: 16),
          const Text(
            'Notification',
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

  Widget _buildTabs() {
    return Container(
      color: Colors.white,
      height: 60,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            _buildTab(0, 'All', Icons.sort),
            _buildTab(1, 'Buy Vehicle'),
            _buildTab(2, 'Sell Vehicle'),
            _buildTab(3, 'Rentals'),
            _buildTab(4, 'Offers & Deals'),
            _buildTab(5, 'Services'),
            _buildTab(6, 'System Alerts'),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(
      int index,
      String title, [
        IconData? icon,
      ]) {
    final isSelected = _selectedTab == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF01422D)
              : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFF005F65),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? Colors.white
                    : const Color(0xFF01422D),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15, top: 5),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 30, 16, 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFCCCCCC),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['message'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    item['time'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF797979),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Badge
          Positioned(
            top: -1,
            left: -1,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: item['badgeColor'],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Text(
                item['badge'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Map<String, dynamic>> items) {
    if (items.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
        ...items.map((item) => _buildNotificationCard(item)).toList(),
        const SizedBox(height: 8),
      ],
    );
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
        backgroundColor: const Color(0xFFFFFFFF),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              height: statusBarHeight,
              color: const Color(0xFF615C5C),
            ),
            Expanded(
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    _buildAppBar(),
                    _buildTabs(),
                    const Divider(height: 7, color: Color(0xFFCCCCCC)),
                    Expanded(
                      child: _currentNotifications.isEmpty
                          ? const Center(
                        child: Text(
                          'No notifications',
                          style: TextStyle(
                            fontSize: 17,
                            color: Color(0xFF000000),
                          ),
                        ),
                      )
                          : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Stay updated with the latest alerts and updates.',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (_selectedTab == 0) ...[
                              _buildSection('Buy Vehicle', _buyNotifications),
                              _buildSection('Sell Vehicle', _sellNotifications),
                            ] else ...[
                              ..._currentNotifications
                                  .map((item) => _buildNotificationCard(item))
                                  .toList(),
                            ],
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