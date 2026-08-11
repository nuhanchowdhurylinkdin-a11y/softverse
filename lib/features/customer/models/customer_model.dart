class CustomerModel {
  final String id;
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
    this.id = '',
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

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      region: json['region']?.toString() ?? '',
      postalCode: json['postalCode']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      customerCode: json['customerCode']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      note: json['note']?.toString() ?? '',
      creditLimit: _doubleFrom(json['creditLimit']),
      points: _doubleFrom(json['points']),
      visitCount: int.tryParse(json['visitCount']?.toString() ?? '') ?? 0,
      lastVisitDate: json['lastVisitDate']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      if (email.trim().isNotEmpty) 'email': email.trim(),
      if (phone.trim().isNotEmpty) 'phone': phone.trim(),
      if (address.trim().isNotEmpty) 'address': address.trim(),
      if (city.trim().isNotEmpty) 'city': city.trim(),
      if (region.trim().isNotEmpty) 'region': region.trim(),
      if (postalCode.trim().isNotEmpty) 'postalCode': postalCode.trim(),
      if (country.trim().isNotEmpty) 'country': country.trim(),
      if (customerCode.trim().isNotEmpty) 'customerCode': customerCode.trim(),
      if (imageUrl.trim().isNotEmpty) 'imageUrl': imageUrl.trim(),
      if (note.trim().isNotEmpty) 'note': note.trim(),
      'creditLimit': creditLimit,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'region': region,
      'postalCode': postalCode,
      'country': country,
      'customerCode': customerCode,
      'imageUrl': imageUrl,
      'note': note,
      'creditLimit': creditLimit,
    };
  }

  CustomerModel copyWith({
    String? id,
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
      id: id ?? this.id,
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

  static double _doubleFrom(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
