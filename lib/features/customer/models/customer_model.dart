class CustomerModel {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String region;
  final String postalCode;
  final String country;
  final String customerCode;
  final String imageUrl;
  final String note;
  final double creditLimit;
  final double points;
  final int visitCount;
  final String lastVisitDate;

  const CustomerModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.region,
    required this.postalCode,
    required this.country,
    required this.customerCode,
    required this.imageUrl,
    this.note = '',
    this.creditLimit = 0,
    this.points = 0,
    this.visitCount = 0,
    this.lastVisitDate = '',
  });

  CustomerModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? region,
    String? postalCode,
    String? country,
    String? customerCode,
    String? imageUrl,
    String? note,
    double? creditLimit,
  }) {
    return CustomerModel(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      region: region ?? this.region,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      customerCode: customerCode ?? this.customerCode,
      imageUrl: imageUrl ?? this.imageUrl,
      note: note ?? this.note,
      creditLimit: creditLimit ?? this.creditLimit,
      points: points,
      visitCount: visitCount,
      lastVisitDate: lastVisitDate,
    );
  }
}
