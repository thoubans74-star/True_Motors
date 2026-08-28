import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';



class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
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
            'Help & Support',
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

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 10.w),
          Text('• ', style: TextStyle(fontSize: 13.5.sp, color: Colors.black)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13.5.sp, color: Colors.black, height: 1.4),
            ),
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
                    _buildAppBar(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 5.h),
                            Text(
                              'Help & Support – True Motors',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              "We're here to help you every step of the way.\nGot questions, issues, or feedback?\nFind answers quickly or connect with our support team for personalized assistance.",
                              style: TextStyle(
                                  fontSize: 13.5.sp, color: Colors.black, height: 1.6),
                            ),
                            SizedBox(height: 16.h),

                            // Call Us Directly
                            Text(
                              'Call Us Directly',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            _buildBulletPoint(
                                'Speak with our customer care team for urgent help.'),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(width: 10.w),
                                Text('• ', style: TextStyle(fontSize: 13.5.sp)),
                                Icon(Icons.phone, size: 14.r, color: Colors.black87),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: Text(
                                    'Customer Support: +91-90873-90873',
                                    style: TextStyle(fontSize: 13.5.sp, color: Colors.black87),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4.h),
                            _buildBulletPoint('Available 9 AM – 9 PM IST'),
                            SizedBox(height: 16.h),

                            // Email Support
                            Text(
                              'Email Support',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            _buildBulletPoint(
                                'For detailed queries or document submissions.'),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(width: 10.w),
                                Text('• ', style: TextStyle(fontSize: 13.5.sp)),
                                Icon(Icons.email_outlined, size: 14.r, color: Colors.black87),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: Text(
                                    'support@truemotors.com',
                                    style: TextStyle(
                                      fontSize: 13.5.sp,
                                      color: const Color(0xFF005F65),
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),

                            // Feedback & Suggestions
                            Text(
                              'Feedback & Suggestions',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              'Share your feedback to help us improve your TrueMotors experience.',
                              style: TextStyle(fontSize: 13.5.sp, color: Colors.black, height: 1.6),
                            ),
                            SizedBox(height: 12.h),

                            // Feedback text field
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: const Color(0xFF000000)),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: TextField(
                                controller: _feedbackController,
                                maxLines: 6,
                                style: TextStyle(fontSize: 13.5.sp),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(12.w),
                                  hintText: 'Write your feedback here...',
                                  hintStyle: TextStyle(
                                      fontSize: 13.sp, color: const Color(0xFFAAAAAA)),
                                ),
                              ),
                            ),
                            SizedBox(height: 16.h),

                            // Submit button
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_feedbackController.text.trim().isNotEmpty) {
                                    _feedbackController.clear();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Feedback submitted successfully!'),
                                        backgroundColor: Color(0xFF005F65),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF742B88),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 24.w, vertical: 12.h),
                                ),
                                child: Text(
                                  'Submit a Feedback',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.5.sp,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            SizedBox(height: 20.h),
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