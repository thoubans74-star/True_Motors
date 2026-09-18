import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:true_motors/login_module/login_screen.dart';
import 'package:true_motors/login_module/signup_screen.dart';
import 'package:true_motors/app_drawer_module/home_screen.dart';
import 'package:true_motors/provider/otp_screen_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


class OtpScreen extends StatefulWidget {
  // ── Data passed in from LoginScreen
  final String mobile;
  final String fToken;
  final String cid;
  final String latitude;
  final String longitude;
  final String deviceId;
  final String appSignature;

  const OtpScreen({
    super.key,
    required this.mobile,
    required this.fToken,
    required this.cid,
    required this.latitude,
    required this.longitude,
    required this.deviceId,
    required this.appSignature,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  int secondsRemaining = 30;
  Timer? timer;
  final TextEditingController otpController = TextEditingController();

  // API loading states
  bool _isVerifying = false;
  bool _isResending = false;

  // f_token can be refreshed on resend; start with what login gave us
  late String _currentToken;

  @override
  void initState() {
    super.initState();
    _currentToken = widget.fToken;
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (secondsRemaining > 0) {
        setState(() {
          secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    otpController.dispose();
    timer?.cancel();
    super.dispose();
  }

  // ── Verify OTP API call ───────────────────────────────────────────────────
  Future<void> _verifyOtp() async {
    final enteredOtp = otpController.text.trim();
    if (enteredOtp.length < 6) {
      _showError('Please enter the complete 6-digit OTP.');
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final request = OtpRequest(
        cid: widget.cid,
        mobile: widget.mobile,
        otp: enteredOtp,
        token: _currentToken,
      );

      final response = await OtpApi.verifyOtp(request);

      if (!mounted) return;

      if (!response.error) {
        // Save persistent login data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user_id', response.userId);
        await prefs.setString('token', response.fToken);
        final loginPhone = response.mobile.isNotEmpty ? response.mobile : widget.mobile;
        await prefs.setString('phone', loginPhone);
        await prefs.setString('mobile', loginPhone);
        await prefs.setString('login_mobile', loginPhone);
        
        if (!mounted) return;
        if (response.isProfileComplete) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const SignupScreen(),
            ),
          );
        }
      } else {
        _showError(response.errorMsg.isNotEmpty
            ? response.errorMsg
            : 'OTP verification failed. Please try again.');
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Something went wrong. Please check your connection.');
      print('[OtpScreen] Verify error: $e');
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  // ── Resend OTP API call ───────────────────────────────────────────────────
  Future<void> _resendOtp() async {
    setState(() => _isResending = true);

    try {
      final json = await OtpApi.resendOtp(
        cid: widget.cid,
        mobile: widget.mobile,
        appSignature: widget.appSignature,
      );

      if (!mounted) return;

      final bool hasError = json['error'] ?? true;

      if (!hasError) {
        // Update token with the freshly issued one
        final newToken = json['f_token']?.toString() ?? _currentToken;
        setState(() {
          _currentToken = newToken;
          secondsRemaining = 30;
        });
        otpController.clear();
        startTimer();
        _showSuccess('OTP resent successfully.');
      } else {
        final msg = json['error_msg']?.toString() ?? '';
        _showError(msg.isNotEmpty ? msg : 'Failed to resend OTP. Try again.');
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Something went wrong. Please check your connection.');
      print('[OtpScreen] Resend error: $e');
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: const TextStyle(fontFamily: 'Lato', color: Colors.white)),
        backgroundColor: const Color(0xFFBE000C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: const TextStyle(fontFamily: 'Lato', color: Colors.white)),
        backgroundColor: const Color(0xFF005F65),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Lato'),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFFFBF8F8),
          titleSpacing: 0,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            icon: Icon(
              Icons.arrow_back,
              color: const Color(0XFF005f65),
              size: 24.r,
            ),
          ),
          title: Text(
            'OTP Verification',
            style: TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w500,
              fontSize: 18.sp,
              color: const Color(0xFF005F65),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 28.w),
            child: Column(
              children: [
                SizedBox(height: 24.h),
                Image.asset(
                  'assets/login_image/otp.png',
                  height: 220.h,
                  width: 220.w,
                ),
                SizedBox(height: 24.h),
                Text(
                  'Your One Time Password (OTP) has been\nSend via SMS to Registered Mobile Number',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    height: 1.5,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF000000),
                  ),
                ),
                SizedBox(height: 24.h),
                PinCodeTextField(
                  appContext: context,
                  length: 6,
                  controller: otpController,
                  autoDisposeControllers: false,
                  keyboardType: TextInputType.number,
                  animationType: AnimationType.fade,
                  autoFocus: true,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(10.r),
                    fieldHeight: 46.h,
                    fieldWidth: 42.w,
                    borderWidth: 0.5,
                    activeColor: const Color(0xFF005F65),
                    selectedColor: const Color(0xFF005F65),
                    inactiveColor: const Color(0xFF005F65),
                  ),
                  onChanged: (value) {},
                  onCompleted: (value) {},
                ),
                SizedBox(height: 20.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: secondsRemaining == 0
                      ? GestureDetector(
                          onTap: _isResending ? null : _resendOtp,
                          child: _isResending
                              ? SizedBox(
                                  width: 20.r,
                                  height: 20.r,
                                  child: const CircularProgressIndicator(
                                    color: Color(0xFF005F65),
                                    strokeWidth: 2,
                                  ),
                                )
                              : Container(
                                  padding: EdgeInsets.only(bottom: 2.h),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Color(0XFF005F65),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    'Resend OTP',
                                    style: TextStyle(
                                      color: const Color(0XFF005F65),
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.only(bottom: 2.h),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Color(0XFF005F65),
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Resend OTP in',
                                style: TextStyle(
                                  color: const Color(0XFF005F65),
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            SizedBox(width: 5.w),
                            Text(
                              '$secondsRemaining Sec',
                              style: TextStyle(
                                color: const Color(0XFF005F65),
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                ),
                SizedBox(height: 32.h),
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF005F65),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    onPressed: _isVerifying ? null : _verifyOtp,
                    child: _isVerifying
                        ? SizedBox(
                            width: 22.r,
                            height: 22.r,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            'VERIFY',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16.sp,
                              color: const Color(0xFFFFFFFF),
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}