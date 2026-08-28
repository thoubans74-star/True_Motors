import 'package:flutter/material.dart';

class ListedVehicle {
  final String vehicleType;
  final String brand;
  final String model;
  final String fuelType;
  final String transmission;
  final String year;
  final String kmDriven;
  final List<String> imagePaths;
  final String state;
  final String city;
  final String area;
  final String leaseType;
  final String leaseDuration;
  final String availableFrom;
  final String monthlyPrice;
  final String securityDeposit;
  final String includedKm;
  final String extraKmCharge;
  final List<String> selectedFeatures;
  final String additionalInfo;

  ListedVehicle({
    required this.vehicleType,
    required this.brand,
    required this.model,
    required this.fuelType,
    required this.transmission,
    required this.year,
    required this.kmDriven,
    required this.imagePaths,
    required this.state,
    required this.city,
    required this.area,
    required this.leaseType,
    required this.leaseDuration,
    required this.availableFrom,
    required this.monthlyPrice,
    required this.securityDeposit,
    required this.includedKm,
    required this.extraKmCharge,
    required this.selectedFeatures,
    required this.additionalInfo,
  });
}

class ListedVehiclesManager extends ChangeNotifier {
  static final ListedVehiclesManager _instance =
  ListedVehiclesManager._internal();
  factory ListedVehiclesManager() => _instance;
  ListedVehiclesManager._internal();

  final List<ListedVehicle> _vehicles = [];

  List<ListedVehicle> get vehicles => List.unmodifiable(_vehicles);

  void addVehicle(ListedVehicle vehicle) {
    _vehicles.add(vehicle);
    notifyListeners();
  }
}