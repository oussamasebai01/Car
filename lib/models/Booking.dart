class Booking {
  final int id;
  final int carId;
  final String nationalId;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String? whatsappNumber;
  final int cityId;
  final String street;
  final String buildingNumber;
  final String? nearestLocation;
  final String driverLicense;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? idPicture;
  final String paymentMethod;
  final double totalPrice;
  final DateTime rentDate;
  final DateTime returnDate;

  Booking({
    required this.id,
    required this.carId,
    required this.nationalId,
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    this.whatsappNumber,
    required this.cityId,
    required this.street,
    required this.buildingNumber,
    this.nearestLocation,
    required this.driverLicense,
    required this.createdAt,
    required this.updatedAt,
    this.idPicture,
    required this.paymentMethod,
    required this.totalPrice,
    required this.rentDate,
    required this.returnDate,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
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
      street: json['street'],
      buildingNumber: json['building_number'],
      nearestLocation: json['nearest_location'],
      driverLicense: json['driver_license'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      idPicture: json['id_picture'],
      paymentMethod: json['payment_method'],
      totalPrice: json['total_price'].toDouble(),
      rentDate: DateTime.parse(json['rent_date']),
      returnDate: DateTime.parse(json['return_date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'car_id': carId,
      'national_id': nationalId,
      'first_name': firstName,
      'middle_name': middleName,
      'last_name': lastName,
      'email': email,
      'phone_number': phoneNumber,
      'whatsapp_number': whatsappNumber,
      'city_id': cityId,
      'street': street,
      'building_number': buildingNumber,
      'nearest_location': nearestLocation,
      'driver_license': driverLicense,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'id_picture': idPicture,
      'payment_method': paymentMethod,
      'total_price': totalPrice,
      'rent_date': rentDate.toIso8601String(),
      'return_date': returnDate.toIso8601String(),
    };
  }
}
