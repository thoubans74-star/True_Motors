import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:shared_preferences/shared_preferences.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selectedLanguage = 'English';

  final List<Map<String, String>> _languages = [
    {'name': 'English', 'native': 'English', 'icon': 'A'},
    {'name': 'Tamil', 'native': 'தமிழ்', 'icon': 'த'},
    {'name': 'Hindi', 'native': 'हिंदी', 'icon': 'आ'},
  ];

  Widget _buildAppBar() {
    return Container(
      color: const Color(0xFFFFF8F8),
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
            'Select Language',
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

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _selectedLanguage = prefs.getString('selectedLanguage') ?? 'English';
    });
  }

  Future<void> _saveLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', language);

    setState(() {
      _selectedLanguage = language;
    });
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
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFFFFFFF),
                Color(0xFF3AB0B7),
              ],
              stops: [0.39, 1.0],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
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
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: 20.h),
                              Image.asset('assets/icons/lan.png',
                                height: 90.h,
                                width: 90.w,
                              ),
                              SizedBox(height: 16.h),

                              Text(
                                'Select Language',
                                style: TextStyle(
                                  fontSize: 19.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'True Guide supports multiple languages to enhance your experience. Please select your preferred language to continue.',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontSize: 14.5.sp,
                                  color: Colors.black,
                                  height: 1.5,
                                ),
                              ),
                              SizedBox(height: 20.h),

                              // Language options
                              Column(
                                children: _languages.map((lang) {
                                  final isSelected =
                                      _selectedLanguage == lang['name'];
                                  final isLast =
                                      _languages.last == lang;
                                  return Column(
                                    children: [
                                      InkWell(
                                        onTap: () => _saveLanguage(lang['name']!),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16.w, vertical: 12.h),
                                          child: Row(
                                            children: [
                                              // Language character badge
                                              Container(
                                                width: 42.r,
                                                height: 42.r,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Color(0xFFEAECF9),
                                                ),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  lang['icon']!,
                                                  style: TextStyle(
                                                    fontFamily: 'Lato',
                                                    fontSize: 18.sp,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 14.w),
                                              // Language name
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      lang['name']!,
                                                      style: TextStyle(
                                                        fontFamily: 'Lato',
                                                        fontSize: 18.sp,
                                                        fontWeight: FontWeight.w700,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    if (lang['name'] !=
                                                        lang['native'])
                                                      Text(
                                                        lang['native']!,
                                                        style: TextStyle(
                                                          fontFamily: 'Lato',
                                                          fontSize: 13.5.sp,
                                                          color: const Color(0xFF656666),
                                                        ),
                                                      ),
                                                    if (lang['name'] ==
                                                        lang['native'])
                                                      Text(
                                                        lang['native']!,
                                                        style: TextStyle(
                                                          fontFamily: 'Lato',
                                                          fontSize: 13.5.sp,
                                                          color: const Color(0xFF656666),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              // Radio
                                              Radio<String>(
                                                value: lang['name']!,
                                                groupValue: _selectedLanguage,
                                                onChanged: (v) {
                                                  if (v != null) {
                                                    _saveLanguage(v);
                                                  }
                                                },
                                                activeColor:
                                                const Color(0xFF4134CA),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const Divider(
                                          height: 1,
                                          color: Color(0xFFC0ADAD),
                                          indent: 1,
                                          endIndent: 1),
                                    ],
                                  );
                                }).toList(),
                              ),
                              SizedBox(height: 24.h),
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
      ),
    );
  }
}