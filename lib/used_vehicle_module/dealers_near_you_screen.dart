import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:latlong2/latlong.dart' hide Path;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dealer_details_screen.dart';

class DealersNearYouScreen extends StatefulWidget {
  const DealersNearYouScreen({super.key});

  @override
  State<DealersNearYouScreen> createState() => _DealersNearYouScreenState();
}

class _DealersNearYouScreenState extends State<DealersNearYouScreen> {
  LatLng? _currentPosition;
  bool _isLoadingLocation = true;
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  // Dummy markers near the user
  final List<LatLng> _dealerLocations = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) setState(() => _isLoadingLocation = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) setState(() => _isLoadingLocation = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) setState(() => _isLoadingLocation = false);
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      
      _currentPosition = LatLng(position.latitude, position.longitude);

      // Generate dummy dealers around the current location
      _dealerLocations.add(LatLng(position.latitude + 0.005, position.longitude + 0.005));
      _dealerLocations.add(LatLng(position.latitude - 0.003, position.longitude + 0.008));
      _dealerLocations.add(LatLng(position.latitude + 0.002, position.longitude - 0.006));

      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF01422D)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Dealers near you',
          style: TextStyle(
            color: const Color(0xFF01422D),
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            _buildSearchBar(),
            SizedBox(height: 16.h),
            _buildInteractiveMap(),
            SizedBox(height: 24.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                'Dealers Near by Coimbatore',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            _buildDealerCard(),
            _buildDealerCard(),
            _buildDealerCard(),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        height: 46.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: const Color(0xFF742B88)),
        ),
        child: TextField(
          controller: _searchController,
          onSubmitted: _handleSearch,
          style: TextStyle(fontSize: 14.sp),
          decoration: InputDecoration(
            hintText: 'Search Dealer or Location',
            hintStyle: TextStyle(color: const Color(0xFF9E9E9E), fontSize: 13.5.sp),
            prefixIcon: Icon(Icons.search, color: const Color(0xFF5F6368), size: 20.r),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 12.h),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSearch(String query) async {
    if (query.trim().isEmpty) return;
    
    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        final LatLng newPos = LatLng(loc.latitude, loc.longitude);
        
        setState(() {
          _currentPosition = newPos;
          _dealerLocations.clear();
          _dealerLocations.add(LatLng(newPos.latitude + 0.005, newPos.longitude + 0.005));
          _dealerLocations.add(LatLng(newPos.latitude - 0.003, newPos.longitude + 0.008));
          _dealerLocations.add(LatLng(newPos.latitude + 0.002, newPos.longitude - 0.006));
        });
        
        _mapController.move(newPos, 13.0);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location not found. Please try another search.')),
        );
      }
    }
  }

  Widget _buildInteractiveMap() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          height: 280.h,
          width: double.infinity,
          color: Colors.white,
          child: _isLoadingLocation
              ? const Center(child: CircularProgressIndicator())
              : _currentPosition == null
                  ? const Center(child: Text("Location unavailable"))
                  : FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _currentPosition!,
                        initialZoom: 14.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                          userAgentPackageName: 'com.truemotors.app', 
                        ),
                        CircleLayer(
                          circles: [
                            CircleMarker(
                              point: _currentPosition!,
                              color: Colors.blue.withValues(alpha: 0.15),
                              borderStrokeWidth: 1,
                              borderColor: Colors.blue.withValues(alpha: 0.3),
                              useRadiusInMeter: true,
                              radius: 1200,
                            ),
                          ],
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _currentPosition!,
                              width: 24.r,
                              height: 24.r,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 3.w),
                                  boxShadow: const [
                                    BoxShadow(color: Colors.black26, blurRadius: 4)
                                  ],
                                ),
                              ),
                            ),
                            if (_dealerLocations.isNotEmpty)
                              Marker(
                                point: _dealerLocations[0],
                                width: 140.w,
                                height: 56.h,
                                alignment: Alignment.topCenter,
                                child: const _DealerMarker(
                                  name: "Speed Motors",
                                  distance: "1.2 km",
                                  iconColor: Colors.deepPurple,
                                  icon: Icons.location_on,
                                ),
                              ),
                            if (_dealerLocations.length > 1)
                              Marker(
                                point: _dealerLocations[1],
                                width: 140.w,
                                height: 56.h,
                                alignment: Alignment.topCenter,
                                child: const _DealerMarker(
                                  name: "Prime Wheels",
                                  distance: "0.6 km",
                                  iconColor: Colors.red,
                                  icon: Icons.store,
                                ),
                              ),
                            if (_dealerLocations.length > 2)
                              Marker(
                                point: _dealerLocations[2],
                                width: 140.w,
                                height: 56.h,
                                alignment: Alignment.topCenter,
                                child: const _DealerMarker(
                                  name: "City Cars",
                                  distance: "1.0 km",
                                  iconColor: Colors.blue,
                                  icon: Icons.directions_car,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildDealerCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DealerDetailsScreen()),
        );
      },
      child: Container(
        margin: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                bottomLeft: Radius.circular(12.r),
              ),
              child: SizedBox(
                width: 105.w,
                child: Image.asset(
                'assets/buy_image/dealer_near.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: Icon(Icons.store, color: Colors.grey, size: 40.r),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'RS Hyundai Showroom',
                    style: TextStyle(
                      color: const Color(0xFF040084),
                      fontSize: 14.5.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.yellow, size: 15.r),
                      Icon(Icons.star, color: Colors.yellow, size: 15.r),
                      Icon(Icons.star, color: Colors.yellow, size: 15.r),
                      Icon(Icons.star, color: Colors.yellow, size: 15.r),
                      Icon(Icons.star_border, color: Colors.black, size: 15.r),
                      SizedBox(width: 4.w),
                      Text(
                        '4.3 (210)',
                        style: TextStyle(fontSize: 11.5.sp, color: Colors.black87),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Container(
                        width: 8.r,
                        height: 8.r,
                        decoration: const BoxDecoration(
                          color: Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Open • Stock: 3 units',
                        style: TextStyle(fontSize: 11.5.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '2.1 kms',
                    style: TextStyle(
                      color: const Color(0xFFE53935),
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    ));
  }
}

class _DealerMarker extends StatelessWidget {
  final String name;
  final String distance;
  final Color iconColor;
  final IconData icon;

  const _DealerMarker({
    required this.name,
    required this.distance,
    required this.iconColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: iconColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 12, color: Colors.white),
              ),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
                  Text(distance, style: const TextStyle(fontSize: 9, color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
        // The little tail
        CustomPaint(
          size: const Size(12, 8),
          painter: _TrianglePainter(),
        ),
      ],
    );
  }
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
      
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
      
    // Small shadow for the tail
    canvas.drawShadow(path, Colors.black, 2.0, false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
