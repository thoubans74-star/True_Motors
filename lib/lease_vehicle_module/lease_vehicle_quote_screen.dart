import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LeaseVehicleQuoteScreen extends StatefulWidget {
  final Map<String, dynamic> car;

  const LeaseVehicleQuoteScreen({super.key, required this.car});

  @override
  State<LeaseVehicleQuoteScreen> createState() =>
      _LeaseVehicleQuoteScreenState();
}

class _LeaseVehicleQuoteScreenState extends State<LeaseVehicleQuoteScreen> {
  String? _selectedVehicleType;
  String? _selectedLeaseDuration;
  String? _selectedStartDate;
  String? _selectedPurpose;

  final TextEditingController _requirementsController = TextEditingController();
  final List<String> _vehicleTypes = ['Car', 'Van & Truck', 'Backhoe Holder', 'Agri Equipment'];
  final List<String> _leaseDurations = ['1 Month', '3 Months', '6 Months', '1 Year'];
  final List<String> _purposes = ['Personal Use', 'Business Use', 'Commercial Use', 'Other'];

  @override
  void dispose() {
    _requirementsController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF01422D),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedStartDate =
        '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  // Generic dropdown menu used by Vehicle Type, Lease Duration and Purpose
  // of Use rows. Anchors a real dropdown-style PopupMenu right under the
  // tapped row (instead of a bottom sheet).
  Future<void> _showDropdownMenu({
    required BuildContext context,
    required List<String> options,
    required String? selectedValue,
    required ValueChanged<String> onSelected,
  }) async {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
    Overlay.of(context).context.findRenderObject() as RenderBox;

    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset(0, button.size.height), ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    final String? selected = await showMenu<String>(
      context: context,
      position: position,
      color: Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      constraints: BoxConstraints(
        minWidth: button.size.width,
        maxWidth: button.size.width,
      ),
      items: options.map((option) {
        final bool isSelected = option == selectedValue;
        return PopupMenuItem<String>(
          value: option,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                option,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? const Color(0xFF01422D) : Colors.black87,
                ),
              ),
              if (isSelected)
                const Icon(Icons.check, color: Color(0xFF01422D), size: 18),
            ],
          ),
        );
      }).toList(),
    );

    if (selected != null) {
      onSelected(selected);
    }
  }

  void _showSuccessPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildSuccessDialog(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F2F2),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              height: statusBarHeight, color: Colors.transparent,
            ),
            // AppBar
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back,
                        color: const Color(0xFF01422D), size: 24.r),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Lease Vehicle Quote',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF01422D),
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
                    _buildBanner(),

                    SizedBox(height: 16.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Column(
                          children: [
                            _buildFormRow(
                              icon: Icons.directions_car_outlined,
                              title: 'Vehicle Type',
                              value: _selectedVehicleType ?? 'Select Vehicle Type',
                              options: _vehicleTypes,
                              selectedValue: _selectedVehicleType,
                              onSelected: (v) =>
                                  setState(() => _selectedVehicleType = v),
                            ),

                            _divider(),
                            _buildFormRow(
                              icon: Icons.calendar_month_outlined,
                              title: 'Lease Duration',
                              value: _selectedLeaseDuration ?? 'Select Duration',
                              options: _leaseDurations,
                              selectedValue: _selectedLeaseDuration,
                              onSelected: (v) =>
                                  setState(() => _selectedLeaseDuration = v),
                            ),

                            _divider(),
                            _buildFormRow(
                              icon: Icons.calendar_today_outlined,
                              title: 'Lease Start Date',
                              value: _selectedStartDate ?? 'Select Start Date',
                              onTap: _pickStartDate,
                            ),

                            _divider(),
                            _buildFormRow(
                              icon: Icons.business_center_outlined,
                              title: 'Purpose of Use',
                              value: _selectedPurpose ?? 'Select Purpose',
                              options: _purposes,
                              selectedValue: _selectedPurpose,
                              onSelected: (v) =>
                                  setState(() => _selectedPurpose = v),
                            ),
                            _buildRequirementsField(),
                            SizedBox(height: 15.h),
                            _buildHowItWorksSectionInside(),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.w),
                      child: GestureDetector(
                        onTap: _showSuccessPopup,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 20.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFF005F65),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Center(
                            child: Text(
                              'Request a Lease quote',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return Image.asset('assets/lease_image/lease_quote.png');
  }

  Widget _divider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: const Divider(
        height: 1,
        thickness: 1,
        color: Color(0xFFE5E7EB),
      ),
    );
  }

  Widget _buildFormRow({
    required IconData icon,
    required String title,
    required String value,
    List<String>? options,
    String? selectedValue,
    ValueChanged<String>? onSelected,
    VoidCallback? onTap,
  }) {
    return Builder(
      builder: (rowContext) {
        final VoidCallback? effectiveOnTap = onTap ??
            ((options != null && onSelected != null)
                ? () => _showDropdownMenu(
              context: rowContext,
              options: options,
              selectedValue: selectedValue,
              onSelected: onSelected,
            )
                : null);

        return InkWell(
          onTap: effectiveOnTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
            child: Row(
              children: [
                Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF2FF),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF0F4C81),
                    size: 22.r,
                  ),
                ),

                SizedBox(width: 14.w),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        value,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.keyboard_arrow_down,
                  size: 22.r,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRequirementsField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFFEFEFE),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
        padding: EdgeInsets.all(12.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44.r,
              height: 44.r,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2FF),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.description_outlined,
                color: const Color(0xFF0F4C81),
                size: 22.r,
              ),
            ),

            SizedBox(width: 14.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Additional Requirements (Optional)',
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  SizedBox(height: 2.h),

                  TextField(
                    controller: _requirementsController,
                    maxLines: 3,
                    maxLength: 250,
                    style: TextStyle(fontSize: 13.5.sp),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter any specific requirements...',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 13.5.sp,
                      ),
                      counterText: '',
                    ),
                  ),

                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      '${_requirementsController.text.length}/250',
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHowItWorksSectionInside() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F7FD),
            borderRadius: BorderRadius.circular(16.r),
          ),
          padding: EdgeInsets.all(16.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info,
                color: Colors.blueAccent,
                size: 22.r,
              ),
              SizedBox(width: 12.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How It Works?',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      "We'll share your request with verified vehicle owners. You will receive lease quotes with price, terms and vehicle details.",
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 5.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _howItWorksIcon(
                  Icons.verified_user_outlined,
                  'Verified Owners',
                ),
              ),
              _verticalDivider(),
              Expanded(
                child: _howItWorksIcon(
                  Icons.shield_outlined,
                  'Secure\n& Safe',
                ),
              ),
              _verticalDivider(),
              Expanded(
                child: _howItWorksIcon(
                  Icons.description_outlined,
                  'Easy Agreement',
                ),
              ),
              _verticalDivider(),
              Expanded(
                child: _howItWorksIcon(
                  Icons.support_agent,
                  '24/7\nSupport',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _howItWorksIcon(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF0F4C81), size: 22.r),
        SizedBox(height: 6.h),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11.5.sp,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 60.h,
      color: const Color(0xFFC4C4C4),
    );
  }

  Widget _buildSuccessDialog(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 140.w,
                  height: 120.h,
                  child: Stack(
                    children: [
                      const Positioned(
                          top: 10, left: 20,
                          child: _Dot(color: Color(0xFF4CAF50), size: 8)),
                      const Positioned(
                          top: 5, right: 30,
                          child: _Dot(color: Color(0xFF2196F3), size: 6)),
                      const Positioned(
                          top: 20, right: 10,
                          child: _Dot(color: Color(0xFF2196F3), size: 5)),
                      const Positioned(
                          bottom: 20, left: 10,
                          child: _Dot(color: Color(0xFFFF9800), size: 7)),
                      const Positioned(
                          bottom: 10, right: 20,
                          child: _Dot(color: Color(0xFFFF5722), size: 5)),
                      const Positioned(
                          top: 40, left: 5,
                          child: _Dot(color: Color(0xFF4CAF50), size: 5)),
                      Center(
                        child: Container(
                          width: 80.r,
                          height: 80.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFE8F5E9),
                            border: Border.all(
                              color: const Color(0xFF4CAF50),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.check_circle,
                            color: const Color(0xFF4CAF50),
                            size: 44.r,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Image.asset(
              'assets/rental_screen/Hyundai Creta.png',
              width: 110.w,
              height: 60.h,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                Icons.directions_car,
                size: 50.r,
                color: Colors.grey,
              ),
            ),

            SizedBox(height: 12.h),

            Text(
              'Quote Successfully Sent!',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 8.h),

            Text(
              'Thank you! Your lease quote request has been successfully submitted. Vehicle owners will review your request and get back to you soon with the best lease offers.',
              style: TextStyle(
                fontSize: 12.5.sp,
                color: Colors.black54,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 16.h),

            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10.r),
              ),
              padding: EdgeInsets.all(12.w),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(4.r),
                    decoration: const BoxDecoration(
                      color: Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check,
                        color: Colors.white, size: 14.r),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "What's Next?",
                          style: TextStyle(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'You will receive notifications and emails once you get a quote.',
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 13.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF003399),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Great, Thanks!',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(Icons.arrow_forward, color: Colors.white, size: 16.r),
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
}

class _Dot extends StatelessWidget {
  final Color color;
  final double size;
  const _Dot({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}