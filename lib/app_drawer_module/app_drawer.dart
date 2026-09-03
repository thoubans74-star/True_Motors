import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:true_motors/menu_module/terms_and_privacy.dart';
import 'package:true_motors/lease_module/dashboard_screen.dart';
import 'package:true_motors/login_module/splash_screen.dart';
import 'package:true_motors/menu_module/my_listing_screen.dart';
import 'package:true_motors/menu_module/saved_vehicle_screen.dart';
import 'package:true_motors/menu_module/notification_alert_screen.dart';
import 'package:true_motors/menu_module/help_support_screen.dart';
import 'package:true_motors/menu_module/language_screen.dart';
import 'package:true_motors/menu_module/subscription_screen.dart';
import 'package:true_motors/menu_module/profile_information_screen.dart';
import 'package:true_motors/menu_module/my_booking_screen.dart';
import 'package:true_motors/provider/profile_update_provider.dart';
import 'package:true_motors/provider/logout_provider.dart';

class AppDrawer extends StatefulWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const AppDrawer({super.key, this.scaffoldKey});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String _name = '';
  String _phone = '';
  String? _profileImagePath;
  String? _profileImageUrl;
  bool _isUploadingImage = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _name = prefs.getString('name') ?? 'User';
      _phone = prefs.getString('phone') ?? prefs.getString('mobile') ?? '000-000';
      _profileImageUrl = prefs.getString('profile_image_url');
    });

    final provider = Provider.of<ProfileUpdateProvider>(context, listen: false);
    final success = await provider.fetchProfile();
    if (success && mounted) {
      final p = provider.profile;
      setState(() {
        if (p.name.isNotEmpty) _name = p.name;
        if (p.mobile.isNotEmpty) _phone = p.mobile;
        if (p.imageUrl.isNotEmpty) _profileImageUrl = p.imageUrl;
      });
    }
  }

  String _formatPhone(String phone) {
    if (phone.isEmpty || phone == '000-000') return '000-000';
    if (phone.length == 10) {
      return '${phone.substring(0, 5)} ${phone.substring(5, 10)}';
    }
    return phone;
  }

  Future<void> _pickImage(ImageSource source) async {
    final provider = Provider.of<ProfileUpdateProvider>(context, listen: false);
    try {
      final XFile? picked =
          await _picker.pickImage(source: source, imageQuality: 80);
      if (picked != null) {
        setState(() {
          _profileImagePath = picked.path;
          _isUploadingImage = true;
        });

        final p = provider.profile;

        final success = await provider.updateProfile(
          name: p.name.isNotEmpty ? p.name : _name,
          email: p.email,
          mobile: p.mobile.isNotEmpty ? p.mobile : _phone,
          block: p.block,
          street: p.street,
          area: p.area,
          city: p.city,
          state: p.state,
          pincode: p.pincode,
          profileImageFile: File(picked.path),
        );

        if (mounted) {
          setState(() {
            _isUploadingImage = false;
            if (success && provider.profile.imageUrl.isNotEmpty) {
              _profileImageUrl = provider.profile.imageUrl;
              _profileImagePath = null;
            }
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isUploadingImage = false);
      debugPrint('Image pick/upload error: $e');
    }
  }

  void _showImagePickerDialog() {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFDDDDDD),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Profile Photo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE8F5E9),
                  child: Icon(Icons.camera_alt, color: Color(0xFF005F65)),
                ),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE3F2FD),
                  child: Icon(Icons.photo_library, color: Color(0xFF1565C0)),
                ),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  ImageProvider? _getAvatarProvider() {
    if (_profileImagePath != null && _profileImagePath!.isNotEmpty) {
      return FileImage(File(_profileImagePath!));
    } else if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty) {
      return NetworkImage(_profileImageUrl!);
    }
    return null;
  }

  Widget _buildProfileAvatar() {
    final avatarImage = _getAvatarProvider();

    return Stack(
      children: [
        CircleAvatar(
          radius: 30.r,
          backgroundColor: const Color(0xFFF5F5F5),
          backgroundImage: avatarImage,
          child: _isUploadingImage
              ? SizedBox(
                  width: 24.r,
                  height: 24.r,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF005F65),
                  ),
                )
              : (avatarImage == null)
                  ? Icon(Icons.person, size: 42.r, color: const Color(0xFFAAAAAA))
                  : null,
        ),
        Positioned(
          bottom: 2.h,
          right: 0,
          child: GestureDetector(
            onTap: _showImagePickerDialog,
            child: Container(
              width: 18.r,
              height: 18.r,
              decoration: BoxDecoration(
                color: const Color(0xFF005F65),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: Icon(Icons.add, color: Colors.white, size: 12.r),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    String? imagePath,
    IconData? icon,
    required String label,
    VoidCallback? onTap,
    Color labelColor = Colors.black,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 2.h,
          ),
          leading: imagePath != null
              ? Image.asset(imagePath, width: 24.r, height: 24.r)
              : Icon(icon, size: 22.r),
          title: Text(
            label,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: labelColor,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: Colors.black,
            size: 20.r,
          ),
          onTap: onTap ?? () {},
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: const Color(0xFF8899BD),
          indent: 20.w,
          endIndent: 20.w,
        ),
      ],
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Are you sure want to Logout?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side:
                            const BorderSide(color: Color(0xFF005F65)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'NO',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final navigator = Navigator.of(context);
                        final prefs = await SharedPreferences.getInstance();
                        
                        final String token = prefs.getString('token') ?? '';
                        final int userId = prefs.getInt('user_id') ?? 0;
                        try {
                          await LogoutApi.logout(LogoutRequest(
                            cid: '21472147',
                            token: token,
                            ledId: userId.toString(),
                          ));
                        } catch (e) {
                          print('[AppDrawer] Logout error: $e');
                        }

                        await prefs.remove('profile_image_path');
                        await prefs.remove('profile_image_url');
                        await prefs.remove('phone');
                        await prefs.remove('name');
                        await prefs.remove('email');
                        await prefs.remove('token');
                        await prefs.remove('user_id');
                        navigator.pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (_) => const SplashScreen(fromLogout: true)),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF005F65),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'YES',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
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

  Future<void> _pushAndReopenDrawer(Widget screen) async {
    Navigator.pop(context);
    Navigator.of(
      widget.scaffoldKey!.currentContext!,
    ).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  void _openProfileInformation() {
    Navigator.pop(context);
    Navigator.of(widget.scaffoldKey!.currentContext!).push(
      MaterialPageRoute(
        builder: (_) => ProfileInformationScreen(
          scaffoldKey: widget.scaffoldKey,
          currentImagePath: _profileImagePath,
          onImageChanged: (path) {
            setState(() => _profileImagePath = path);
          },
        ),
      ),
    ).then((_) => _loadUserData());
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
      child: Drawer(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        width: MediaQuery.of(context).size.width * 0.77,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: statusBarHeight,
              color: Colors.transparent,
            ),
            Expanded(
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    // ─── Header ───────────────────────────────────────────
                    Container(
                      width: double.infinity,
                      color: const Color(0xFF005F65),
                      padding: const EdgeInsets.only(
                          top: 25, left: 16, right: 12, bottom: 16),
                      child: Stack(
                        children: [
                          Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.center,
                            children: [
                              _buildProfileAvatar(),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            _name.isEmpty
                                                ? 'User'
                                                : _name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight:
                                                  FontWeight.w600,
                                            ),
                                            overflow:
                                                TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      _formatPhone(_phone),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            onTap:
                                                _openProfileInformation,
                                            child: const Text(
                                              'View Full Profile',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                                fontWeight:
                                                    FontWeight.w500,
                                                decoration: TextDecoration
                                                    .underline,
                                                decorationColor:
                                                    Colors.white,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 3),
                                          decoration: BoxDecoration(
                                            color:
                                                const Color(0xFF30AC4B),
                                            borderRadius:
                                                BorderRadius.circular(
                                                    12),
                                          ),
                                          child: const Text(
                                            'Active',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight:
                                                  FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Icon(Icons.close,
                                  color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ─── Menu Items ───────────────────────────────────────
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.only(top: 8),
                        children: [
                          _buildMenuItem(
                            imagePath:
                                'assets/drawer_image/profile.png',
                            label: 'Profile Information',
                            onTap: _openProfileInformation,
                          ),
                          _buildMenuItem(
                            imagePath:
                                'assets/drawer_image/booking.png',
                            label: 'My Booking',
                            onTap: () => _pushAndReopenDrawer(
                                const MyBookingScreen()),
                          ),
                          _buildMenuItem(
                            imagePath:
                                'assets/drawer_image/listing.png',
                            label: 'My Listing',
                            onTap: () => _pushAndReopenDrawer(
                                const MyListingScreen()),
                          ),
                          _buildMenuItem(
                            imagePath:
                                'assets/drawer_image/saved_vehicle.png',
                            label: 'Saved Vehicles',
                            onTap: () => _pushAndReopenDrawer(
                                const SavedVehiclesScreen()),
                          ),
                          _buildMenuItem(
                            imagePath:
                                'assets/sell_image/red_car.png',
                            label: 'Lease Vehicles',
                            onTap: () => _pushAndReopenDrawer(
                                LeaseVehicleDashboardScreen()),
                          ),
                          _buildMenuItem(
                            imagePath:
                                'assets/drawer_image/notification.png',
                            label: 'Notification & Alerts',
                            onTap: () => _pushAndReopenDrawer(
                                const NotificationAlertScreen()),
                          ),
                          _buildMenuItem(
                            imagePath: 'assets/drawer_image/help.png',
                            label: 'Help & Support',
                            onTap: () => _pushAndReopenDrawer(
                                const HelpSupportScreen()),
                          ),
                          _buildMenuItem(
                            imagePath:
                                'assets/drawer_image/security.png',
                            label: 'Subscription',
                            onTap: () => _pushAndReopenDrawer(
                                const SubscriptionScreen()),
                          ),
                          _buildMenuItem(
                            imagePath:
                                'assets/drawer_image/terms_privacy.png',
                            label: 'Terms & Privacy',
                            onTap: () => _pushAndReopenDrawer(
                                const TermsAndPrivacyScreen()),
                          ),
                          _buildMenuItem(
                            imagePath:
                                'assets/drawer_image/language.png',
                            label: 'Language',
                            onTap: () => _pushAndReopenDrawer(
                                const LanguageScreen()),
                          ),
                          const SizedBox(height: 8),
                          _buildMenuItem(
                            imagePath:
                                'assets/drawer_image/logout.png',
                            label: 'Logout',
                            onTap: _showLogoutDialog,
                          ),
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