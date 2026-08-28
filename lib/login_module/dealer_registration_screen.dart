import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class DealerRegistrationScreen extends StatefulWidget {
  const DealerRegistrationScreen({super.key});

  @override
  State<DealerRegistrationScreen> createState() => _DealerRegistrationScreenState();
}

class _DealerRegistrationScreenState extends State<DealerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Selected brands
  final List<String> _selectedBrands = ['TATA'];

  // List of available brands
  final List<String> _brands = [
    'TATA',
    'Hyundai',
    'Mahindra',
    'KIA',
    'Toyota',
    'Honda'
  ];

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
            'Register as a Dealer',
            style: TextStyle(
              color: const Color(0xFF005F65),
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
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
                            color: const Color(0xFF005F65), // 3rd step active
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
                  child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Show Room Details'),
                  _buildLabel('Showroom / Business Name*'),
                  _buildTextField(hint: 'e.g Prime Motors'),
                  SizedBox(height: 16.h),
                  
                  _buildLabel('Brand Dealt in'),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 12.w,
                    runSpacing: 12.h,
                    children: [
                      ..._brands.map((brand) => _buildBrandChip(brand)),
                      _buildAddMoreChip(),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  
                  _buildLabel('Year In Business'),
                  _buildTextField(hint: 'e.g 8 years'),
                  SizedBox(height: 24.h),

                  _buildSectionHeader('Owner / Contact Person'),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Full Name'),
                            _buildTextField(hint: 'owner name'),
                          ],
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Designation'),
                            _buildTextField(hint: 'e.g. manager'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  _buildLabel('Mobile Number'),
                  _buildTextField(hint: '+91 Enter Mobile Number', keyboardType: TextInputType.phone),
                  SizedBox(height: 16.h),
                  _buildLabel('Email Address'),
                  _buildTextField(hint: 'business @email.com', keyboardType: TextInputType.emailAddress),
                  SizedBox(height: 24.h),

                  _buildSectionHeader('Showroom Address'),
                  _buildLabel('Address Line'),
                  _buildTextField(hint: '', maxLines: 3),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('City'),
                            _buildTextField(hint: 'city'),
                          ],
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Pincode'),
                            _buildTextField(hint: 'pincode', keyboardType: TextInputType.number),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),

                  _buildSectionHeader('Identity Verification'),
                  _buildLabel('GSTIN Number'),
                  _buildTextField(hint: 'e.g 22AAAAA0000A1Z5'),
                  SizedBox(height: 16.h),
                  _buildLabel('Upload Document (PAN / GST / Trade License)'),
                  SizedBox(height: 8.h),
                  _buildDocumentUploadCard(
                    title: 'Government Reg. Certificate',
                    subtitle: 'Upload PDF / Image up to 5MB',
                  ),
                  SizedBox(height: 24.h),

                  _buildSectionHeader('Showroom Photos'),
                  _buildPhotoUploadContainer(),
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
                      onPressed: () {
                        _showSuccessDialog();
                      },
                      child: Text(
                        'submit for verification',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Text(
        title,
        style: TextStyle(
          color: const Color(0xFF005F65),
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.black,
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: const Color(0xFFB0B0B0), fontSize: 14.sp),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.r),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.r),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.r),
          borderSide: const BorderSide(color: Color(0xFF005F65)),
        ),
      ),
    );
  }

  Widget _buildBrandChip(String label) {
    final isSelected = _selectedBrands.contains(label);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedBrands.remove(label);
          } else {
            _selectedBrands.add(label);
          }
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF005F65) : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF005F65) : const Color(0xFFE0E0E0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF005F65),
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildAddMoreChip() {
    return GestureDetector(
      onTap: () {
        // Handle add more brand logic
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Text(
          '+ Add more',
          style: TextStyle(
            color: const Color(0xFF005F65),
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentUploadCard({required String title, required String subtitle}) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Icon(Icons.description_outlined, color: const Color(0xFF005F65), size: 24.r),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF005F65),
              side: const BorderSide(color: Color(0xFF005F65)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.r),
              ),
              minimumSize: Size(75.w, 34.h),
            ),
            child: Text('Upload', style: TextStyle(fontSize: 12.sp)),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoUploadContainer() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 28.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
          style: BorderStyle.solid, 
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.image_outlined, color: const Color(0xFF005F65), size: 32.r),
          SizedBox(height: 8.h),
          Text(
            'Upload showroom photos',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black54,
            ),
          ),
          Text(
            'PNG or JPG, up to 5 images',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 16.w),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Icon
                Container(
                  padding: EdgeInsets.all(16.w),
                  child: Image.asset('assets/login_image/register_ticket.gif', width: 110.w, height: 110.h),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Verification Details',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E3A8A), // Dark blue
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Submitted Successfully',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF00BFA5), // Greenish
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Thank you! Your dealer verification details have been submitted successfully',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.black54,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 24.h),
                // Green support box
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F8F1), // Light green
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: const BoxDecoration(
                          color: Color(0xFFD6EFD6),
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset('assets/onboarding_image/online-support 1.png', width: 22.w, height: 22.h),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Our team will reach out to you within a few hours.',
                              style: TextStyle(fontSize: 11.5.sp, fontWeight: FontWeight.bold, color: Colors.black, fontFamily: 'Poppins'),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Please keep your phone handy.',
                              style: TextStyle(fontSize: 10.5.sp, color: Colors.black54, fontFamily: 'Poppins'),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                // Got It button
                SizedBox(
                  width: double.infinity,
                  height: 46.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF005F65),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                    },
                    child: Text('Got It', style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        );
      }
    );
  }
}
