class Clinic {
  final String name;
  final String address;
  final String website;
  final String phone;
  final String email;
  final String opening_hours;
  final String place_id;

  Clinic({
    required this.name,
    required this.address,
    required this.website,
    required this.phone,
    required this.email,
    required this.opening_hours,
    required this.place_id,
  });

  //TODO implement Clinic.fromJson
  factory Clinic.fromJson(Map<String, dynamic> json) {
    return Clinic(
      name: json["properties"]['name'],
      address: json["properties"]['address_line2'],
      website: json["properties"]['website'] ?? '',
      phone: (json["properties"]['contact']?['phone'] ?? '').toString(),
      email: json["properties"]['contact']?['email'] ?? '',
      opening_hours: json["properties"]['opening_hours'] ?? '',
      place_id: json["properties"]['place_id'],
    );
  }
}
