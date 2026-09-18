import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:true_motors/provider/used_vehicle_provider.dart';
import 'package:true_motors/provider/sell_vehicle_provider.dart';
import 'package:true_motors/provider/common_dropdown_provider.dart';
import 'package:true_motors/provider/rto_location_provider.dart';
import 'package:true_motors/provider/seller_insert_step_provider.dart';

import 'package:true_motors/menu_module/listing_manager.dart';
import 'sell_vehicle_condition.dart';

class SellCarFormScreen extends StatefulWidget {
  final String registrationNumber;
  final String? vehicleType;
  final int? vehicleCategoryId;
  // When set, we are editing an existing listing instead of creating new
  final String? editingListingId;
  final String? listingId;

  const SellCarFormScreen({
    super.key,
    required this.registrationNumber,
    this.vehicleType,
    this.vehicleCategoryId,
    this.editingListingId,
    this.listingId,
  });

  @override
  State<SellCarFormScreen> createState() => _SellCarFormScreenState();
}

class _SellCarFormScreenState extends State<SellCarFormScreen> {
  // ── Selected values ────────────────────────────────────────────────────────
  String? _selectedVehicleType;
  String? _selectedBrand;
  String? _selectedModel;
  String? _selectedFuelType;
  String? _selectedTransmission;
  String? _selectedCategory;
  String? _selectedLocation;
  String? _selectedRTO;
  String? _selectedVehicleLocation;
  String? _selectedOwner;
  String? _selectedColor;

  // ── Which dropdown is currently open ──────────────────────────────────────
  String? _openDropdown;
  bool _isSubmittingStep2 = false;

  bool get _isBike {
    if (_selectedVehicleType != null) {
      final vt = _selectedVehicleType!.trim().toLowerCase();
      if (vt.contains('bike') ||
          vt.contains('two-wheeler') ||
          vt.contains('scooty') ||
          vt == '2') {
        return true;
      }
    }
    if (mounted) {
      final sel = context.read<SellVehicleProvider>().selectedVehicleType;
      if (sel != null &&
          (sel.id == 2 || sel.vehName.toLowerCase().contains('bike'))) {
        return true;
      }
    }
    return false;
  }

  // ── Text controllers ───────────────────────────────────────────────────────
  final TextEditingController _mfgYearController = TextEditingController();
  final TextEditingController _kmController = TextEditingController();
  final TextEditingController _regYearController = TextEditingController();

  // ── Text field errors ──────────────────────────────────────────────────────
  String? _kmError;
  String? _mfgYearError;
  String? _regYearError;

  // ── Lists ──────────────────────────────────────────────────────────────────
  final List<String> _defaultVehicleTypes = [
    'Car',
    'Bike',
    'Scooty',
    'Commercial Vehicle',
    'Tractor',
  ];





  // ── Field limits ───────────────────────────────────────────────────────────
  static const int _maxKmDigits = 7;

  @override
  void initState() {
    super.initState();
    if (widget.vehicleType != null && widget.vehicleType!.isNotEmpty) {
      _selectedVehicleType = widget.vehicleType;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final sellProvider = context.read<SellVehicleProvider>();
      final commonProvider = context.read<CommonDropdownProvider>();
      final rtoProvider = context.read<RtoLocationProvider>();

      commonProvider.fetchFuelTypes();
      commonProvider.fetchTransmissions();
      commonProvider.fetchCategories();
      commonProvider.fetchOwners();
      commonProvider.fetchColors();
      rtoProvider.fetchLocations();

      await sellProvider.fetchVehicleTypes();
      await sellProvider.fetchBrands();
      await sellProvider.fetchStandaloneModels();

      if (!mounted) return;

      if (_selectedVehicleType != null && _selectedVehicleType!.isNotEmpty) {
        await sellProvider.selectVehicleTypeByName(_selectedVehicleType!);
        if (!mounted) return;
        if (_selectedBrand != null && _selectedBrand!.isNotEmpty) {
          await sellProvider.selectBrandByName(_selectedBrand!);
          if (!mounted) return;
          if (_selectedModel != null && _selectedModel!.isNotEmpty) {
            sellProvider.selectModelByName(_selectedModel!);
          }
        }
      } else if (_selectedBrand != null && _selectedBrand!.isNotEmpty) {
        await sellProvider.selectBrandByName(_selectedBrand!);
      }

      if (_selectedLocation != null && _selectedLocation!.isNotEmpty) {
        rtoProvider.selectLocationByName(_selectedLocation!);
      }
    });
    // Pre-fill form if editing an existing listing
    if (widget.editingListingId != null) {
      final existing = ListingManager()
          .allListings
          .where((l) => l.id == widget.editingListingId)
          .firstOrNull;
      if (existing != null) {
        _selectedVehicleType = existing.vehicleType;
        _selectedBrand = existing.brand;
        _selectedModel = existing.model;
        _selectedFuelType = existing.fuelType;
        _selectedTransmission = existing.transmission;
        _selectedCategory = existing.category;
        _selectedLocation = existing.location;
        _selectedRTO = existing.rto;
        _selectedVehicleLocation = existing.currentLocation ?? existing.location;
        _kmController.text = existing.kmDriven;
        _regYearController.text = existing.regYear;
        if (existing.mfgYear != null && existing.mfgYear!.isNotEmpty) {
          _mfgYearController.text = existing.mfgYear!;
        }
      }
    }
  }

  @override
  void dispose() {
    _mfgYearController.dispose();
    _kmController.dispose();
    _regYearController.dispose();
    super.dispose();
  }

  void _toggleDropdown(String key) {
    setState(() => _openDropdown = _openDropdown == key ? null : key);
  }

  bool _validateTextFields() {
    bool valid = true;
    setState(() {
      if (_mfgYearController.text.trim().isEmpty) {
        _mfgYearError = 'Required';
        valid = false;
      } else {
        _mfgYearError = null;
      }

      final km = _kmController.text.trim();
      if (km.isEmpty) {
        _kmError = 'Please enter kilometers driven';
        valid = false;
      } else {
        final val = int.tryParse(km);
        if (val == null || val <= 0) {
          _kmError = 'Enter a valid number greater than 0';
          valid = false;
        } else {
          _kmError = null;
        }
      }

      if (_regYearController.text.trim().isEmpty) {
        _regYearError = 'Required';
        valid = false;
      } else {
        _regYearError = null;
      }
    });
    return valid;
  }

  List<String> _missingDropdowns() {
    final missing = <String>[];
    if (_selectedVehicleType == null) missing.add('Vehicle Type');
    if (_selectedBrand == null) missing.add('Brand');
    if (_selectedModel == null) missing.add('Model');
    if (_selectedFuelType == null) missing.add('Fuel Type');
    if (_selectedTransmission == null) missing.add('Transmission');
    if (!_isBike && _selectedCategory == null) missing.add('Category');
    if (_selectedLocation == null) missing.add('Location');
    if (_selectedRTO == null) missing.add('RTO');
    if (_selectedVehicleLocation == null) missing.add('Vehicle Location');
    if (_selectedOwner == null) missing.add('Owner');
    if (_selectedColor == null) missing.add('Color');
    return missing;
  }

  void _onSaveAndNext() {
    FocusScope.of(context).unfocus();
    setState(() => _openDropdown = null);

    final missing = _missingDropdowns();
    final bool textFieldsValid = _validateTextFields();

    if (missing.isNotEmpty || !textFieldsValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please fill all fields',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: const Color(0xFF323232),
          behavior: SnackBarBehavior.fixed,
          duration: const Duration(seconds: 2),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
      );
      return;
    }

    if (widget.editingListingId != null) {
      // Editing mode — update the listing directly and pop back to My Listing
      final existing = ListingManager()
          .allListings
          .where((l) => l.id == widget.editingListingId)
          .firstOrNull;
      if (existing != null) {
        final updated = existing.copyWith(
          vehicleType: _selectedVehicleType,
          brand: _selectedBrand,
          model: _selectedModel,
          fuelType: _selectedFuelType,
          transmission: _selectedTransmission,
          category: _isBike ? null : _selectedCategory,
          mfgYear: _mfgYearController.text.trim(),
          regYear: _regYearController.text.trim(),
          kmDriven: _kmController.text.trim(),
          location: _selectedLocation,
          rto: _selectedRTO,
          currentLocation: _selectedVehicleLocation,
          price: '0',
          insuranceDate: '',
          features: [],
        );
        ListingManager().updateListing(widget.editingListingId!, updated);
      }
      // Pop back to My Listing
      Navigator.pop(context);
    } else {
      if (_isSubmittingStep2) return;
      setState(() => _isSubmittingStep2 = true);

      final stepProvider = context.read<SellerInsertStepProvider>();
      final sellVehicleProvider = context.read<SellVehicleProvider>();
      final commonDropdownProvider = context.read<CommonDropdownProvider>();
      final rtoLocationProvider = context.read<RtoLocationProvider>();

      () async {
        try {
          String? activeListingId = widget.listingId ?? stepProvider.currentListingId;

          if (activeListingId == null || activeListingId.isEmpty) {
            final s1 = await stepProvider.submitStep1(vehicleNo: widget.registrationNumber);
            activeListingId = s1?.listingId;
          }

          if (activeListingId == null || activeListingId.isEmpty) {
            throw Exception(stepProvider.step1Error ?? 'Could not initialize vehicle draft.');
          }

          final vTypeId = sellVehicleProvider.selectedVehicleType?.id ??
              sellVehicleProvider.vehicleTypes
                  .where((v) => v.vehName.toLowerCase() == (_selectedVehicleType ?? '').toLowerCase())
                  .firstOrNull
                  ?.id ??
              2;

          final vCatId = !_isBike
              ? (commonDropdownProvider.getCategoryIdByName(_selectedCategory ?? '') ?? 1)
              : null;

          final brandId = sellVehicleProvider.selectedBrand?.id ??
              sellVehicleProvider.brands
                  .where((b) => b.name.toLowerCase() == (_selectedBrand ?? '').toLowerCase())
                  .firstOrNull
                  ?.id ??
              1;

          int modelId = sellVehicleProvider.getModelIdByName(
                _selectedModel ?? '',
                brandId: brandId,
                brandName: _selectedBrand,
              ) ??
              ((sellVehicleProvider.selectedModel?.id != null &&
                      sellVehicleProvider.selectedModel!.id > 0)
                  ? sellVehicleProvider.selectedModel!.id
                  : 0);

          if (modelId == 0) {
            final m = sellVehicleProvider.models
                .where((item) =>
                    item.name.toLowerCase() ==
                        (_selectedModel ?? '').toLowerCase() &&
                    item.id > 0)
                .firstOrNull;
            if (m != null) modelId = m.id;
          }

          if (modelId == 0) {
            final sm = sellVehicleProvider.standaloneModels
                .where((item) =>
                    item.name.toLowerCase() ==
                        (_selectedModel ?? '').toLowerCase() &&
                    item.id > 0)
                .firstOrNull;
            if (sm != null) modelId = sm.id;
          }

          if (modelId == 0 && sellVehicleProvider.standaloneModels.isEmpty) {
            await sellVehicleProvider.fetchStandaloneModels();
            modelId = sellVehicleProvider.getModelIdByName(
                  _selectedModel ?? '',
                  brandId: brandId,
                  brandName: _selectedBrand,
                ) ??
                0;
          }

          if (modelId == 0) {
            modelId = 655;
          }

          debugPrint(
              '[SellCarFormScreen] Resolved model: "$_selectedModel", Brand: "$_selectedBrand" (id: $brandId) -> DB Model ID: $modelId');

          final fuelId = commonDropdownProvider.fuelTypeItems
                  .where((f) => f.name.toLowerCase() == (_selectedFuelType ?? '').toLowerCase())
                  .firstOrNull
                  ?.id ??
              1;

          final rtoId = rtoLocationProvider.selectedRto?.id ??
              rtoLocationProvider.rtos
                  .where((r) => r.name.toLowerCase() == (_selectedRTO ?? '').toLowerCase())
                  .firstOrNull
                  ?.id ??
              1;

          final regCityId = rtoLocationProvider.selectedLocation?.id ??
              rtoLocationProvider.locations
                  .where((l) => l.name.toLowerCase() == (_selectedLocation ?? '').toLowerCase())
                  .firstOrNull
                  ?.id ??
              1;

          final vehLocId = rtoLocationProvider.locations
                  .where((l) => l.name.toLowerCase() == (_selectedVehicleLocation ?? '').toLowerCase())
                  .firstOrNull
                  ?.id ??
              5;

          final transId = commonDropdownProvider.transmissionItems
                  .where((t) => t.name.toLowerCase() == (_selectedTransmission ?? '').toLowerCase())
                  .firstOrNull
                  ?.id ??
              1;

          final ownerId = commonDropdownProvider.ownerItems
                  .where((o) => o.name.toLowerCase() == (_selectedOwner ?? '').toLowerCase())
                  .firstOrNull
                  ?.id ??
              int.tryParse(_selectedOwner?.replaceAll(RegExp(r'[^0-9]'), '') ?? '1') ??
              1;

          final colId = commonDropdownProvider.colorItems
                  .where((c) => c.name.toLowerCase() == (_selectedColor ?? '').toLowerCase())
                  .firstOrNull
                  ?.id ??
              3;

          final step2Res = await stepProvider.submitStep2(
            listingId: activeListingId,
            vehicleType: vTypeId.toString(),
            vehicleCategory: vCatId != null ? vCatId.toString() : '',
            brand: brandId.toString(),
            model: modelId.toString(),
            fuelType: fuelId.toString(),
            regState: '33',
            regCity: regCityId.toString(),
            rtoLocation: rtoId.toString(),
            vehLocation: vehLocId.toString(),
            kmDriven: _kmController.text.trim(),
            transmission: transId.toString(),
            noOfOwner: ownerId.toString(),
            manifactureYear: _mfgYearController.text.trim(),
            regYear: _regYearController.text.trim(),
            colour: colId.toString(),
          );

          if (!mounted) return;
          setState(() => _isSubmittingStep2 = false);

          if (step2Res != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SellVehicleConditionScreen(
                  registrationNumber: widget.registrationNumber,
                  vehicleType: _selectedVehicleType ?? widget.vehicleType ?? 'Car',
                  brand: _selectedBrand!,
                  model: _selectedModel!,
                  fuelType: _selectedFuelType!,
                  transmission: _selectedTransmission!,
                  category: _isBike ? null : _selectedCategory,
                  mfgYear: _mfgYearController.text.trim(),
                  kmDriven: _kmController.text.trim(),
                  location: _selectedLocation!,
                  rto: _selectedRTO!,
                  currentLocation: _selectedVehicleLocation,
                  vehicleLocation: _selectedVehicleLocation,
                  regYear: _regYearController.text.trim(),
                  owner: _selectedOwner!,
                  color: _selectedColor!,
                  listingId: step2Res.listingId.isNotEmpty ? step2Res.listingId : activeListingId,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(stepProvider.step2Error ?? 'Failed to save vehicle details. Please try again.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } catch (e) {
          if (!mounted) return;
          setState(() => _isSubmittingStep2 = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }();
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final providerCategories = context.watch<UsedVehicleProvider>().categories;
    final sellVehicleProvider = context.watch<SellVehicleProvider>();
    final commonDropdownProvider = context.watch<CommonDropdownProvider>();
    final rtoLocationProvider = context.watch<RtoLocationProvider>();

    final vehicleTypeItems = sellVehicleProvider.vehicleTypeNames.isNotEmpty
        ? sellVehicleProvider.vehicleTypeNames
        : (providerCategories.isNotEmpty
            ? providerCategories.map((c) => c.catName).toList()
            : _defaultVehicleTypes);

    final brandItems = sellVehicleProvider.uniqueBrandNames;
    final modelItems = sellVehicleProvider.uniqueModelNames;
    final fuelTypeItems = commonDropdownProvider.fuelTypeNames;
    final transmissionItems = commonDropdownProvider.transmissionNames;
    final categoryItems = commonDropdownProvider.categoryNames;
    final locationItems = rtoLocationProvider.locationNames;
    final rtoItems = rtoLocationProvider.rtoNames;
    final ownerItems = commonDropdownProvider.ownerNames;
    final colorItems = commonDropdownProvider.colorNames;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          setState(() => _openDropdown = null);
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF3F3F3),
          resizeToAvoidBottomInset: true,
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
                        SizedBox(height: 14.h),

                        Text(
                          widget.editingListingId != null
                              ? 'Edit Vehicle - ${widget.registrationNumber}'
                              : 'Sell Vehicle - ${widget.registrationNumber}',
                          style: TextStyle(
                              fontSize: 15.sp, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Add Or Edit Vehicle',
                          style:
                          TextStyle(fontSize: 13.5.sp, color: Colors.black54),
                        ),
                        SizedBox(height: 16.h),

                        // ── Dropdowns ─────────────────────────────────────────
                        _buildInlineDropdown(
                          key: 'vehicle_type',
                          label: 'Select Vehicle Type',
                          value: _selectedVehicleType,
                          items: vehicleTypeItems,
                          isLoading: sellVehicleProvider.isVehicleTypesLoading,
                          emptyMessage: sellVehicleProvider.vehicleTypesError ??
                              'No vehicle types available',
                          onSelected: (v) {
                            setState(() {
                              if (_selectedVehicleType != v) {
                                _selectedBrand = null;
                                _selectedModel = null;
                              }
                              _selectedVehicleType = v;
                              if (_isBike) {
                                _selectedCategory = null;
                                if (_openDropdown == 'category') {
                                  _openDropdown = null;
                                }
                              }
                              _openDropdown = null;
                            });
                            context
                                .read<SellVehicleProvider>()
                                .selectVehicleTypeByName(v);
                          },
                        ),
                        _buildInlineDropdown(
                          key: 'brand',
                          label: 'Select Brand',
                          value: _selectedBrand,
                          items: brandItems,
                          isSearchable: true,
                          isLoading: sellVehicleProvider.isBrandsLoading,
                          emptyMessage: _selectedVehicleType == null
                              ? 'Please select vehicle type first'
                              : (sellVehicleProvider.brandsError ??
                                  'No brands found for $_selectedVehicleType'),
                          onSelected: (v) {
                            setState(() {
                              if (_selectedBrand != v) {
                                _selectedModel = null;
                              }
                              _selectedBrand = v;
                              _openDropdown = null;
                            });
                            context
                                .read<SellVehicleProvider>()
                                .selectBrandByName(v);
                          },
                        ),
                        _buildInlineDropdown(
                          key: 'model',
                          label: 'Select Model',
                          value: _selectedModel,
                          items: modelItems,
                          isSearchable: true,
                          isLoading: sellVehicleProvider.isModelsLoading,
                          emptyMessage: _selectedBrand == null
                              ? 'Please select a brand first'
                              : (sellVehicleProvider.modelsError ??
                                  'No models found for $_selectedBrand'),
                          onSelected: (v) {
                            setState(() {
                              _selectedModel = v;
                              _openDropdown = null;
                            });
                            context
                                .read<SellVehicleProvider>()
                                .selectModelByName(v);
                          },
                        ),
                        _buildInlineDropdown(
                          key: 'fuel',
                          label: 'Fuel Type',
                          value: _selectedFuelType,
                          items: fuelTypeItems,
                          isLoading: commonDropdownProvider.isFuelTypeLoading,
                          emptyMessage: commonDropdownProvider.fuelTypeError ??
                              'No fuel types available',
                          onSelected: (v) => setState(() {
                            _selectedFuelType = v;
                            _openDropdown = null;
                          }),
                        ),
                        _buildInlineDropdown(
                          key: 'transmission',
                          label: 'Transmission',
                          value: _selectedTransmission,
                          items: transmissionItems,
                          isLoading: commonDropdownProvider.isTransmissionLoading,
                          emptyMessage: commonDropdownProvider.transmissionError ??
                              'No transmission options available',
                          onSelected: (v) => setState(() {
                            _selectedTransmission = v;
                            _openDropdown = null;
                          }),
                        ),
                        if (!_isBike)
                          _buildInlineDropdown(
                            key: 'category',
                            label: 'Select Category',
                            value: _selectedCategory,
                            items: categoryItems,
                            isLoading: commonDropdownProvider.isCategoryLoading,
                            emptyMessage: commonDropdownProvider.categoryError ??
                                'No category options available',
                            onSelected: (v) => setState(() {
                              _selectedCategory = v;
                              _openDropdown = null;
                            }),
                          ),
                        _buildFloatingTextField(
                          label: 'Manufacturing Date',
                          controller: _mfgYearController,
                          error: _mfgYearError,
                          readOnly: true,
                          suffixIcon: Icon(Icons.calendar_month_outlined,
                              color: const Color(0xFF742B88), size: 20.r),
                          onTap: () async {
                            DateTime initial = DateTime.now();
                            final currentText = _mfgYearController.text.trim();
                            if (currentText.isNotEmpty) {
                              final parts = currentText.split('-');
                              if (parts.length == 3) {
                                final d = int.tryParse(parts[0]);
                                final m = int.tryParse(parts[1]);
                                final y = int.tryParse(parts[2]);
                                if (d != null && m != null && y != null) {
                                  final parsed = DateTime(y, m, d);
                                  if (parsed.isAfter(DateTime(1980)) &&
                                      !parsed.isAfter(DateTime.now())) {
                                    initial = parsed;
                                  }
                                }
                              }
                            }
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: initial,
                              firstDate: DateTime(1980),
                              lastDate: DateTime.now(),
                              initialDatePickerMode: DatePickerMode.year,
                              builder: (ctx, child) => Theme(
                                data: Theme.of(ctx).copyWith(
                                  colorScheme: const ColorScheme.light(
                                      primary: Color(0xFF005F65)),
                                ),
                                child: child!,
                              ),
                            );
                            if (picked != null) {
                              final d = picked.day.toString().padLeft(2, '0');
                              final m = picked.month.toString().padLeft(2, '0');
                              final y = picked.year.toString();
                              _mfgYearController.text = '$d-$m-$y';
                              setState(() => _mfgYearError = null);
                            }
                          },
                        ),
                        _buildFloatingTextField(
                          label: 'Kilometer Driven',
                          controller: _kmController,
                          error: _kmError,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(_maxKmDigits),
                          ],
                          onChanged: (_) => setState(() => _kmError = null),
                        ),
                        _buildInlineDropdown(
                          key: 'location',
                          label: 'Location',
                          value: _selectedLocation,
                          items: locationItems,
                          isSearchable: true,
                          isLoading: rtoLocationProvider.isLocationsLoading,
                          emptyMessage: rtoLocationProvider.locationsError ??
                              'No locations available',
                          onSelected: (v) {
                            setState(() {
                              if (_selectedLocation != v) {
                                _selectedRTO = null;
                              }
                              _selectedLocation = v;
                              _openDropdown = null;
                            });
                            context
                                .read<RtoLocationProvider>()
                                .selectLocationByName(v);
                          },
                        ),
                        _buildInlineDropdown(
                          key: 'rto',
                          label: 'Select RTO',
                          value: _selectedRTO,
                          items: rtoItems,
                          isSearchable: true,
                          isLoading: rtoLocationProvider.isRtosLoading,
                          emptyMessage: _selectedLocation == null
                              ? 'Please select a location first'
                              : (rtoLocationProvider.rtosError ??
                                  'No RTOs found for $_selectedLocation'),
                          onSelected: (v) {
                            setState(() {
                              _selectedRTO = v;
                              _openDropdown = null;
                            });
                            context
                                .read<RtoLocationProvider>()
                                .selectRtoByName(v);
                          },
                        ),
                        _buildInlineDropdown(
                          key: 'vehicle_location',
                          label: 'Vehicle Location',
                          value: _selectedVehicleLocation,
                          items: locationItems,
                          isSearchable: true,
                          isLoading: rtoLocationProvider.isLocationsLoading,
                          emptyMessage: rtoLocationProvider.locationsError ??
                              'No locations available',
                          onSelected: (v) {
                            setState(() {
                              _selectedVehicleLocation = v;
                              _openDropdown = null;
                            });
                          },
                        ),
                        _buildFloatingTextField(
                          label: 'Registration Date',
                          controller: _regYearController,
                          error: _regYearError,
                          readOnly: true,
                          suffixIcon: Icon(Icons.calendar_month_outlined,
                              color: const Color(0xFF742B88), size: 20.r),
                          onTap: () async {
                            DateTime initial = DateTime.now();
                            final currentText = _regYearController.text.trim();
                            if (currentText.isNotEmpty) {
                              final parts = currentText.split('-');
                              if (parts.length == 3) {
                                final d = int.tryParse(parts[0]);
                                final m = int.tryParse(parts[1]);
                                final y = int.tryParse(parts[2]);
                                if (d != null && m != null && y != null) {
                                  final parsed = DateTime(y, m, d);
                                  if (parsed.isAfter(DateTime(1980)) &&
                                      !parsed.isAfter(DateTime(2040))) {
                                    initial = parsed;
                                  }
                                }
                              }
                            }
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: initial,
                              firstDate: DateTime(1980),
                              lastDate: DateTime(2040),
                              initialDatePickerMode: DatePickerMode.year,
                              builder: (ctx, child) => Theme(
                                data: Theme.of(ctx).copyWith(
                                  colorScheme: const ColorScheme.light(
                                      primary: Color(0xFF005F65)),
                                ),
                                child: child!,
                              ),
                            );
                            if (picked != null) {
                              final d = picked.day.toString().padLeft(2, '0');
                              final m = picked.month.toString().padLeft(2, '0');
                              final y = picked.year.toString();
                              _regYearController.text = '$d-$m-$y';
                              setState(() => _regYearError = null);
                            }
                          },
                        ),
                        _buildInlineDropdown(
                          key: 'owner',
                          label: 'No of Owner',
                          value: _selectedOwner,
                          items: ownerItems,
                          isLoading: commonDropdownProvider.isOwnerLoading,
                          emptyMessage: commonDropdownProvider.ownerError ??
                              'No owner options available',
                          onSelected: (v) => setState(() {
                            _selectedOwner = v;
                            _openDropdown = null;
                          }),
                        ),
                        _buildInlineDropdown(
                          key: 'color',
                          label: 'Choose Color',
                          value: _selectedColor,
                          items: colorItems,
                          isLoading: commonDropdownProvider.isColorLoading,
                          emptyMessage: commonDropdownProvider.colorError ??
                              'No color options available',
                          onSelected: (v) => setState(() {
                            _selectedColor = v;
                            _openDropdown = null;
                          }),
                        ),
                        SizedBox(height: 24.h),

                        Center(
                          child: SizedBox(
                            width: 230.w,
                            height: 48.h,
                            child: ElevatedButton(
                              onPressed: _isSubmittingStep2 ? null : _onSaveAndNext,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF005F65),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r)),
                                elevation: 0,
                              ),
                              child: _isSubmittingStep2
                                  ? SizedBox(
                                      width: 22.r,
                                      height: 22.r,
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      widget.editingListingId != null
                                          ? 'Save Changes'
                                          : 'Save & Next',
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
      ),
    );
  }

  // ── App bar ────────────────────────────────────────────────────────────────
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
            widget.editingListingId != null ? 'Edit Listing' : 'Sell car',
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

  // ── Promo banner ───────────────────────────────────────────────────────────
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

  Widget _buildInlineDropdown({
    required String key,
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String> onSelected,
    bool isLoading = false,
    String? emptyMessage,
    bool isSearchable = false,
  }) {
    final isOpen = _openDropdown == key;
    final hasValue = value != null;

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

          // Header — shows placeholder when nothing selected, selected value otherwise
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

          // Items — flush below header
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
                      : _SearchableDropdownPanel(
                          key: ValueKey('panel_$key'),
                          label: label,
                          selectedValue: value,
                          items: items,
                          isSearchable: isSearchable,
                          onSelected: onSelected,
                        ),
            ),
        ],
      ),
    );
  }



  // ── Floating label text field ──────────────────────────────────────────────
  Widget _buildFloatingTextField({
    required String label,
    required TextEditingController controller,
    String? error,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    bool readOnly = false,
    Widget? suffixIcon,
    ValueChanged<String>? onChanged,
    VoidCallback? onTap,
  }) {
    final bool hasText = controller.text.isNotEmpty;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasText)
            Padding(
              padding: EdgeInsets.only(left: 8.w, bottom: 4.h),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: error != null
                      ? const Color(0xFFB00020)
                      : const Color(0xFF005F65),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            readOnly: readOnly,
            onChanged: (v) {
              onChanged?.call(v);
              setState(() {});
            },
            onTap: onTap,
            enableInteractiveSelection: !readOnly,
            style: TextStyle(
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: hasText ? '' : label,
              hintStyle: TextStyle(
                fontSize: 13.5.sp,
                color: const Color(0xFFB4B4B4),
              ),
              errorText: error,
              errorStyle: TextStyle(fontSize: 11.5.sp),
              suffixIcon: suffixIcon,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 12.h,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(
                  color: error != null
                      ? const Color(0xFFB00020)
                      : const Color(0xFFE2E2E2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide:
                const BorderSide(color: Color(0xFF005F65)),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: Color(0xFFB00020)),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide:
                const BorderSide(color: Color(0xFFB00020)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Searchable Dropdown Panel ──────────────────────────────────────────────
class _SearchableDropdownPanel extends StatefulWidget {
  final String label;
  final String? selectedValue;
  final List<String> items;
  final ValueChanged<String> onSelected;
  final bool isSearchable;

  const _SearchableDropdownPanel({
    super.key,
    required this.label,
    required this.selectedValue,
    required this.items,
    required this.onSelected,
    this.isSearchable = false,
  });

  @override
  State<_SearchableDropdownPanel> createState() =>
      _SearchableDropdownPanelState();
}

class _SearchableDropdownPanelState extends State<_SearchableDropdownPanel> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _filteredItems {
    final cleanQuery = _query.trim().toLowerCase();
    if (!widget.isSearchable || cleanQuery.isEmpty) {
      return widget.items;
    }
    return widget.items
        .where((item) => item.toLowerCase().contains(cleanQuery))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredItems;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {}, // Absorb taps inside dropdown so outer tap listener does not close it
      child: Container(
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
          children: [
            // Search Input Header (only when searchable)
            if (widget.isSearchable) ...[
              Padding(
                padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 8.h),
                child: Container(
                  height: 38.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8F9),
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(color: const Color(0xFFDCDCDC)),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Icon(
                          Icons.search,
                          size: 18.r,
                          color: const Color(0xFF005F65),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.black87,
                          ),
                          decoration: InputDecoration(
                            hintText:
                                'Search ${widget.label.replaceFirst('Select ', '')}...',
                            hintStyle: TextStyle(
                              fontSize: 12.5.sp,
                              color: const Color(0xFF9E9E9E),
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                          ),
                          onChanged: (val) {
                            setState(() {
                              _query = val;
                            });
                          },
                        ),
                      ),
                      if (_query.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() {
                              _query = '';
                            });
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.w),
                            child: Icon(
                              Icons.cancel,
                              size: 16.r,
                              color: const Color(0xFF9E9E9E),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
            ],

            // Content: Empty state or scrollable list
            if (filtered.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 26.r,
                      color: Colors.grey.shade400,
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'No results found for "$_query"',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        color: Colors.black54,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                constraints: BoxConstraints(maxHeight: 220.h),
                child: SingleChildScrollView(
                  child: Column(
                    children: List.generate(filtered.length, (index) {
                      final item = filtered[index];
                      final isSelected = item == widget.selectedValue;

                      return GestureDetector(
                        onTap: () => widget.onSelected(item),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 10.h,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFE8F3F1)
                                : (index % 2 == 0
                                    ? const Color(0xFFF9F9F9)
                                    : Colors.white),
                            border: Border(
                              bottom: BorderSide(
                                color: const Color(0xFFEEEEEE),
                                width: index == filtered.length - 1 ? 0 : 0.8,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item,
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
      ),
    );
  }
}