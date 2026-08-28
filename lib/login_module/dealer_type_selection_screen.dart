import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dealer_registration_screen.dart';


class DealerTypeSelectionScreen extends StatefulWidget {
  const DealerTypeSelectionScreen({super.key});

  @override
  State<DealerTypeSelectionScreen> createState() => _DealerTypeSelectionScreenState();
}

class _DealerTypeSelectionScreenState extends State<DealerTypeSelectionScreen> {
  final List<String> _selectedTypes = ['New Vehicles'];

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Lato'),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6F9),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF005F65)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Dealer Registration',
            style: TextStyle(
              color: const Color(0xFF005F65),
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress Bar
              Container(
                color: Colors.white,
                padding: EdgeInsets.only(bottom: 16.h),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 6.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFF005F65),
                            borderRadius: BorderRadius.circular(3.r),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Container(
                          height: 6.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFF005F65), // 2nd step active
                            borderRadius: BorderRadius.circular(3.r),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Container(
                          height: 6.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E0E0),
                            borderRadius: BorderRadius.circular(3.r),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'What kind of dealer are you?',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Tell us whether you sell new bikes, used ones, or both.',
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          color: const Color(0xFF4A4A4A),
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      
                      _buildTypeOption(
                        id: 'New Vehicles',
                        title: 'New Vehicles',
                        subtitle: 'Authorized / showroom sales of brand-new vehicles',
                      ),
                      SizedBox(height: 16.h),
                      _buildTypeOption(
                        id: 'Used Vehicles',
                        title: 'Used Vehicles',
                        subtitle: 'Pre-owned / second-hand vehicle sales',
                      ),
                      SizedBox(height: 16.h),
                      _buildTypeOption(
                        id: 'Both',
                        title: 'Both',
                        subtitle: 'You sell new as well as pre-owned vehicles',
                      ),
                    ],
                  ),
                ),
              ),
              
              // Continue Button
              Padding(
                padding: EdgeInsets.all(20.w),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DealerRegistrationScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF005F65),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeOption({
    required String id,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedTypes.contains(id);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_selectedTypes.contains(id)) {
            _selectedTypes.remove(id);
          } else {
            _selectedTypes.add(id);
          }
        });
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFFFFB) : Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF005F65).withValues(alpha: 0.3) : const Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      color: const Color(0xFF757575),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16.w),
            Container(
              width: 24.r,
              height: 24.r,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF6750A4) : Colors.transparent,
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(
                  color: isSelected ? const Color(0xFF6750A4) : const Color(0xFFBDBDBD),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 16.r,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

}
