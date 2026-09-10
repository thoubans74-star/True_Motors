import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'sell_car_photo_screen.dart';

class SellVehicleConditionScreen extends StatefulWidget {
  final String registrationNumber;
  final String vehicleType;
  final String brand;
  final String model;
  final String fuelType;
  final String transmission;
  final String mfgYear;
  final String kmDriven;
  final String location;
  final String rto;
  final String regYear;
  final String owner;
  final String color;

  const SellVehicleConditionScreen({
    super.key,
    required this.registrationNumber,
    required this.vehicleType,
    required this.brand,
    required this.model,
    required this.fuelType,
    required this.transmission,
    required this.mfgYear,
    required this.kmDriven,
    required this.location,
    required this.rto,
    required this.regYear,
    required this.owner,
    required this.color,
  });

  @override
  State<SellVehicleConditionScreen> createState() =>
      _SellVehicleConditionScreenState();
}

class _SellVehicleConditionScreenState
    extends State<SellVehicleConditionScreen> {
  final List<String> _featuresList = [
    'ABS',
    'Airbags',
    'Alloy Wheel',
    'Sun roof',
    'Power Steering',
    'Bluetooth',
    'Rear Camera',
    'Cruise Control',
    'Touch screen',
    'Others'
  ];
  final List<String> _selectedFeatures = [];

  String? _selectedCondition;
  final List<String> _conditions = ['Excellent', 'Good', 'Fair', 'Poor'];

  bool _accidentHistory = false;
  bool _serviceHistory = false;
  bool _insuranceAvailable = false;
  bool _pucAvailable = false;

  final TextEditingController _dateController = TextEditingController();

  void _onSaveAndNext() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SellCarPhotoScreen(
          registrationNumber: widget.registrationNumber,
          vehicleType: widget.vehicleType,
          brand: widget.brand,
          model: widget.model,
          fuelType: widget.fuelType,
          transmission: widget.transmission,
          regYear: widget.regYear,
          kmDriven: widget.kmDriven,
          location: widget.location,
          rto: widget.rto,
          features: _selectedFeatures,
          // Wait, SellCarPhotoScreen will be updated later. I will pass the required data for it after I modify it.
          // Currently SellCarPhotoScreen expects price, insuranceDate, features. Let's provide defaults for now.
          price: '0',
          insuranceDate: '',
        ),
      ),
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F3F3),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              height: statusBarHeight,
              color: Colors.white,
            ),
            _buildAppBar(),
            Expanded(
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPromoBanner(),
                      SizedBox(height: 16.h),
                      Text(
                        'Condition & features',
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Buyers filter by this before anything else — be accurate, it protects you at handover too.',
                        style: TextStyle(
                            fontSize: 12.sp, color: Colors.black54),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        'Feature Checklist',
                        style: TextStyle(
                            fontSize: 14.sp, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 12.h),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 12.h,
                        children: _featuresList.map((f) {
                          final isSelected = _selectedFeatures.contains(f);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedFeatures.remove(f);
                                } else {
                                  _selectedFeatures.add(f);
                                }
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 14.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF005F65)
                                      : const Color(0xFFE2E2E2),
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Text(
                                f,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        'Vehicle condition',
                        style: TextStyle(
                            fontSize: 15.sp, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Overall condition',
                        style: TextStyle(
                            fontSize: 12.sp, color: Colors.black54),
                      ),
                      SizedBox(height: 8.h),
                      _buildDropdown(),
                      SizedBox(height: 24.h),
                      Text(
                        'Disclosures',
                        style: TextStyle(
                            fontSize: 15.sp, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Required — these appear on the listing',
                        style: TextStyle(
                            fontSize: 12.sp, color: Colors.black54),
                      ),
                      SizedBox(height: 16.h),
                      _buildDisclosureRow('Accident history', _accidentHistory,
                          (v) => setState(() => _accidentHistory = v)),
                      _buildDisclosureRow('Service history\navailable',
                          _serviceHistory,
                          (v) => setState(() => _serviceHistory = v)),
                      _buildDisclosureRow('Insurance\navailable',
                          _insuranceAvailable,
                          (v) => setState(() => _insuranceAvailable = v)),
                      _buildDisclosureRow('PUC available', _pucAvailable,
                          (v) => setState(() => _pucAvailable = v)),
                      SizedBox(height: 16.h),
                      _buildDateField(),
                      SizedBox(height: 40.h),
                      Center(
                        child: SizedBox(
                          width: 230.w,
                          height: 48.h,
                          child: ElevatedButton(
                            onPressed: _onSaveAndNext,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF005F65),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r)),
                              elevation: 0,
                            ),
                            child: Text(
                              'Save & Next',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.sp),
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
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back,
                size: 24.r, color: const Color(0xFF01422D)),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            'Sell car',
            style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF01422D),
                fontFamily: 'Poppins'),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFF00274B),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/sell_image/red_car.png',
            width: 125.w,
            height: 110.h,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Sell Your Car Instantly',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Calistoga',
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15.5.sp,
                    ),
                  ),
                ),
                SizedBox(height: 1.h),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Best price,Free inspection.\nInstant payment',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Calistoga',
                      color: Colors.white,
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Get Free Quote',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Calistoga',
                        color: const Color(0xFF000000),
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      height: 46.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFE2E2E2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCondition,
          hint: Text('Good',
              style: TextStyle(fontSize: 13.5.sp, color: Colors.black)),
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down,
              color: const Color(0xFF742B88), size: 24.r),
          items: _conditions.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: TextStyle(fontSize: 13.5.sp)),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedCondition = newValue;
            });
          },
        ),
      ),
    );
  }

  Widget _buildDisclosureRow(
      String title, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 14.sp, color: Colors.black),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => onChanged(true),
                child: Container(
                  width: 60.w,
                  height: 32.h,
                  decoration: BoxDecoration(
                    color: value ? const Color(0xFF742B88) : Colors.white,
                    border: Border.all(
                        color: value
                            ? const Color(0xFF742B88)
                            : const Color(0xFFE2E2E2)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Yes',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: value ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => onChanged(false),
                child: Container(
                  width: 60.w,
                  height: 32.h,
                  decoration: BoxDecoration(
                    color: !value ? const Color(0xFF742B88) : Colors.white,
                    border: Border.all(
                        color: !value
                            ? const Color(0xFF742B88)
                            : const Color(0xFFE2E2E2)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'No',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: !value ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDateField() {
    return TextField(
      controller: _dateController,
      readOnly: true,
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2035),
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: const ColorScheme.light(primary: Color(0xFF005F65)),
            ),
            child: child!,
          ),
        );
        if (picked != null) {
          _dateController.text =
              '${picked.month.toString().padLeft(2, '0')} / ${picked.day.toString().padLeft(2, '0')} / ${picked.year}';
        }
      },
      decoration: InputDecoration(
        hintText: '09 / 29 / 2026',
        hintStyle: TextStyle(fontSize: 14.sp, color: Colors.black),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: Icon(Icons.calendar_month_outlined,
            color: const Color(0xFF742B88), size: 20.r),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: Color(0xFFE2E2E2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: Color(0xFF005F65)),
        ),
      ),
    );
  }
}
