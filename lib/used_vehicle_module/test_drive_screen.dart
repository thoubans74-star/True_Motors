import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'buy_car.dart'; // for CarListingCard, CarListing

// ─── Test Drive Screen ────────────────────────────────────────────────────────

class TestDriveScreen extends StatefulWidget {
  const TestDriveScreen({super.key});

  @override
  State<TestDriveScreen> createState() => _TestDriveScreenState();
}

class _TestDriveScreenState extends State<TestDriveScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeSlotController = TextEditingController();

  String? _selectedVehicle;
  String? _selectedLocation;
  bool _bookingSuccess = false;
  bool _isCardFav = false; // ← favorite state for the summary card
  DateTime? _selectedDate;

  // The car shown in the summary card
  static const _car = CarListing(
    name: 'Maruti Suzuki Swift VXI 2021',
    km: 25000,
    fuel: 'Petrol',
    transmission: 'Manual',
    price: 9.2,
    emi: 13470,
    location: 'Coimbatore',
    imagePath: 'assets/buy_car/suzuki.png',
  );

  final List<String> _vehicleOptions = [
    'Maruti Suzuki Swift VXI 2021',
    'Maruti Suzuki Baleno',
    'Hyundai Creta 2023',
    'Tata Nexon',
    'Honda City',
  ];

  final List<String> _locationOptions = [
    'Coimbatore',
    'Chennai',
    'Bangalore',
    'Madurai',
    'Salem',
  ];

  final List<String> _timeSlots = [
    '9:00 AM - 10:00 AM',
    '10:00 AM - 11:00 AM',
    '11:00 AM - 12:00 PM',
    '2:00 PM - 3:00 PM',
    '3:00 PM - 4:00 PM',
    '4:00 PM - 5:00 PM',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _dateController.dispose();
    _timeSlotController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF1A3A5C),
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Color(0xFF333333),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text =
        '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}';
      });
    }
  }

  void _submitTestDrive() {
    if (_formKey.currentState!.validate()) {
      setState(() => _bookingSuccess = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              height: statusBarHeight, color: Colors.transparent,
            ),
            Expanded(
              child: SafeArea(
                top: false,
                child: _bookingSuccess
                    ? _buildSuccessScreen(context)
                    : Column(
                  children: [
                    _buildTopBar(context),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Car summary using shared CarListingCard ────────
                              CarListingCard(
                                car: _car,
                                isFav: _isCardFav,
                                onFavToggle: () =>
                                    setState(() => _isCardFav = !_isCardFav),
                                onViewDetails: () =>
                                    Navigator.maybePop(context),
                              ),
                              const SizedBox(height: 16),

                              // ── Form fields inside white card ──────────────────
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildTextField(
                                      controller: _nameController,
                                      label: 'Full Name',
                                      hint: 'Enter your full name',
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'[a-zA-Z ]')),
                                      ],
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Name is required';
                                        }
                                        if (!RegExp(r'^[a-zA-Z ]+$')
                                            .hasMatch(value.trim())) {
                                          return 'Only alphabets are allowed';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 14),
                                    _buildTextField(
                                      controller: _phoneController,
                                      label: 'Contact Number',
                                      hint: 'Enter your contact number',
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(10),
                                      ],
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Contact number is required';
                                        }
                                        if (value.length != 10) {
                                          return 'Enter a valid 10-digit mobile number';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 14),
                                    _buildTextField(
                                      controller: _emailController,
                                      label: 'Email Address',
                                      hint: 'Enter your email address',
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Email is required';
                                        }
                                        if (!RegExp(
                                          r'^[a-zA-Z0-9._%+-]+@gmail\.com$',
                                        ).hasMatch(value.trim())) {
                                          return 'Enter a valid Gmail address';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 14),
                                    _buildVehicleDropdown(),
                                    const SizedBox(height: 14),
                                    _buildDateField(),
                                    const SizedBox(height: 14),
                                    _buildLocationDropdown(),
                                    const SizedBox(height: 14),
                                    _buildTimeSlotField(),
                                    const SizedBox(height: 28),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: _submitTestDrive,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                          const Color(0xFF005F65),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 14),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: const Text('Book Test Drive',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
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

  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Icon(Icons.arrow_back,
                size: 24.r, color: const Color(0xFF01422D)),
          ),
          SizedBox(width: 12.w),
          Text('Schedule free Test Drive',
              style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF01422D))),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF000000))),
        SizedBox(height: 6.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          inputFormatters: inputFormatters,
          style: TextStyle(fontSize: 14.sp, color: const Color(0xFF000000)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
            TextStyle(fontSize: 12.sp, color: const Color(0xFF737373)),
            contentPadding:
            EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: Color(0xFF8C8C8C))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: Color(0xFF8C8C8C))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: Color(0xFF8C8C8C))),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: Color(0xFFE53935))),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Vehicle',
            style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF000000))),
        SizedBox(height: 6.h),
        DropdownButtonFormField<String>(
          value: _selectedVehicle,
          dropdownColor: Colors.white,
          hint: Text('Car',
              style: TextStyle(fontSize: 12.sp, color: const Color(0xFF737373))),
          validator: (v) =>
          v == null ? 'Please select a vehicle' : null,
          items: _vehicleOptions
              .map((v) => DropdownMenuItem(
            value: v,
            child: Text(v,
                style: TextStyle(
                    fontSize: 14.sp, color: const Color(0xFF000000))),
          ))
              .toList(),
          onChanged: (v) => setState(() => _selectedVehicle = v),
          decoration: _dropdownDecoration(),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Preferred Date',
            style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF000000))),
        SizedBox(height: 6.h),
        TextFormField(
          controller: _dateController,
          readOnly: true,
          onTap: _pickDate,
          validator: (v) =>
          v!.isEmpty ? 'Please select a date' : null,
          style: TextStyle(fontSize: 14.sp, color: const Color(0xFF333333)),
          decoration: InputDecoration(
            hintText: 'Select preferred date',
            hintStyle:
            TextStyle(fontSize: 12.sp, color: const Color(0xFF737373)),
            suffixIcon: Icon(Icons.calendar_month_outlined,
                size: 22.r, color: const Color(0xFF005F65)),
            contentPadding:
            EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: Color(0xFF7D7D7D))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: Color(0xFF7D7D7D))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: Color(0xFF7D7D7D))),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: Color(0xFFE53935))),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your Location',
            style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF000000))),
        SizedBox(height: 6.h),
        DropdownButtonFormField<String>(
          value: _selectedLocation,
          dropdownColor: Colors.white,
          hint: Text('Coimbatore',
              style: TextStyle(fontSize: 12.sp, color: const Color(0xFF737373))),
          validator: (v) =>
          v == null ? 'Please select a location' : null,
          items: _locationOptions
              .map((l) => DropdownMenuItem(
            value: l,
            child: Text(l,
                style: TextStyle(
                    fontSize: 14.sp, color: const Color(0xFF000000))),
          ))
              .toList(),
          onChanged: (v) => setState(() => _selectedLocation = v),
          decoration: _dropdownDecoration(),
        ),
      ],
    );
  }

  Widget _buildTimeSlotField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Preferred Time Slot',
            style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF000000))),
        SizedBox(height: 6.h),
        TextFormField(
          controller: _timeSlotController,
          readOnly: true,
          validator: (v) =>
          v!.isEmpty ? 'Please select a time slot' : null,
          style: TextStyle(fontSize: 14.sp, color: const Color(0xFF000000)),
          onTap: _showTimeSlotPicker,
          decoration: InputDecoration(
            hintText: 'Select time slot',
            hintStyle:
            TextStyle(fontSize: 12.sp, color: const Color(0xFF737373)),
            suffixIcon: Icon(Icons.arrow_drop_down,
                size: 25.r, color: const Color(0xFF005F65)),
            contentPadding:
            EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: Color(0xFF7D7D7D))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: Color(0xFF7D7D7D))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: Color(0xFF7D7D7D))),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: Color(0xFFE53935))),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  void _showTimeSlotPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Text('Select Time Slot',
                style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF000000))),
          ),
          const Divider(height: 1),
          ..._timeSlots.map(
                (slot) => ListTile(
              title: Text(slot,
                  style: TextStyle(
                      fontSize: 14.sp, color: const Color(0xFF333333))),
              trailing: _timeSlotController.text == slot
                  ? Icon(Icons.check, color: const Color(0xFF1A3A5C), size: 20.r)
                  : null,
              onTap: () {
                setState(() => _timeSlotController.text = slot);
                Navigator.pop(context);
              },
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      contentPadding:
      EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: Color(0xFF7D7D7D))),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: Color(0xFF7D7D7D))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: Color(0xFF7D7D7D))),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: Color(0xFFE53935))),
      filled: true,
      fillColor: Colors.white,
    );
  }

  // ─── Success Screen ─────────────────────────────────────────────────────────

  Widget _buildSuccessScreen(BuildContext context) {
    final now = DateTime.now();
    final formatted =
        '${now.day} ${_monthName(now.month)}-${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')} ${now.hour < 12 ? 'AM' : 'PM'}';

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFFFFFFF),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/buy_car/tick.gif',
                    width: 170.w,
                    height: 170.h,
                  ),
                  SizedBox(height: 24.h),
                  Text('Congratulations',
                      style: TextStyle(
                        fontFamily: 'Inter',
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF000000))),
                  SizedBox(height: 24.h),
                  Text('Your free test drive booking',
                      style: TextStyle(fontSize: 15.sp, color: const Color(0xFF000000), fontFamily: 'Inter'),
                      textAlign: TextAlign.center),
                  Text('Confirmed on $formatted',
                      style: TextStyle(
                          fontSize: 15.sp,
                          color: const Color(0xFF000000),
                          fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center),
                  SizedBox(height: 48.h),
                  SizedBox(
                    width: 250.w,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context)
                          ..pop()
                          ..pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF005F65),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r)),
                      ),
                      child: Text('Back',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16.sp)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  String _monthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }
}