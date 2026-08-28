import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class SecuritySettingScreen extends StatelessWidget {
  const SecuritySettingScreen({super.key});

  Widget _buildAppBar(BuildContext context) {
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
            'Security & Setting',
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

  Widget _buildSettingItem({
    required BuildContext context,
    required String imagePath,
    required String title,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding:
          EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          leading: Image.asset(
            imagePath,
            width: 24.r,
            height: 24.r,
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 15.5.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: const Color(0xFF3C3C3C),
            size: 22.r,
          ),
          onTap: onTap,
        ),
        Divider(
            height: 1.h,
            color: const Color(0xFF979797),
            indent: 10.w,
            endIndent: 10.w),
      ],
    );
  }

  void _showChangeMobileDialog(BuildContext context) {
    final TextEditingController mobileController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        title: Text('Change Mobile Number',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
        content: TextField(
          controller: mobileController,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          style: TextStyle(fontSize: 13.5.sp),
          decoration: InputDecoration(
            hintText: 'Enter new mobile number',
            hintStyle: TextStyle(fontSize: 13.sp),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Color(0xFF005F65)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(color: Colors.black, fontSize: 13.5.sp)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF005F65)),
            child: Text('Update',
                style: TextStyle(color: Colors.white, fontSize: 13.5.sp)),
          ),
        ],
      ),
    );
  }

  void _showTwoFactorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        title: Text('Two Factor Authentication',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
        content: Text(
            'Enable two-factor authentication to add an extra layer of security to your account.',
            style: TextStyle(fontSize: 13.5.sp)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(color: Colors.black, fontSize: 13.5.sp)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF005F65)),
            child: Text('Enable',
                style: TextStyle(color: Colors.white, fontSize: 13.5.sp)),
          ),
        ],
      ),
    );
  }

  void _showPrivacySettingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        title: Text('Privacy Setting',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
        content: Text(
            'Manage your privacy settings and control how your data is used.',
            style: TextStyle(fontSize: 13.5.sp)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
            Text('Close', style: TextStyle(color: Colors.black, fontSize: 13.5.sp)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        title: Text('Delete Account',
            style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.red)),
        content: Text(
            'Are you sure you want to delete your account? This action cannot be undone.',
            style: TextStyle(fontSize: 13.5.sp)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(color: Colors.black, fontSize: 13.5.sp)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete',
                style: TextStyle(color: Colors.white, fontSize: 13.5.sp)),
          ),
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
                    _buildAppBar(context),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 5.h),
                            Text(
                              'Security & Settings – TrueMotors',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              'Your privacy and security come first.\nManage your account security, privacy settings, and personal preferences — all in one place.',
                              style: TextStyle(
                                  fontSize: 13.5.sp, color: Colors.black, height: 1.6),
                            ),
                            SizedBox(height: 10.h),
                            Column(
                              children: [
                                _buildSettingItem(
                                  context: context,
                                  imagePath:
                                  'assets/icons/mobile.png',
                                  title: 'Change Mobile Number',
                                  onTap: () =>
                                      _showChangeMobileDialog(context),
                                ),
                                _buildSettingItem(
                                  context: context,
                                  imagePath: 'assets/icons/lock.png',
                                  title: 'Two Factor Authentication',
                                  onTap: () =>
                                      _showTwoFactorDialog(context),
                                ),
                                _buildSettingItem(
                                  context: context,
                                  imagePath:
                                  'assets/icons/privacy.png',
                                  title: 'Privacy Setting',
                                  onTap: () =>
                                      _showPrivacySettingDialog(context),
                                ),
                                _buildSettingItem(
                                  context: context,
                                  imagePath:
                                  'assets/icons/delete.png',
                                  title: 'Delete Account',
                                  onTap: () =>
                                      _showDeleteAccountDialog(context),
                                ),
                              ],
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