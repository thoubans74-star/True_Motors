import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final TextEditingController searchController = TextEditingController();

  bool isLoading = false;
  String currentAddress = '';

  // ── All logic unchanged from your code ────────────────────────────────────

  Future<void> searchLocation(String locationName) async {
    if (locationName.isEmpty) return;

    setState(() {
      isLoading = true;
      currentAddress = '';
    });

    try {
      List<Location> locations = await locationFromAddress(locationName);

      if (locations.isNotEmpty) {
        Location location = locations.first;

        List<Placemark> placemarks = await placemarkFromCoordinates(
          location.latitude,
          location.longitude,
        );

        Placemark place = placemarks.first;

        final List<String> parts = [];
        if ((place.subLocality ?? '').trim().isNotEmpty) {
          parts.add(place.subLocality!.trim());
        }
        if ((place.locality ?? '').trim().isNotEmpty) {
          parts.add(place.locality!.trim());
        } else if ((place.subAdministrativeArea ?? '').trim().isNotEmpty) {
          parts.add(place.subAdministrativeArea!.trim());
        }
        if ((place.administrativeArea ?? '').trim().isNotEmpty) {
          parts.add(place.administrativeArea!.trim());
        }
        if ((place.country ?? '').trim().isNotEmpty) {
          parts.add(place.country!.trim());
        }

        final fullAddress = parts.isNotEmpty ? parts.join(', ') : locationName;

        setState(() {
          currentAddress = fullAddress;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location not found')),
        );
      }
    }
  }

  Future<void> getCurrentLocation() async {
    setState(() => isLoading = true);

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => isLoading = false);
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => isLoading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => isLoading = false);
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    Placemark place = placemarks[0];

    final List<String> parts = [];
    if ((place.subLocality ?? '').trim().isNotEmpty) {
      parts.add(place.subLocality!.trim());
    }
    if ((place.name ?? '').trim().isNotEmpty && place.name != place.subLocality) {
      parts.insert(0, place.name!.trim());
    }
    if ((place.street ?? '').trim().isNotEmpty && place.street != place.name) {
      parts.add(place.street!.trim());
    }
    if ((place.locality ?? '').trim().isNotEmpty) {
      parts.add(place.locality!.trim());
    } else if ((place.subAdministrativeArea ?? '').trim().isNotEmpty) {
      parts.add(place.subAdministrativeArea!.trim());
    }
    if ((place.administrativeArea ?? '').trim().isNotEmpty) {
      parts.add(place.administrativeArea!.trim());
    }
    if ((place.postalCode ?? '').trim().isNotEmpty) {
      parts.add(place.postalCode!.trim());
    }

    final fullAddress =
    parts.isNotEmpty ? parts.join(', ') : 'Unknown Location';

    setState(() {
      currentAddress = fullAddress;
      isLoading = false;
    });
  }

  Future<void> _saveAndReturn(String address) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_city', address);
    if (mounted) Navigator.pop(context, address);
  }

  // ── UI ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Container(
                  color: const Color(0xFFFBF8F8),
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
                        'Location',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF01422D),
                        ),
                      ),
                    ],
                  ),
                ),
                    // ── Search bar ──────────────────────────────────────────────────
                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: const Color(0xFF000000), size: 22.r),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: TextField(
                              controller: searchController,
                              onSubmitted: (value) => searchLocation(value),
                              style: TextStyle(fontSize: 14.5.sp, color: Colors.black),
                              cursorColor: const Color(0xFF005F65),
                              decoration: InputDecoration(
                                hintText: 'Search for your city',
                                hintStyle: TextStyle(
                                  fontSize: 14.5.sp,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF000000),
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Divider(height: 1, color: Color(0xFFB9B9B9)),

                    // ── Auto Detect My Location ──────────────────────────────────────
                    InkWell(
                      onTap: getCurrentLocation,
                      child: Padding(
                        padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/home_image/location.png',
                              width: 22.r,
                              height: 22.r,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.my_location,
                                color: const Color(0xFF005F65),
                                size: 22.r,
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Text(
                              'Auto Detect My Location',
                              style: TextStyle(
                                fontSize: 14.5.sp,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (isLoading)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.w),
                          child: const CircularProgressIndicator(color: Color(0xFF005F65)),
                        ),
                      )

                    // ── Detected address result ──────────────────────────────────────
                    else if (currentAddress.isNotEmpty)
                      GestureDetector(
                        onTap: () => _saveAndReturn(currentAddress),
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 12.h),
                          padding: EdgeInsets.all(14.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: const Color(0xFFEEEEEE)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.location_on_outlined,
                                  color: const Color(0xFF005F65), size: 22.r),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Text(
                                  currentAddress,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14.5.sp,
                                    color: Colors.black,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Icon(Icons.chevron_right,
                                  color: const Color(0xFF9E9E9E), size: 20.r),
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