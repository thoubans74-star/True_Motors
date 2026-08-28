import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:true_motors/provider/used_vehicle_provider.dart';
import 'package:true_motors/sell_vehicle_module/sell_car_form_screen.dart';

import 'used_vehicle_screen.dart';
import 'compare_vehicle_screen.dart';

class SellVehicleScreen extends StatefulWidget {
  const SellVehicleScreen({super.key});

  @override
  State<SellVehicleScreen> createState() => _SellVehicleScreenState();
}

class _SellVehicleScreenState extends State<SellVehicleScreen> {
  final int _selectedNavIndex = 2;

  UsedVehicleCategory? _selectedCategory;
  final TextEditingController _regController = TextEditingController();
  final FocusNode _regFocusNode = FocusNode();
  String? _regError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UsedVehicleProvider>().fetchUsedVehicleCategories();
    });
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

  /// Returns the registration label based on selected vehicle type
  String get _registrationLabel {
    final catName = _selectedCategory?.catName.toLowerCase();
    switch (catName) {
      case 'bike':
        return 'Enter Your Bike Registration Number';
      case 'scooty':
        return 'Enter Your Scooty Registration Number';
      case 'commercial vehicle':
        return 'Enter Your Commercial Vehicle Registration Number';
      case 'tractor':
        return 'Enter Your Tractor Registration Number';
      default:
        return 'Enter Your Car Registration Number';
    }
  }

  /// Returns hint text based on vehicle type
  String get _registrationHint {
    final catName = _selectedCategory?.catName.toLowerCase();
    switch (catName) {
      case 'bike':
      case 'scooty':
        return 'TN 42 A 4872';
      case 'commercial vehicle':
        return 'TN 09 C 1234';
      case 'tractor':
        return 'TN 57 T 5678';
      default:
        return 'TN 42 A 4872';
    }
  }

  /// Indian vehicle registration number regex validator
  /// Supports formats: AA 00 AA 0000 or AA 00 A 0000
  bool _isValidRegistration(String value) {
    final trimmed = value.trim().replaceAll(' ', '').toUpperCase();
    // Standard Indian format: 2 letters + 2 digits + 1-3 letters + 4 digits
    final regex = RegExp(r'^[A-Z]{2}[0-9]{1,2}[A-Z]{1,3}[0-9]{1,4}$');
    return regex.hasMatch(trimmed);
  }

  void _onSellVehicle() {
    // Validate vehicle selection
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a vehicle type'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate registration number
    final reg = _regController.text.trim();
    if (reg.isEmpty) {
      setState(() => _regError = 'Please enter a registration number');
      return;
    }
    if (!_isValidRegistration(reg)) {
      setState(() => _regError = 'Enter a valid registration number (e.g. TN 42 A 4872)');
      return;
    }

    setState(() => _regError = null);

    // Navigate to the sell car form with the registration number
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SellCarFormScreen(
          registrationNumber: reg.trim().toUpperCase(),
          vehicleType: _selectedCategory!.catName,
          vehicleCategoryId: _selectedCategory!.id,
        ),
      ),
    );
  }

  void _onNavTap(int index) {
    if (index == _selectedNavIndex) return;
    if (index == 0) {
      Navigator.popUntil(context, (route) => route.isFirst);
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UsedVehicleScreen()),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CompareVehicleScreen()),
      );
    }
  }

  @override
  void dispose() {
    _regController.dispose();
    _regFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Dismiss keyboard on tap outside — keeps bottom nav fixed
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        // resizeToAvoidBottomInset: false keeps the bottom nav from moving up
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Column(
            children: [
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
    return Consumer<UsedVehicleProvider>(
      builder: (context, provider, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFB5B4B4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Get Your Vehicle Best Price Now',
                  style: TextStyle(
                      color: Color(0xFF003399),
                      fontWeight: FontWeight.w700,
                      fontSize: 18.5)),
              const SizedBox(height: 12),
              if (provider.isLoading)
                const Center(child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(color: Color(0xFF005F65)),
                ))
              else if (provider.error != null)
                Text('Error: ${provider.error}', style: const TextStyle(color: Colors.red))
              else
                _buildDropdown(
                  'Select Vehicle',
                  provider.categories,
                  _selectedCategory,
                      (val) => setState(() {
                    _selectedCategory = val;
                    _regController.clear();
                    _regError = null;
                  }),
                ),
              const SizedBox(height: 10),

              // Dynamic label based on vehicle type
              if (_selectedCategory != null) ...[
                Text(
                  _registrationLabel,
                  style: const TextStyle(
                      fontSize: 14, color: Colors.black, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _regController,
                  focusNode: _regFocusNode,
                  textCapitalization: TextCapitalization.characters,
                  onChanged: (_) {
                    if (_regError != null) setState(() => _regError = null);
                  },
                  decoration: InputDecoration(
                    hintText: _registrationHint,
                    hintStyle: const TextStyle(
                        color: Color(0xFF999999), fontWeight: FontWeight.w500),
                    errorText: _regError,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          color: _regError != null ? Colors.red : Colors.black),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          color: _regError != null ? Colors.red : Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          color: _regError != null ? Colors.red : const Color(0xFF005F65),
                          width: 2),
                    ),
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
              ] else ...[
                // Show static label before vehicle is selected
                const Text(
                  'Enter Your Vehicle Registration Number',
                  style: TextStyle(
                      fontSize: 14, color: Colors.black, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                TextField(
                  enabled: false,
                  decoration: InputDecoration(
                    hintText: 'Select a vehicle type first',
                    hintStyle: const TextStyle(
                        color: Color(0xFF999999), fontWeight: FontWeight.w500),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                ),
              ],

              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 160,
                  child: ElevatedButton(
                    onPressed: _onSellVehicle,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF005F65),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Sell my vehicle',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBrandSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Text('or Select your car brand',
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w400)),
          ),
        ),
        Container(
          height: 200,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 4,
                  spreadRadius: 0,
                  offset: const Offset(0, 4))
            ],
          ),
          child: GridView.count(
            crossAxisCount: 5,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 15,
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
        }).toList(),
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

  Widget _buildDropdown(String hint, List<UsedVehicleCategory> items, UsedVehicleCategory? value,
      ValueChanged<UsedVehicleCategory?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<UsedVehicleCategory>(
          iconEnabledColor: Colors.black,
          dropdownColor: Colors.white,
          isExpanded: true,
          hint: Text(hint,
              style: const TextStyle(
                  color: Color(0xFF000000), fontWeight: FontWeight.w500)),
          value: value,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e.catName)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      {'image': 'assets/icons/home.png', 'label': 'Home'},
      {'image': 'assets/icons/buy.png', 'label': 'Buy'},
      {'image': 'assets/icons/sell.png', 'label': 'Sell'},
      {'image': 'assets/icons/compare.png', 'label': 'Compare'},
    ];

    return Container(
      decoration: const BoxDecoration(color: Color(0xFF005F65)),
      child: SafeArea(
        child: SizedBox(
          height: 65,
          child: Row(
            children: List.generate(items.length, (i) {
              final isSelected = _selectedNavIndex == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _onNavTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 4),
                      Image.asset(
                        items[i]['image'] as String,
                        width: isSelected ? 28 : 24,
                        height: isSelected ? 28 : 24,
                        fit: BoxFit.contain,
                        color: isSelected ? Colors.white : Colors.white60,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        items[i]['label'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white : Colors.white60,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 4,
                        width: isSelected ? double.infinity : 0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}