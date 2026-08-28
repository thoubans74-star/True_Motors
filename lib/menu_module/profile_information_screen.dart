import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:true_motors/provider/profile_update_provider.dart';

class ProfileInformationScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final String? currentImagePath;
  final ValueChanged<String>? onImageChanged;

  const ProfileInformationScreen({
    super.key,
    this.scaffoldKey,
    this.currentImagePath,
    this.onImageChanged,
  });

  @override
  State<ProfileInformationScreen> createState() =>
      _ProfileInformationScreenState();
}

class _ProfileInformationScreenState
    extends State<ProfileInformationScreen> {
  final ImagePicker _picker = ImagePicker();

  // ── Basic Details ──────────────────────────────────────────────────────────
  String _name = '';
  String _phone = '';
  String _email = '';
  String? _profileImagePath;
  String? _profileImageUrl;

  // ── Address Details (6 fields from API) ──────────────────────────────────
  String _block = '';
  String _streetName = '';
  String _area = '';
  String _city = '';
  String _state = '';
  String _pincode = '';

  // ── Edit states ───────────────────────────────────────────────────────────
  bool _isEditingBasic = false;
  bool _isEditingAddress = false;

  // ── Controllers for Basic Details inline edit ─────────────────────────────
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;

  // ── Controllers for Address inline edit ───────────────────────────────────
  late TextEditingController _blockCtrl;
  late TextEditingController _streetCtrl;
  late TextEditingController _areaCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _stateCtrl;
  late TextEditingController _pincodeCtrl;

  final _basicFormKey = GlobalKey<FormState>();
  final _addressFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _profileImagePath = widget.currentImagePath;
    _nameCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _emailCtrl = TextEditingController();

    _blockCtrl = TextEditingController();
    _streetCtrl = TextEditingController();
    _areaCtrl = TextEditingController();
    _cityCtrl = TextEditingController();
    _stateCtrl = TextEditingController();
    _pincodeCtrl = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAndFetchData();
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _blockCtrl.dispose();
    _streetCtrl.dispose();
    _areaCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _pincodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAndFetchData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _name = prefs.getString('name') ?? '';
      _phone = prefs.getString('phone') ?? prefs.getString('mobile') ?? '';
      _email = prefs.getString('email') ?? '';
      _block = prefs.getString('block') ?? '';
      _streetName = prefs.getString('street_name') ?? '';
      _area = prefs.getString('area') ?? '';
      _city = prefs.getString('city') ?? '';
      _state = prefs.getString('state') ?? '';
      _pincode = prefs.getString('pincode') ?? '';
      _profileImageUrl = prefs.getString('profile_image_url');
    });

    final provider = Provider.of<ProfileUpdateProvider>(context, listen: false);
    final success = await provider.fetchProfile();
    if (success && mounted) {
      final p = provider.profile;
      setState(() {
        _name = p.name;
        _phone = p.mobile;
        _email = p.email;
        _block = p.block;
        _streetName = p.street;
        _area = p.area;
        _city = p.city;
        _state = p.state;
        _pincode = p.pincode;
        if (p.imageUrl.isNotEmpty) {
          _profileImageUrl = p.imageUrl;
        }
      });
    }
  }

  String _formatPhone(String phone) {
    if (phone.isEmpty) return '';
    if (phone.length == 10) {
      return '${phone.substring(0, 5)} ${phone.substring(5, 10)}';
    }
    return phone;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked =
          await _picker.pickImage(source: source, imageQuality: 80);
      if (picked != null) {
        setState(() => _profileImagePath = picked.path);
        widget.onImageChanged?.call(picked.path);
      }
    } catch (e) {
      debugPrint('Image pick error: $e');
    }
  }

  void _showImagePickerDialog() {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: const Color(0xFFDDDDDD),
                    borderRadius: BorderRadius.circular(2)),
              ),
              const Text('Profile Photo',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE8F5E9),
                    child: Icon(Icons.camera_alt, color: Color(0xFF005F65))),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE3F2FD),
                    child: Icon(Icons.photo_library, color: Color(0xFF1565C0))),
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

  Future<void> _saveChanges() async {
    if (_isEditingBasic && !_basicFormKey.currentState!.validate()) return;
    if (_isEditingAddress && !_addressFormKey.currentState!.validate()) return;

    final updatedName = _isEditingBasic ? _nameCtrl.text.trim() : _name;
    final updatedPhone = _isEditingBasic ? _phoneCtrl.text.trim() : _phone;
    final updatedEmail = _isEditingBasic ? _emailCtrl.text.trim().toLowerCase() : _email;

    final updatedBlock = _isEditingAddress ? _blockCtrl.text.trim() : _block;
    final updatedStreet = _isEditingAddress ? _streetCtrl.text.trim() : _streetName;
    final updatedArea = _isEditingAddress ? _areaCtrl.text.trim() : _area;
    final updatedCity = _isEditingAddress ? _cityCtrl.text.trim() : _city;
    final updatedState = _isEditingAddress ? _stateCtrl.text.trim() : _state;
    final updatedPincode = _isEditingAddress ? _pincodeCtrl.text.trim() : _pincode;

    final provider = Provider.of<ProfileUpdateProvider>(context, listen: false);

    final success = await provider.updateProfile(
      name: updatedName,
      email: updatedEmail,
      mobile: updatedPhone,
      block: updatedBlock,
      street: updatedStreet,
      area: updatedArea,
      city: updatedCity,
      state: updatedState,
      pincode: updatedPincode,
      profileImageFile: (_profileImagePath != null && _profileImagePath!.isNotEmpty)
          ? File(_profileImagePath!)
          : null,
    );

    if (!mounted) return;

    if (success) {
      final p = provider.profile;
      setState(() {
        _name = p.name;
        _phone = p.mobile;
        _email = p.email;
        _block = p.block;
        _streetName = p.street;
        _area = p.area;
        _city = p.city;
        _state = p.state;
        _pincode = p.pincode;
        if (p.imageUrl.isNotEmpty) {
          _profileImageUrl = p.imageUrl;
          _profileImagePath = null;
        }
        _isEditingBasic = false;
        _isEditingAddress = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Color(0xFF005F65),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to update profile'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ── Input decoration helper ────────────────────────────────────────────────
  InputDecoration _inputDec(String label) => InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 13.sp, color: const Color(0xFF005F65)),
        floatingLabelStyle:
            TextStyle(fontSize: 13.sp, color: const Color(0xFF005F65)),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: const BorderSide(color: Color(0xFFC4C4C4))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: const BorderSide(color: Color(0xFFC4C4C4))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide:
                const BorderSide(color: Color(0xFF005F65), width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide:
                const BorderSide(color: Color(0xFFE53935), width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide:
                const BorderSide(color: Color(0xFFE53935), width: 1.5)),
        contentPadding:
            EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      );

  // ── Section header with Edit button ───────────────────────────────────────
  Widget _sectionHeader(
    String title,
    bool isEditing,
    VoidCallback onEdit,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          GestureDetector(
            onTap: onEdit,
            child: Icon(
              Icons.edit_outlined,
              color: const Color(0xFF005F65),
              size: 22.r,
            ),
          ),
        ],
      ),
    );
  }

  // ── Read-only info row ────────────────────────────────────────────────────
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          SizedBox(
            width: 120.w,
            child: Text(label,
                style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF000000))),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: value.isEmpty
                      ? const Color(0xFFAAAAAA)
                      : const Color(0xFF555555)),
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider? _getAvatarImageProvider() {
    if (_profileImagePath != null && _profileImagePath!.isNotEmpty) {
      return FileImage(File(_profileImagePath!));
    } else if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty) {
      return NetworkImage(_profileImageUrl!);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final profileProvider = Provider.of<ProfileUpdateProvider>(context);

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
                color: Colors.white),
            Expanded(
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    // ── AppBar ──────────────────────────────────────────────
                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 14.h),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Icon(Icons.arrow_back,
                                size: 24.r, color: const Color(0xFF01442D)),
                          ),
                          SizedBox(width: 12.w),
                          Text('Profile Information',
                              style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF01422D))),
                          const Spacer(),
                          if (profileProvider.isLoading)
                            SizedBox(
                              width: 20.r,
                              height: 20.r,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF005F65),
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
                            SizedBox(height: 8.h),
                            // ── Profile Avatar Card ───────────────────────
                            Padding(
                              padding: EdgeInsets.all(16.w),
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                      color: const Color(0xFFC4C4C4)),
                                ),
                                child: Row(
                                  children: [
                                    Stack(
                                      children: [
                                        CircleAvatar(
                                          radius: 30.r,
                                          backgroundColor:
                                              const Color(0xFFF0F0F0),
                                          backgroundImage: _getAvatarImageProvider(),
                                          child: (_getAvatarImageProvider() == null)
                                              ? Icon(Icons.person,
                                                  size: 44.r,
                                                  color: const Color(0xFFAAAAAA))
                                              : null,
                                        ),
                                        Positioned(
                                          bottom: 0, right: 0,
                                          child: GestureDetector(
                                            onTap: _showImagePickerDialog,
                                            child: Container(
                                              width: 22.r, height: 22.r,
                                              decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFF005F65),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                      color: Colors.white,
                                                      width: 1.5)),
                                              child: Icon(
                                                  Icons.camera_alt,
                                                  color: Colors.white,
                                                  size: 12.r),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: 15.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _name.isEmpty ? 'User' : _name,
                                            style: TextStyle(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black),
                                          ),
                                          SizedBox(height: 4.h),
                                          Text(
                                            _phone.isEmpty
                                                ? '+91 000-000'
                                                : '+91 ${_formatPhone(_phone)}',
                                            style: TextStyle(
                                                fontSize: 13.sp,
                                                color: const Color(0xFF000000)),
                                          ),
                                          if (_email.isNotEmpty)
                                            Text(_email,
                                                style: TextStyle(
                                                    fontSize: 13.sp,
                                                    color: const Color(0xFF000000))),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: 10.h),
                            // ── Basic Details Section ─────────────────────
                            _sectionHeader(
                              'Basic Details',
                              _isEditingBasic,
                              () {
                                _nameCtrl.text = _name;
                                _phoneCtrl.text = _phone;
                                _emailCtrl.text = _email;
                                setState(() => _isEditingBasic = true);
                              },
                            ),
                            SizedBox(height: 16.h),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 16.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                    color: const Color(0xFFC4C4C4)),
                              ),
                              child: _isEditingBasic
                                  ? Padding(
                                      padding: EdgeInsets.all(16.w),
                                      child: Form(
                                        key: _basicFormKey,
                                        child: Column(
                                          children: [
                                            TextFormField(
                                              style: TextStyle(fontSize: 13.5.sp),
                                              controller: _nameCtrl,
                                              decoration:
                                                  _inputDec('Full Name'),
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .allow(RegExp(r'[a-zA-Z ]'))
                                              ],
                                              validator: (v) =>
                                                  (v == null || v.trim().isEmpty)
                                                      ? 'Enter name'
                                                      : null,
                                            ),
                                            SizedBox(height: 12.h),
                                            TextFormField(
                                              style: TextStyle(fontSize: 13.5.sp),
                                              controller: _phoneCtrl,
                                              decoration:
                                                  _inputDec('Mobile Number'),
                                              keyboardType:
                                                  TextInputType.phone,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                                LengthLimitingTextInputFormatter(
                                                    10),
                                              ],
                                              validator: (v) {
                                                if (v == null ||
                                                    v.trim().isEmpty) {
                                                  return 'Enter mobile number';
                                                }
                                                if (v.trim().length != 10) {
                                                  return 'Must be 10 digits';
                                                }
                                                return null;
                                              },
                                            ),
                                            SizedBox(height: 12.h),
                                            TextFormField(
                                              style: TextStyle(fontSize: 13.5.sp),
                                              controller: _emailCtrl,
                                              decoration:
                                                  _inputDec('Email Address'),
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                              validator: (v) {
                                                if (v == null ||
                                                    v.trim().isEmpty) {
                                                  return 'Enter email';
                                                }
                                                if (!RegExp(
                                                        r'^[\w\.-]+@[\w\.-]+\.\w+$')
                                                    .hasMatch(v.trim())) {
                                                  return 'Enter valid email';
                                                }
                                                return null;
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Column(
                                      children: [
                                        _infoRow('Full Name', _name),
                                        _infoRow('Mobile Number',
                                            _phone.isEmpty ? '' : '+91 ${_formatPhone(_phone)}'),
                                        _infoRow(
                                            'Email Address', _email),
                                      ],
                                    ),
                            ),

                            SizedBox(height: 20.h),

                            // ── Address Section ───────────────────────────
                            _sectionHeader(
                              'Address',
                              _isEditingAddress,
                              () {
                                _blockCtrl.text = _block;
                                _streetCtrl.text = _streetName;
                                _areaCtrl.text = _area;
                                _cityCtrl.text = _city;
                                _stateCtrl.text = _state;
                                _pincodeCtrl.text = _pincode;
                                setState(() => _isEditingAddress = true);
                              },
                            ),
                            SizedBox(height: 16.h),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 16.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                    color: const Color(0xFFC4C4C4)),
                              ),
                              child: _isEditingAddress
                                  ? Padding(
                                      padding: EdgeInsets.all(16.w),
                                      child: Form(
                                        key: _addressFormKey,
                                        child: Column(
                                          children: [
                                            TextFormField(
                                              style: TextStyle(fontSize: 13.5.sp),
                                              controller: _blockCtrl,
                                              decoration:
                                                  _inputDec('Block'),
                                              validator: (v) =>
                                                  (v == null || v.trim().isEmpty)
                                                      ? 'Enter block'
                                                      : null,
                                            ),
                                            SizedBox(height: 12.h),
                                            TextFormField(
                                              style: TextStyle(fontSize: 13.5.sp),
                                              controller: _streetCtrl,
                                              decoration:
                                                  _inputDec('Street Name'),
                                              validator: (v) =>
                                                  (v == null || v.trim().isEmpty)
                                                      ? 'Enter street'
                                                      : null,
                                            ),
                                            SizedBox(height: 12.h),
                                            TextFormField(
                                              style: TextStyle(fontSize: 13.5.sp),
                                              controller: _areaCtrl,
                                              decoration:
                                                  _inputDec('Area'),
                                              validator: (v) =>
                                                  (v == null || v.trim().isEmpty)
                                                      ? 'Enter area'
                                                      : null,
                                            ),
                                            SizedBox(height: 12.h),
                                            TextFormField(
                                              style: TextStyle(fontSize: 13.5.sp),
                                              controller: _cityCtrl,
                                              decoration: _inputDec('City'),
                                              validator: (v) =>
                                                  (v == null || v.trim().isEmpty)
                                                      ? 'Enter city'
                                                      : null,
                                            ),
                                            SizedBox(height: 12.h),
                                            TextFormField(
                                              style: TextStyle(fontSize: 13.5.sp),
                                              controller: _stateCtrl,
                                              decoration: _inputDec('State'),
                                              validator: (v) =>
                                                  (v == null || v.trim().isEmpty)
                                                      ? 'Enter state'
                                                      : null,
                                            ),
                                            SizedBox(height: 12.h),
                                            TextFormField(
                                              style: TextStyle(fontSize: 13.5.sp),
                                              controller: _pincodeCtrl,
                                              decoration: _inputDec('Pincode'),
                                              keyboardType: TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter.digitsOnly,
                                                LengthLimitingTextInputFormatter(6),
                                              ],
                                              validator: (v) =>
                                                  (v == null || v.trim().isEmpty)
                                                      ? 'Enter pincode'
                                                      : null,
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Column(
                                      children: [
                                        _infoRow('Block', _block),
                                        _infoRow('Street Name', _streetName),
                                        _infoRow('Area', _area),
                                        _infoRow('City', _city),
                                        _infoRow('State', _state),
                                        _infoRow('Pincode', _pincode),
                                      ],
                                    ),
                            ),

                            SizedBox(height: 30.h),

                            // ── Save Changes button ───────────────────────
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 50.w),
                              child: SizedBox(
                                width: double.infinity,
                                height: 46.h,
                                child: ElevatedButton(
                                  onPressed: profileProvider.isLoading
                                      ? null
                                      : _saveChanges,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(0xFF005F65),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.r)),
                                    elevation: 0,
                                  ),
                                  child: profileProvider.isLoading
                                      ? SizedBox(
                                          width: 24.r,
                                          height: 24.r,
                                          child: const CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text('Save Changes',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.w700)),
                                ),
                              ),
                            ),
                            SizedBox(height: 32.h),
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