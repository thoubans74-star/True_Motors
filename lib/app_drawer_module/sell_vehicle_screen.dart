import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:true_motors/provider/used_vehicle_provider.dart';
import 'package:true_motors/provider/seller_insert_step_provider.dart';
import 'package:true_motors/sell_vehicle_module/sell_car_form_screen.dart';

class SellVehicleScreen extends StatefulWidget {
  const SellVehicleScreen({super.key});

  @override
  State<SellVehicleScreen> createState() => _SellVehicleScreenState();
}

class _SellVehicleScreenState extends State<SellVehicleScreen> {
  final TextEditingController _regController = TextEditingController();
  final FocusNode _regFocusNode = FocusNode();
  String? _regError;
  bool _isSubmittingStep1 = false;

  @override
  void initState() {
    super.initState();
    _regController.addListener(_onRegChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UsedVehicleProvider>().fetchUsedVehicleCategories();
    });
  }

  void _onRegChanged() {
    if (mounted) {
      setState(() {
        if (_regError != null) _regError = null;
      });
    }
  }

  final List<Map<String, dynamic>> _trendingCars = [
    {
      'image': 'assets/home_image/maruti_suzuki_swift.png',
      'name': 'Maruti Suzuki Swift',
      'year': '2021',
      'price': '6.98',
    },
    {
      'image': 'assets/home_image/maruti_suzuki_baleno.png',
      'name': 'Maruti Suzuki Baleno',
      'year': '2023',
      'price': '7.00',
    },
  ];

  final List<Map<String, String>> _carBrands = [
    {'image': 'assets/brands/mahindra.png'},
    {'image': 'assets/brands/toyota.png'},
    {'image': 'assets/brands/tata.png'},
    {'image': 'assets/brands/hyundai.png'},
    {'image': 'assets/brands/suzuki.png'},
    {'image': 'assets/brands/honda.png'},
    {'image': 'assets/brands/ford.png'},
    {'image': 'assets/brands/fiat.png'},
    {'image': 'assets/brands/nissan.png'},
    {'image': 'assets/brands/kia.png'},
  ];

  final List<Map<String, dynamic>> _sellingProcess = [
    {
      'title': 'Get price online',
      'desc': 'Answer some question about your car to help us understand its condition',
      'image': 'assets/sell_image/process1.png',
    },
    {
      'title': 'Car inspection',
      'desc': 'Our car expert will physically verify your cars condition and give you the final offer',
      'image': 'assets/sell_image/process2.png',
    },
    {
      'title': 'Car pick up & payment',
      'desc': 'We will transfer the amount directly to your bank account before your car is picked up',
      'image': 'assets/sell_image/process3.png',
    },
  ];

  final List<Map<String, String>> _faqs = [
    {
      'q': 'Q. Where can I Sell my car?',
      'a': 'You can sell your car through True Motors by visiting our website or app, entering your car details, and getting an instant price quote. We operate across major cities in India.',
    },
    {
      'q': 'Q. Which documents are essential for selling my car?',
      'a': 'You will need the RC (Registration Certificate), valid insurance documents, PUC certificate, original purchase invoice, and a valid ID proof such as Aadhaar or PAN card.',
    },
    {
      'q': 'Q. How soon will I receive payment after selling my car to True Motors?',
      'a': 'Payment is transferred directly to your bank account before your car is picked up. The process is instant and secure.',
    },
    {
      'q': 'Q. How long does it take to sell my car?',
      'a': 'The entire process from getting a quote to final pickup typically takes 24 to 48 hours, depending on your location and document readiness.',
    },
  ];
  final List<bool> _faqExpanded = [false, false, false, false];

  /// Indian vehicle registration number validator
  /// Supports standard state format (e.g. TN 42 A 4872, TN 42 AB 1234) and Bharat series (e.g. 22 BH 1234 AA)
  bool _isValidRegistration(String value) {
    final trimmed = value.trim().replaceAll(' ', '').replaceAll('-', '').toUpperCase();
    final standardRegex = RegExp(r'^[A-Z]{2}[0-9]{1,2}[A-Z]{0,3}[0-9]{1,4}$');
    final bhRegex = RegExp(r'^[0-9]{2}BH[0-9]{4}[A-Z]{1,2}$');
    if (trimmed.length < 5) return false;
    return standardRegex.hasMatch(trimmed) || bhRegex.hasMatch(trimmed);
  }

  _RegistrationParts _parseRegistration(String text) {
    final clean = text.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
    final bool isValid = _isValidRegistration(clean);

    // Check Bharat (BH) series format: e.g. 22 BH 1234 AA
    final bhRegex = RegExp(r'^([0-9]{0,2})(BH)?([0-9]{0,4})([A-Z]{0,2})$');
    if (clean.length >= 2 && RegExp(r'^[0-9]{2}').hasMatch(clean)) {
      final match = bhRegex.firstMatch(clean);
      final yr = match?.group(1) ?? '';
      final bh = match?.group(2) ?? '';
      final num = match?.group(3) ?? '';
      final ser = match?.group(4) ?? '';
      return _RegistrationParts(
        state: '$yr $bh'.trim(),
        rto: '',
        series: ser,
        number: num,
        currentStep: isValid ? 5 : 4,
        hintText: isValid
            ? '✓ Valid Bharat (BH) series: $yr BH $num $ser'.trim()
            : 'BH Series: Enter remaining digits/letters',
        isValid: isValid,
      );
    }

    // Standard state series
    String state = '';
    String rto = '';
    String series = '';
    String number = '';

    int i = 0;
    // 1. State letters (up to 2 letters)
    while (i < clean.length && RegExp(r'[A-Z]').hasMatch(clean[i]) && state.length < 2) {
      state += clean[i];
      i++;
    }

    // 2. RTO digits (up to 2 digits)
    while (i < clean.length && RegExp(r'[0-9]').hasMatch(clean[i]) && rto.length < 2) {
      rto += clean[i];
      i++;
    }

    // 3. Series letters (up to 3 letters)
    while (i < clean.length && RegExp(r'[A-Z]').hasMatch(clean[i]) && series.length < 3) {
      series += clean[i];
      i++;
    }

    // 4. Number digits (up to 4 digits)
    while (i < clean.length && RegExp(r'[0-9]').hasMatch(clean[i]) && number.length < 4) {
      number += clean[i];
      i++;
    }

    int currentStep = 1;
    String hintText = '';

    if (state.isEmpty) {
      currentStep = 1;
      hintText = 'Enter 2-letter State code (e.g. TN, KA, MH, DL)';
    } else if (state.length < 2) {
      currentStep = 1;
      hintText = 'State code: Enter 2nd letter (e.g. ${state}N)';
    } else if (rto.isEmpty) {
      currentStep = 2;
      hintText = 'Next: Enter 2-digit RTO number (e.g. 42, 01)';
    } else if (rto.length < 2 && i == clean.length) {
      currentStep = 2;
      hintText = 'Next: Enter 2nd digit of RTO or Series letter (e.g. A)';
    } else if (series.isEmpty && number.isEmpty) {
      currentStep = 3;
      hintText = 'Next: Enter Series letter (e.g. A, AB)';
    } else if (number.isEmpty) {
      currentStep = 4;
      hintText = 'Next: Enter 4-digit vehicle number (e.g. 4872)';
    } else if (number.length < 4 && !isValid) {
      currentStep = 4;
      hintText = 'Vehicle number: Enter remaining digits (e.g. 4872)';
    } else if (isValid) {
      currentStep = 5;
      final formatted = [
        state,
        rto,
        if (series.isNotEmpty) series,
        number,
      ].join(' ');
      hintText = '✓ Valid registration format: $formatted';
    } else {
      currentStep = 4;
      hintText = 'Format: TN 42 A 4872 (State • RTO • Series • Number)';
    }

    return _RegistrationParts(
      state: state,
      rto: rto,
      series: series,
      number: number,
      currentStep: currentStep,
      hintText: hintText,
      isValid: isValid,
    );
  }

  void _onSellVehicle() {
    final rawReg = _regController.text.trim();
    if (rawReg.isEmpty) {
      setState(() => _regError = 'Please enter your vehicle registration number');
      return;
    }
    if (!_isValidRegistration(rawReg)) {
      final parts = _parseRegistration(rawReg);
      setState(() => _regError = parts.hintText.replaceFirst('💡 ', '').replaceFirst('✓ ', ''));
      return;
    }

    setState(() => _regError = null);

    final parts = _parseRegistration(rawReg);
    final formattedReg = [
      parts.state,
      parts.rto,
      if (parts.series.isNotEmpty) parts.series,
      parts.number,
    ].where((p) => p.isNotEmpty).join(' ');

    final finalReg = formattedReg.isNotEmpty ? formattedReg : rawReg.toUpperCase();

    if (_isSubmittingStep1) return;
    setState(() => _isSubmittingStep1 = true);

    final stepProvider = context.read<SellerInsertStepProvider>();
    stepProvider.submitStep1(vehicleNo: finalReg).then((result) {
      if (!mounted) return;
      setState(() => _isSubmittingStep1 = false);

      if (result != null && result.listingId.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SellCarFormScreen(
              registrationNumber: finalReg,
              listingId: result.listingId,
            ),
          ),
        );
      } else {
        final errorMsg = stepProvider.step1Error ?? 'Failed to initialize vehicle draft. Please try again.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
          ),
        );
      }
    }).catchError((e) {
      if (!mounted) return;
      setState(() => _isSubmittingStep1 = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  @override
  void dispose() {
    _regController.removeListener(_onRegChanged);
    _regController.dispose();
    _regFocusNode.dispose();
    super.dispose();
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
      child: GestureDetector(
        // Dismiss keyboard on tap outside — keeps bottom nav fixed
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          // resizeToAvoidBottomInset: false keeps the bottom nav from moving up
          resizeToAvoidBottomInset: false,
          body: Column(
            children: [
              Container(
                width: double.infinity,
                height: statusBarHeight,
                color: Colors.white,
              ),
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPromoBanner(),
                      _buildGetPriceForm(),
                      _buildBrandSelector(),
                      const SizedBox(height: 10),
                      _buildTrendingCarsSection(),
                      _buildSellingProcess(),
                      _buildTestimonial(),
                      _buildFAQ(),
                      const SizedBox(height: 16),
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

  Widget _buildAppBar(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
            child: const Icon(Icons.arrow_back, size: 24, color: Color(0xFF01422D)),
          ),
          const SizedBox(width: 16),
          const Text('Sell car',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFF01422D))),
        ],
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF00274B),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15, bottom: 5, top: 5),
            child: Image.asset(
              'assets/sell_image/red_car.png',
              width: 145,
              height: 140,
              fit: BoxFit.contain,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Sell Your Car Instantly',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Calistoga',
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Best price,Free inspection.\nInstant payment',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Calistoga',
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Get Free Quote',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Calistoga',
                          color: Color(0xFF000000),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
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
    );
  }

  Widget _buildGetPriceForm() {
    final parts = _parseRegistration(_regController.text);
    final isComplete = parts.isValid;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFB5B4B4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Get Your Vehicle Best Price Now',
            style: TextStyle(
              color: Color(0xFF003399),
              fontWeight: FontWeight.w700,
              fontSize: 18.5,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Enter Your Vehicle Registration Number',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _regController,
            focusNode: _regFocusNode,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              _UpperCaseTextFormatter(),
              LengthLimitingTextInputFormatter(13),
            ],
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.directions_car_outlined,
                color: Color(0xFF005F65),
                size: 20,
              ),
              suffixIcon: isComplete
                  ? const Icon(
                      Icons.check_circle,
                      color: Color(0xFF2E7D32),
                      size: 22,
                    )
                  : _regController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.grey, size: 20),
                          onPressed: () {
                            _regController.clear();
                            setState(() => _regError = null);
                          },
                        )
                      : null,
              hintText: 'e.g. TN 42 A 4872',
              hintStyle: const TextStyle(
                color: Color(0xFF999999),
                fontWeight: FontWeight.w500,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: _regError != null ? Colors.red : Colors.black,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: _regError != null
                      ? Colors.red
                      : isComplete
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFB5B4B4),
                  width: isComplete ? 1.5 : 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: _regError != null
                      ? Colors.red
                      : const Color(0xFF005F65),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
          const SizedBox(height: 8),
          // ── Decent format guide and suggestion under textfield ───────
          _buildFormatSuggestion(parts),
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              width: 160,
              child: ElevatedButton(
                onPressed: _isSubmittingStep1 ? null : _onSellVehicle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005F65),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isSubmittingStep1
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Sell my vehicle',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatSuggestion(_RegistrationParts parts) {
    if (_regError != null) {
      return Padding(
        padding: const EdgeInsets.only(left: 2, top: 2),
        child: Row(
          children: [
            const Icon(Icons.error_outline, size: 14, color: Colors.red),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                _regError!,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final isTyping = _regController.text.trim().isNotEmpty;
    final isValid = parts.isValid;

    return Padding(
      padding: const EdgeInsets.only(left: 2, top: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isTyping) ...[
            Row(
              children: [
                Icon(
                  isValid ? Icons.check_circle : Icons.info_outline,
                  size: 14,
                  color: isValid ? const Color(0xFF2E7D32) : const Color(0xFF005F65),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    parts.hintText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isValid ? FontWeight.w600 : FontWeight.w500,
                      color: isValid ? const Color(0xFF2E7D32) : const Color(0xFF005F65),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
          Row(
            children: const [
              Icon(Icons.lightbulb_outline, size: 13, color: Color(0xFF757575)),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Format: TN 42 A 4872  (State • RTO • Series • Number)',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF757575),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBrandSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'or Select your car brand',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 6,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: GridView.count(
            crossAxisCount: 5,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 10,
            childAspectRatio: 1,
            children: _carBrands.map((brand) {
              return GestureDetector(
                onTap: () {},
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFB9B9B9)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Image.asset(
                        brand['image']!,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingCarsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          child: Text(
            'Trending Cars',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
        SizedBox(
          height: 235.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            children: _trendingCars.map((car) => _buildCarCard(car)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCarCard(Map<String, dynamic> car) {
    return Container(
      width: 250.w,
      margin: EdgeInsets.only(right: 14.w),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFEAEAEA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Image.asset(car['image'], height: 75.h, width: 140.w, fit: BoxFit.contain),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  car['name'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                car['year'] ?? '',
                style: TextStyle(fontSize: 13.sp, color: const Color(0xFF464646)),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Test Drive Available',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.sp, color: const Color(0xFF797979)),
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '₹ ',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 13.sp,
                      ),
                    ),
                    TextSpan(
                      text: car['price'] ?? '',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 13.sp,
                      ),
                    ),
                    TextSpan(
                      text: ' Lakh',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),

              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF742B88)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('View Details',
                  style: TextStyle(
                      color: Color(0xFF742B88),
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellingProcess() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            'Process of selling cars',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
          ),
        ),
        ..._sellingProcess.map((step) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 120),
                  padding: const EdgeInsets.fromLTRB(35, 8, 20, 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9E2FF),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 4,
                        spreadRadius: 0,
                        offset: Offset(0, 4),
                        color: Color(0xFFE2E2E2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step['title']!,
                        style: const TextStyle(
                          color: Color(0xFF742B88),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        step['desc']!,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF000000),
                        ),
                      ),
                    ],
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.asset(
                    step['image']!,
                    width: 144,
                    height: 94,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTestimonial() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text('Testimonials – What Our Customers Say',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text('Harish – Coimbatore',
                      style: TextStyle(
                          color: Color(0xFF000EAD),
                          fontWeight: FontWeight.w400,
                          fontSize: 13)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text('Rating: ',
                      style: TextStyle(fontSize: 13, color: Colors.black)),
                  ...List.generate(4,
                          (_) => const Icon(Icons.star, size: 14, color: Color(0xFFFBCD16))),
                  const Icon(Icons.star_outline, size: 14, color: Colors.black),
                  const Text(' (4.5/5)',
                      style: TextStyle(fontSize: 13)),
                ],
              ),
              const SizedBox(height: 4),
              const Text('"Great range of bikes and quick service!"',
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13)),
              const SizedBox(height: 2),
              const Text(
                'Found the exact model I was looking for, and they delivered it on time. Customer support was\nresponsive even after the sale.',
                style: TextStyle(
                    fontWeight: FontWeight.w400, fontSize: 13, height: 1.65),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFAQ() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Center(
            child: Text(
              'Frequently Asked Questions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        ...List.generate(_faqs.length, (i) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () =>
                      setState(() => _faqExpanded[i] = !_faqExpanded[i]),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _faqs[i]['q']!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Icon(
                          _faqExpanded[i]
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
                if (_faqExpanded[i]) ...[
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: Colors.grey.shade200,
                    indent: 14,
                    endIndent: 14,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    child: Text(
                      _faqs[i]['a']!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _RegistrationParts {
  final String state;
  final String rto;
  final String series;
  final String number;
  final int currentStep;
  final String hintText;
  final bool isValid;

  _RegistrationParts({
    required this.state,
    required this.rto,
    required this.series,
    required this.number,
    required this.currentStep,
    required this.hintText,
    required this.isValid,
  });
}

class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}