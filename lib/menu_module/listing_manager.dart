import 'dart:io';
import 'package:flutter/material.dart';

/// Represents a single vehicle listing entry.
class VehicleListing {
  final String id;
  String brand;
  String model;
  String fuelType;
  String transmission;
  String regYear;
  String kmDriven;
  String location;
  String rto;
  String price;
  String insuranceDate;
  List<String> features;
  List<File> images;
  bool allowTestDrive;
  String additionalInfo;
  String registrationNumber;
  String vehicleType;
  String status; // 'active', 'pending', 'sold'

  VehicleListing({
    required this.id,
    required this.brand,
    required this.model,
    required this.fuelType,
    required this.transmission,
    required this.regYear,
    required this.kmDriven,
    required this.location,
    required this.rto,
    required this.price,
    required this.insuranceDate,
    required this.features,
    required this.images,
    required this.allowTestDrive,
    required this.additionalInfo,
    required this.registrationNumber,
    required this.vehicleType,
    this.status = 'pending',
  });

  VehicleListing copyWith({
    String? brand,
    String? model,
    String? fuelType,
    String? transmission,
    String? regYear,
    String? kmDriven,
    String? location,
    String? rto,
    String? price,
    String? insuranceDate,
    List<String>? features,
    List<File>? images,
    bool? allowTestDrive,
    String? additionalInfo,
    String? registrationNumber,
    String? vehicleType,
    String? status,
  }) {
    return VehicleListing(
      id: this.id,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      fuelType: fuelType ?? this.fuelType,
      transmission: transmission ?? this.transmission,
      regYear: regYear ?? this.regYear,
      kmDriven: kmDriven ?? this.kmDriven,
      location: location ?? this.location,
      rto: rto ?? this.rto,
      price: price ?? this.price,
      insuranceDate: insuranceDate ?? this.insuranceDate,
      features: features ?? this.features,
      images: images ?? this.images,
      allowTestDrive: allowTestDrive ?? this.allowTestDrive,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      status: status ?? this.status,
    );
  }
}

/// Singleton that holds all listings and notifies listeners on change.
class ListingManager extends ChangeNotifier {
  static final ListingManager _instance = ListingManager._internal();
  factory ListingManager() => _instance;
  ListingManager._internal();

  final List<VehicleListing> _listings = [
    // Pre-populated active listings to match Figma design
    VehicleListing(
      id: 'TM-S1234-1',
      brand: 'Maruthi Suzuki',
      model: 'Swift',
      fuelType: 'Petrol',
      transmission: 'Manual',
      regYear: '2020',
      kmDriven: '45000',
      location: 'Coimbatore',
      rto: 'TN 57',
      price: '550000',
      insuranceDate: '12/6/2026',
      features: ['Air Conditioning', 'Power Steering'],
      images: [],
      allowTestDrive: false,
      additionalInfo: '',
      registrationNumber: 'TN57AB1234',
      vehicleType: 'Car',
      status: 'active',
    ),
    VehicleListing(
      id: 'TM-S1234-2',
      brand: 'Maruthi Suzuki',
      model: 'Swift',
      fuelType: 'Petrol',
      transmission: 'Manual',
      regYear: '2021',
      kmDriven: '30000',
      location: 'Chennai',
      rto: 'TN 01',
      price: '550000',
      insuranceDate: '12/6/2026',
      features: ['Air Conditioning', 'Airbags'],
      images: [],
      allowTestDrive: true,
      additionalInfo: '',
      registrationNumber: 'TN01CD5678',
      vehicleType: 'Car',
      status: 'active',
    ),
    VehicleListing(
      id: 'TM-S1234-3',
      brand: 'Maruthi Suzuki',
      model: 'Swift',
      fuelType: 'Petrol',
      transmission: 'Manual',
      regYear: '2019',
      kmDriven: '60000',
      location: 'Bangalore',
      rto: 'TN 33',
      price: '550000',
      insuranceDate: '12/6/2026',
      features: ['Power Steering', 'Bluetooth'],
      images: [],
      allowTestDrive: false,
      additionalInfo: '',
      registrationNumber: 'TN33EF9012',
      vehicleType: 'Car',
      status: 'active',
    ),
  ];

  List<VehicleListing> get allListings => List.unmodifiable(_listings);

  List<VehicleListing> get activeListings =>
      _listings.where((l) => l.status == 'active').toList();

  List<VehicleListing> get pendingListings =>
      _listings.where((l) => l.status == 'pending').toList();

  List<VehicleListing> get soldListings =>
      _listings.where((l) => l.status == 'sold').toList();

  void addListing(VehicleListing listing) {
    _listings.add(listing);
    notifyListeners();
  }

  void updateListing(String id, VehicleListing updated) {
    final index = _listings.indexWhere((l) => l.id == id);
    if (index != -1) {
      _listings[index] = updated;
      notifyListeners();
    }
  }

  void markAsSold(String id) {
    final index = _listings.indexWhere((l) => l.id == id);
    if (index != -1) {
      _listings[index].status = 'sold';
      notifyListeners();
    }
  }

  String generateId() {
    return 'TM-${DateTime.now().millisecondsSinceEpoch}';
  }
}