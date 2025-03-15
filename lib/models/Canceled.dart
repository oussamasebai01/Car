class Canceled {
  final int id;
  final int carId;
  final int nationalId;
  final String firstName;
  final String middleName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String whatsappNumber;
  final int cityId;
  final int countryId;
  final String street;
  final String buildingNumber;
  final String nearestLocation;
  final String driverLicense;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String paymentMethod;
  final double totalPrice;
  final DateTime rentDate;
  final DateTime returnDate;
  final String description;

  Canceled({
    required this.id,
    required this.carId,
    required this.nationalId,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.whatsappNumber,
    required this.cityId,
    required this.countryId,
    required this.street,
    required this.buildingNumber,
    required this.nearestLocation,
    required this.driverLicense,
    required this.createdAt,
    required this.updatedAt,
    required this.paymentMethod,
    required this.totalPrice,
    required this.rentDate,
    required this.returnDate,
    required this.description,
  });

  factory Canceled.fromJson(Map<String, dynamic> json) {
    return Canceled(
      id: json['id'],
      carId: json['car_id'],
      nationalId: json['national_id'],
      firstName: json['first_name'],
      middleName: json['middle_name'],
      lastName: json['last_name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      whatsappNumber: json['whatsapp_number'],
      cityId: json['city_id'],
      countryId: json['country_id'],
      street: json['street'],
      buildingNumber: json['building_number'],
      nearestLocation: json['nearest_location'],
      driverLicense: json['driver_license'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      paymentMethod: json['payment_method'],
      totalPrice: double.parse(json['total_price']),
      rentDate: DateTime.parse(json['rent_date']),
      returnDate: DateTime.parse(json['return_date']),
      description: json['description'],
    );
  }
}