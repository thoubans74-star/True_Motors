import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:true_motors/provider/common_dropdown_provider.dart';
import 'package:true_motors/provider/seller_insert_step_provider.dart';

import 'sell_car_photo_screen.dart';

class SellVehicleConditionScreen extends StatefulWidget {
  final String registrationNumber;
  final String vehicleType;
  final String brand;
  final String model;
  final String fuelType;
  final String transmission;
  final String? category;
  final String mfgYear;
  final String kmDriven;
  final String location;
  final String rto;
  final String regYear;
  final String owner;
  final String color;
  final String? currentLocation;
  final String? vehicleLocation;
  final String? listingId;

  const SellVehicleConditionScreen({
    super.key,
    required this.registrationNumber,
    required this.vehicleType,
    required this.brand,
    required this.model,
    required this.fuelType,
    required this.transmission,
    this.category,
    required this.mfgYear,
    required this.kmDriven,
    required this.location,
    required this.rto,
    required this.regYear,
    required this.owner,
    required this.color,
    this.currentLocation,
    this.vehicleLocation,
    this.listingId,
  });

  @override
  State<SellVehicleConditionScreen> createState() =>
      _SellVehicleConditionScreenState();
}

class _SellVehicleConditionScreenState
    extends State<SellVehicleConditionScreen> {
  // ── Vehicle Condition ───────────────────────────────────────────────────
  String? _selectedConditionLabel = 'Good';
  String? _selectedConditionValue = '2';
  String? _openDropdown;
  bool _isSubmittingStep3 = false;

  void _toggleDropdown(String key) {
    setState(() => _openDropdown = _openDropdown == key ? null : key);
  }

  // ── Price & Negotiable ────────────────────────────────────────────────────
  final TextEditingController _priceController = TextEditingController();
  bool _isNegotiable = true;
  String? _priceError;

  // ── Disclosures ───────────────────────────────────────────────────────────
  bool _accidentHistory = false;
  bool _serviceHistory = false;
  bool _insuranceAvailable = false;
  bool _pucAvailable = false;

  final TextEditingController _insuranceDateController =
      TextEditingController();
  final TextEditingController _pucDateController = TextEditingController();

  String? _insuranceDateError;
  String? _pucDateError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final commonProvider = context.read<CommonDropdownProvider>();
      await commonProvider.fetchVehicleConditions();
      if (!mounted) return;
      final items = commonProvider.conditionItems;
      if (items.isNotEmpty) {
        // Resolve initial condition to ensure label and value are in sync
        final match = items.firstWhere(
          (e) =>
              e.value == _selectedConditionValue ||
              e.label.toLowerCase() ==
                  (_selectedConditionLabel ?? 'good').toLowerCase(),
          orElse: () => items.first,
        );
        setState(() {
          _selectedConditionLabel = match.label;
          _selectedConditionValue = match.value;
        });
      }
    });
  }

  @override
  void dispose() {
    _priceController.dispose();
    _insuranceDateController.dispose();
    _pucDateController.dispose();
    super.dispose();
  }

  void _onSaveAndNext() {
    bool valid = true;
    final priceText = _priceController.text.trim();

    if (priceText.isEmpty) {
      setState(() => _priceError = 'Please enter expected price');
      valid = false;
    } else {
      setState(() => _priceError = null);
    }

    if (_insuranceAvailable && _insuranceDateController.text.trim().isEmpty) {
      setState(() => _insuranceDateError = 'Please select insurance expiry date');
      valid = false;
    } else {
      setState(() => _insuranceDateError = null);
    }

    if (_pucAvailable && _pucDateController.text.trim().isEmpty) {
      setState(() => _pucDateError = 'Please select PUC expiry date');
      valid = false;
    } else {
      setState(() => _pucDateError = null);
    }

    if (!valid) return;

    if (_isSubmittingStep3) return;
    setState(() => _isSubmittingStep3 = true);

    final stepProvider = context.read<SellerInsertStepProvider>();
    final activeListingId = widget.listingId ?? stepProvider.currentListingId;

    () async {
      try {
        final step3Res = await stepProvider.submitStep3(
          listingId: activeListingId,
          sellingPrice: priceText,
          vehicleCondition: _selectedConditionValue ?? '1',
          negotiable: _isNegotiable ? '1' : '2',
          accidentHistory: _accidentHistory ? '1' : '2',
          serHistory: _serviceHistory ? '1' : '2',
          insAvil: _insuranceAvailable ? '2' : '1',
          insExpDate: _insuranceAvailable ? _insuranceDateController.text.trim() : '',
          pucAvil: _pucAvailable ? '2' : '1',
          pucExpDate: _pucAvailable ? _pucDateController.text.trim() : '',
        );

        if (!mounted) return;
        setState(() => _isSubmittingStep3 = false);

        if (step3Res != null) {
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
                category: widget.category,
                mfgYear: widget.mfgYear,
                kmDriven: widget.kmDriven,
                location: widget.location,
                rto: widget.rto,
                regYear: widget.regYear,
                owner: widget.owner,
                color: widget.color,
                currentLocation: widget.vehicleLocation ?? widget.currentLocation,
                vehicleLocation: widget.vehicleLocation ?? widget.currentLocation,
                condition: _selectedConditionValue ?? '2',
                conditionLabel: _selectedConditionLabel ?? 'Good',
                price: priceText,
                isNegotiable: _isNegotiable,
                accidentHistory: _accidentHistory,
                serviceHistory: _serviceHistory,
                insuranceAvailable: _insuranceAvailable,
                insuranceDate: _insuranceDateController.text.trim(),
                pucAvailable: _pucAvailable,
                pucDate: _pucDateController.text.trim(),
                listingId: step3Res.listingId.isNotEmpty ? step3Res.listingId : activeListingId,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(stepProvider.step3Error ?? 'Failed to save condition details. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        setState(() => _isSubmittingStep3 = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }();
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final commonDropdownProvider = context.watch<CommonDropdownProvider>();
    final conditionItems = commonDropdownProvider.conditionItems;

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
                child: GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    if (_openDropdown != null) {
                      setState(() => _openDropdown = null);
                    }
                  },
                  behavior: HitTestBehavior.translucent,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPromoBanner(),
                        SizedBox(height: 16.h),

                        // ── Registration Number Badge ────────────────────────
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F3F3),
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            widget.registrationNumber,
                            style: TextStyle(
                                fontSize: 14.sp, fontWeight: FontWeight.w500),
                          ),
                        ),
                        SizedBox(height: 20.h),

                        // ── Vehicle Condition Section ────────────────────────
                        Text(
                          'Vehicle condition',
                          style: TextStyle(
                              fontSize: 15.sp, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 12.h),
                        _buildInlineDropdown(
                          key: 'condition',
                          label: 'Overall condition',
                          value: _selectedConditionLabel,
                          items: conditionItems,
                          isLoading: commonDropdownProvider.isConditionLoading,
                          emptyMessage: commonDropdownProvider.conditionError ??
                              'No condition options available',
                          onSelected: (item) => setState(() {
                            _selectedConditionLabel = item.label;
                            _selectedConditionValue = item.value;
                            _openDropdown = null;
                          }),
                        ),
                        SizedBox(height: 20.h),

                        // ── Price Section ────────────────────────────────────
                        Text(
                        'Price',
                        style: TextStyle(
                            fontSize: 15.sp, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Expected selling price',
                        style:
                            TextStyle(fontSize: 12.sp, color: Colors.black54),
                      ),
                      SizedBox(height: 8.h),
                      TextField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        style: TextStyle(fontSize: 14.sp),
                        onChanged: (val) {
                          if (_priceError != null) {
                            setState(() => _priceError = null);
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'e.g.698000',
                          hintStyle: TextStyle(
                              fontSize: 14.sp, color: Colors.grey),
                          errorText: _priceError,
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(12.w),
                            child: Text(
                              '₹',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: const Color(0xFF005F65),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          prefixIconConstraints: const BoxConstraints(
                              minWidth: 0, minHeight: 0),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 14.h),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(
                              color: _priceError != null
                                  ? Colors.red
                                  : const Color(0xFFE2E2E2),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide:
                                const BorderSide(color: Color(0xFF005F65)),
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // ── Disclosures Section ──────────────────────────────
                      Text(
                        'Disclosures',
                        style: TextStyle(
                            fontSize: 15.sp, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Required — these appear on the listing',
                        style:
                            TextStyle(fontSize: 12.sp, color: Colors.black54),
                      ),
                      SizedBox(height: 16.h),
                      _buildDisclosureRow('Accident history', _accidentHistory,
                          (v) => setState(() => _accidentHistory = v)),
                      _buildDisclosureRow(
                          'Service history\navailable',
                          _serviceHistory,
                          (v) => setState(() => _serviceHistory = v)),
                      _buildDisclosureRow('Price negotiable', _isNegotiable,
                          (v) => setState(() => _isNegotiable = v)),
                      _buildDisclosureRow(
                        'Insurance\navailable',
                        _insuranceAvailable,
                        (v) {
                          setState(() {
                            _insuranceAvailable = v;
                            if (!v) {
                              _insuranceDateController.clear();
                              _insuranceDateError = null;
                            }
                          });
                        },
                      ),
                      if (_insuranceAvailable) ...[
                        Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: _buildDateField(
                            controller: _insuranceDateController,
                            hintText: 'Select insurance expiry date',
                            errorText: _insuranceDateError,
                            onDateSelected: () {
                              if (_insuranceDateError != null) {
                                setState(() => _insuranceDateError = null);
                              }
                            },
                          ),
                        ),
                      ],
                      _buildDisclosureRow(
                        'PUC available',
                        _pucAvailable,
                        (v) {
                          setState(() {
                            _pucAvailable = v;
                            if (!v) {
                              _pucDateController.clear();
                              _pucDateError = null;
                            }
                          });
                        },
                      ),
                      if (_pucAvailable) ...[
                        Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: _buildDateField(
                            controller: _pucDateController,
                            hintText: 'Select PUC expiry date',
                            errorText: _pucDateError,
                            onDateSelected: () {
                              if (_pucDateError != null) {
                                setState(() => _pucDateError = null);
                              }
                            },
                          ),
                        ),
                      ],
                      SizedBox(height: 40.h),

                      // ── Save & Next Button ───────────────────────────────
                      Center(
                        child: SizedBox(
                          width: 230.w,
                          height: 48.h,
                          child: ElevatedButton(
                            onPressed: _isSubmittingStep3 ? null : _onSaveAndNext,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF005F65),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r)),
                              elevation: 0,
                            ),
                            child: _isSubmittingStep3
                                ? SizedBox(
                                    width: 22.r,
                                    height: 22.r,
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
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

  Widget _buildDateField({
    required TextEditingController controller,
    required String hintText,
    String? errorText,
    VoidCallback? onDateSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          readOnly: true,
          onTap: () async {
            DateTime initial = DateTime.now();
            final currentText = controller.text.trim();
            if (currentText.isNotEmpty) {
              final parts = currentText.split('-');
              if (parts.length == 3) {
                final d = int.tryParse(parts[0]);
                final m = int.tryParse(parts[1]);
                final y = int.tryParse(parts[2]);
                if (d != null && m != null && y != null) {
                  final parsed = DateTime(y, m, d);
                  if (parsed.isAfter(DateTime(2000)) &&
                      !parsed.isAfter(DateTime(2040))) {
                    initial = parsed;
                  }
                }
              }
            }
            final picked = await showDatePicker(
              context: context,
              initialDate: initial,
              firstDate: DateTime(2000),
              lastDate: DateTime(2040),
              builder: (ctx, child) => Theme(
                data: Theme.of(ctx).copyWith(
                  colorScheme:
                      const ColorScheme.light(primary: Color(0xFF005F65)),
                ),
                child: child!,
              ),
            );
            if (picked != null) {
              final d = picked.day.toString().padLeft(2, '0');
              final m = picked.month.toString().padLeft(2, '0');
              final y = picked.year.toString();
              setState(() {
                controller.text = '$d-$m-$y';
              });
              onDateSelected?.call();
            }
          },
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(fontSize: 13.5.sp, color: Colors.black45),
            filled: true,
            fillColor: Colors.white,
            suffixIcon: Icon(Icons.calendar_month_outlined,
                color: const Color(0xFF742B88), size: 20.r),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(
                color:
                    errorText != null ? Colors.red : const Color(0xFFE2E2E2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Color(0xFF005F65)),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: EdgeInsets.only(top: 4.h, left: 4.w),
            child: Text(
              errorText,
              style: TextStyle(color: Colors.red, fontSize: 11.5.sp),
            ),
          ),
      ],
    );
  }

  Widget _buildInlineDropdown({
    required String key,
    required String label,
    required String? value,
    required List<ListDropdownItem> items,
    required ValueChanged<ListDropdownItem> onSelected,
    bool isLoading = false,
    String? emptyMessage,
  }) {
    final isOpen = _openDropdown == key;
    final hasValue = value != null && value.isNotEmpty;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Floating label above — only when value is selected
          if (hasValue)
            Padding(
              padding: EdgeInsets.only(left: 8.w, bottom: 4.h),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: const Color(0xFF005F65),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          // Header
          GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              _toggleDropdown(key);
            },
            child: Container(
              height: 46.h,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: isOpen
                      ? const Color(0xFF005F65)
                      : const Color(0xFFE2E2E2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      hasValue ? value : label,
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        color: hasValue ? Colors.black : const Color(0xFF757575),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (isLoading)
                    SizedBox(
                      width: 16.r,
                      height: 16.r,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF005F65),
                      ),
                    )
                  else
                    Icon(
                      isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                      size: 24.r,
                      color: const Color(0xFF742B88),
                    ),
                ],
              ),
            ),
          ),

          // Items panel
          if (isOpen)
            Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: isLoading
                  ? Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 14.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F4F4),
                        border: Border.all(color: const Color(0xFFE2E2E2)),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16.r,
                            height: 16.r,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF005F65),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Loading...',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    )
                  : items.isEmpty
                      ? Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 12.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F4F4),
                            border: Border.all(color: const Color(0xFFE2E2E2)),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            emptyMessage ?? 'No options available',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.black54,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      : Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: const Color(0x59005F65)),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0F000000),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: List.generate(items.length, (index) {
                              final item = items[index];
                              final isSelected = item.label == value ||
                                  item.value == _selectedConditionValue;

                              return GestureDetector(
                                onTap: () => onSelected(item),
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14.w,
                                    vertical: 12.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFFE8F3F1)
                                        : (index % 2 == 0
                                            ? const Color(0xFFF9F9F9)
                                            : Colors.white),
                                    border: index < items.length - 1
                                        ? const Border(
                                            bottom: BorderSide(
                                              color: Color(0xFFEEEEEE),
                                              width: 0.8,
                                            ),
                                          )
                                        : null,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.label,
                                          style: TextStyle(
                                            fontSize: 13.5.sp,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w500,
                                            color: isSelected
                                                ? const Color(0xFF005F65)
                                                : const Color(0xFF1E1E1E),
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        Icon(
                                          Icons.check_circle_rounded,
                                          size: 18.r,
                                          color: const Color(0xFF005F65),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
            ),
        ],
      ),
    );
  }
}
