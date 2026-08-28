// Shared data model passed across all rental screens

class RentalBookingData {
  final String carName;
  final String pickupDate;
  final String returnDate;
  final String location;

  const RentalBookingData({
    required this.carName,
    required this.pickupDate,
    required this.returnDate,
    required this.location,
  });

  RentalBookingData copyWith({
    String? carName,
    String? pickupDate,
    String? returnDate,
    String? location,
  }) {
    return RentalBookingData(
      carName: carName ?? this.carName,
      pickupDate: pickupDate ?? this.pickupDate,
      returnDate: returnDate ?? this.returnDate,
      location: location ?? this.location,
    );
  }
}