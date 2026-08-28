import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:provider/provider.dart';
import 'package:true_motors/provider/used_vehicle_provider.dart';
import 'package:true_motors/service_vehicle_module/conform_booking_screen.dart';

enum DropdownType { vehicle, service }

class VehicleServiceScreen extends StatefulWidget {
  const VehicleServiceScreen({super.key});

  @override
  State<VehicleServiceScreen> createState() => _VehicleServiceScreenState();
}

class _VehicleServiceScreenState extends State<VehicleServiceScreen> {

  String selectedVehicle = "Select Vehicle";
  int? selectedVehicleId;
  String selectedService = "Service Type";

  bool vehicleDropOpen = false;
  bool serviceDropOpen = false;

  final TextEditingController pickupController = TextEditingController();
  final TextEditingController specialController = TextEditingController();

  int currentVehicleIndex = 0;
  Timer? vehicleTimer;

  final List<String> vehicleSlides = [
    'assets/vehicle_service/Bike.png',
    'assets/vehicle_service/Car.png',
    'assets/vehicle_service/Commercial Vehicle.png',
    'assets/vehicle_service/Tractor.png',
  ];

  final List<String> vehicleOptions = [
    'Car',
    'Bike',
    'Commercial Vehicle',
    'Tractor or Agricultural Vehicle',
  ];

  final List<String> serviceOptions = [
    'General Service',
    'Oil Change',
    'Filter Replacement (Air/Oil/Fuel)',
    'Brake Inspection & Replacement',
    'Coolant Top-Up',
    'Battery Check & Replacement',
    'Spark Plug Replacement',
  ];

  final List<String> faqList = [
    'How long does it take to service vehicle?',
    'How long does it take to service vehicle?',
    'How long does it take to service vehicle?',
    'How long does it take to service vehicle?',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UsedVehicleProvider>().fetchUsedVehicleCategories();
    });
    startVehicleTimer();
  }

  void startVehicleTimer() {
    vehicleTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      setState(() {
        currentVehicleIndex = (currentVehicleIndex + 1) % vehicleSlides.length;
      });
    });
  }

  @override
  void dispose() {
    vehicleTimer?.cancel();
    pickupController.dispose();
    specialController.dispose();
    super.dispose();
  }

  void closeAllDropdowns() {
    setState(() {
      vehicleDropOpen = false;
      serviceDropOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final hp = width * 0.055;
    final scale = width / 360.0;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F2F2),
        body: GestureDetector(
          onTap: closeAllDropdowns,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: statusBarHeight, color: Colors.transparent,
              ),

              Container(
                width: double.infinity,
                height: 52.h,
                color: const Color(0xFFF2F2F2),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.arrow_back,
                        size: 24.r,
                        color: const Color(0xFF01422D),
                      ),
                    ),
                    SizedBox(width: 15.w),
                    Text('Service Vehicle',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18.sp,
                        color: const Color(0xFF01422D),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      SizedBox(
                        width: double.infinity,
                        height: 173 * scale,
                        child: Image.asset(
                          'assets/vehicle_service/service.png',
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFFF2F2F2),
                            child: const Center(
                              child: Icon(Icons.build,
                                  color: Color(0xFF1B6B5A), size: 48),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: height * 0.025),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: hp),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Book a Service',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: Color(0xFF000000),
                              ),
                            ),
                            SizedBox(height: height * 0.01),

                            const Text(
                              '"Ensure your vehicle stays in top condition. Book your service with TrueMotors\' trusted partners today."',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                color: Color(0xFF000000),
                              ),
                            ),
                            SizedBox(height: height * 0.02),

                            Consumer<UsedVehicleProvider>(
                              builder: (context, provider, child) {
                                return buildDropdown(
                                  type: DropdownType.vehicle,
                                  isOpen: vehicleDropOpen,
                                  useDropTwo: true,
                                  onTap: () {
                                    setState(() {
                                      vehicleDropOpen = !vehicleDropOpen;
                                      serviceDropOpen = false;
                                    });
                                  },
                                  options: provider.categories.map((c) => c.catName).toList(),
                                  onOptionSelected: (String option) {
                                    setState(() {
                                      selectedVehicle = option;
                                      vehicleDropOpen = false;
                                      try {
                                        selectedVehicleId = provider.categories.firstWhere((c) => c.catName == option).id;
                                      } catch (e) {
                                        selectedVehicleId = null;
                                      }
                                    });
                                  },
                                );
                              }
                            ),
                            const SizedBox(height: 8),

                            buildDropdown(
                              type: DropdownType.service,
                              isOpen: serviceDropOpen,
                              useDropTwo: false,
                              onTap: () {
                                setState(() {
                                  serviceDropOpen = !serviceDropOpen;
                                  vehicleDropOpen = false;
                                });
                              },
                              options: serviceOptions,
                            ),
                            const SizedBox(height: 8),
                            buildStaticBox('Select Preferred Date & Time'),
                            const SizedBox(height: 8),

                            buildStaticBox('Select Location'),
                            const SizedBox(height: 14),

                            const Text(
                              'Pickup Address',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: Color(0xFF000000),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2F2F2),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                    color: const Color(0xFFB6B3B3)),
                              ),
                              child: TextField(
                                controller: pickupController,
                                minLines: 2,
                                maxLines: 3,
                                style: const TextStyle(
                                    fontFamily: 'Poppins', fontSize: 12),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            const Text(
                              'Special Instruction',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: Color(0xFF000000),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2F2F2),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                    color: const Color(0xFFB6B3B3)),
                              ),
                              child: TextField(
                                controller: specialController,
                                minLines: 3,
                                maxLines: 4,
                                style: const TextStyle(
                                    fontFamily: 'Poppins', fontSize: 12),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(10),
                                ),
                              ),
                            ),

                            SizedBox(height: height * 0.015),
                            Center(
                              child: SizedBox(
                                width: 200 * scale,
                                height: 45,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (_, anim, __) =>
                                            ConformBookingScreen(
                                              vehicleName: selectedVehicle,
                                              vehicleId: selectedVehicleId,
                                              servicesSelected: selectedService,
                                              pickupAddress: pickupController.text,
                                              specialInstructions: specialController.text,
                                            ),
                                        transitionsBuilder:
                                            (_, anim, __, child) =>
                                                FadeTransition(
                                                    opacity: anim,
                                                    child: child),
                                        transitionDuration: const Duration(
                                            milliseconds: 300),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(0xFF005F65),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Book Service Now',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: height * 0.02),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: hp),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            'assets/vehicle_service/Skoda.png',
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 150,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1B1B2F),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: height * 0.015),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: hp),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Center(
                                child: Text(
                                  'Why Choose Us',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Color(0xFF000000),
                                  ),
                                ),
                              ),

                              SizedBox(height: height * 0.01),
                              const Text(
                                'Our certified and trained technicians ensure that your vehicle gets the care it deserves. From routine servicing to complex repairs, your car is in safe hands.',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: Color(0xFF000000),
                                ),
                              ),

                              SizedBox(height: height * 0.01),
                              buildWhyItem('Expert Technicians:',
                                  'Certified professionals for every service.'),
                              buildWhyItem('Genuine Parts:',
                                  'Guaranteed quality and reliability.'),
                              buildWhyItem('Transparent Pricing:',
                                  'No hidden charges, upfront estimates.'),
                              buildWhyItem('Convenience:',
                                  'Home pickup & drop for hassle-free servicing.'),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: height * 0.015),
                      Padding(
                        padding: EdgeInsets.only(left: hp, bottom: 8),
                        child: const Text(
                          'Popular Service Vehicles:',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Color(0xFF000000),
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: hp),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 600),
                          transitionBuilder: (child, anim) =>
                              FadeTransition(opacity: anim, child: child),
                          child: ClipRRect(
                            key: ValueKey(currentVehicleIndex),
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              vehicleSlides[currentVehicleIndex],
                              width: double.infinity,
                              height: 150 * scale,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 150 * scale,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFBEBE),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: height * 0.015),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: hp),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  'Frequently Asked Questions',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: Color(0xFF000000),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              ...List.generate(faqList.length, (index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 4),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${index + 1}. ${faqList[index]}',
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w400,
                                            fontSize: 12,
                                            color: Color(0xFF000000),
                                            decoration: TextDecoration.none,
                                          ),
                                        ),
                                      ),
                                      const Icon(Icons.keyboard_arrow_down,
                                        color: Color(0xFF3C3C3C),
                                      )
                                    ],
                                  ),
                                );
                              }),
                              SizedBox(height: height * 0.02),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.04),
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

  Widget buildStaticBox(String label) {
    return Container(
      width: double.infinity,
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFE2E2E2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: Color(0xFF000000),
            ),
          ),
          Icon(Icons.arrow_drop_down,
            color: Color(0xFF742B88),
          )
        ],
      ),
    );
  }

  Widget buildDropdown({
    required DropdownType type,
    required bool isOpen,
    required VoidCallback onTap,
    required List<String> options,
    required bool useDropTwo,
    Function(String)? onOptionSelected,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFE2E2E2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    type == DropdownType.vehicle
                        ? selectedVehicle
                        : selectedService,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Color(0xFF000000),
                    ),
                  )
                ),

                Icon(
                  isOpen
                      ? Icons.arrow_drop_up
                      : Icons.arrow_drop_down,
                  color: const Color(0xFF742B88),
                ),
              ],
            ),
          ),
        ),

        if (isOpen)
          Column(
            children: options.map((option) {
              return GestureDetector(
                onTap: () {
                  if (onOptionSelected != null) {
                    onOptionSelected(option);
                  } else {
                    setState(() {
                      if (type == DropdownType.vehicle) {
                        selectedVehicle = option;
                        vehicleDropOpen = false;
                      } else {
                        selectedService = option;
                        serviceDropOpen = false;
                      }
                    });
                  }
                },
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 0),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Color(0xFFE2E2E2)
                    ),
                    borderRadius: BorderRadius.circular(4)
                  ),
                  child: Text(
                    option,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Color(0xFF000000),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget buildWhyItem(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF000000),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: Color(0xFF000000),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: Color(0xFF000000),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}