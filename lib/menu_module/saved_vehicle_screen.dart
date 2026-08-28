import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:true_motors/used_vehicle_module/buy_car.dart';
import 'package:true_motors/used_vehicle_module/used_vehicle_detail_screen.dart';
import 'favourites_manager.dart';

class SavedVehiclesScreen extends StatefulWidget {
  const SavedVehiclesScreen({super.key});

  @override
  State<SavedVehiclesScreen> createState() => _SavedVehiclesScreenState();
}

class _SavedVehiclesScreenState extends State<SavedVehiclesScreen> {
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
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final favorites = _manager.favorites;

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
                    _buildTopBar(context),
                    Expanded(
                      child: favorites.isEmpty
                          ? _buildEmptyState()
                          : _buildFavoritesList(favorites),
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
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back,
                size: 24.r, color: const Color(0xFF01442D)),
          ),
          SizedBox(width: 12.w),
          Text(
            'Saved Vehicles',
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'No Saved Vehicles',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF000000),
            ),
          ),
          SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 44.w),
            child: Text(
              'Vehicles you like will appear here.\nTap the heart icon on any car to save it.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.5.sp, color: const Color(0xFF8C8C8C)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(List<CarListing> favorites) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        children: [
          for (int i = 0; i < favorites.length; i++) ...[
            CarListingCard(
              car: favorites[i],
              isFav: true,
              onFavToggle: () => _manager.toggle(favorites[i]),
              onViewDetails: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UsedVehicleDetailScreen(),
                  ),
                );
              },
            ),
            SizedBox(height: 10.h),
          ],
        ],
      ),
    );
  }
}