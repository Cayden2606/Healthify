class Clinic {
  final String name;
  final String address;
  final String website;
  final String phone;
  final String email;
  final String openingHours;
  final String placeId;
  final String operator;
  final String branch;
  final bool wheelchairAccessible;
  final String wheelchairCondition; // e.g. "limited"
  final String speciality;
  final double lat;
  final double lon;

  Clinic({
    required this.name,
    required this.address,
    required this.website,
    required this.phone,
    required this.email,
    required this.openingHours,
    required this.placeId,
    required this.operator,
    required this.branch,
    required this.wheelchairAccessible,
    required this.wheelchairCondition,
    required this.speciality,
    required this.lat,
    required this.lon,
  });

  factory Clinic.fromJson(Map<String, dynamic> json) {
    final properties = json['properties'];
    final geometry = json['geometry'];

    final facilities = properties['facilities'] ?? {};
    final wheelchairDetails = facilities['wheelchair_details'] ?? {};

    return Clinic(
      name: properties['name'] ?? '',
      address: properties['address_line2'] ?? '',
      website: properties['website'] ??
          properties['datasource']?['raw']?['website'] ??
          '',
      phone: (properties['contact']?['phone'] ??
              properties['datasource']?['raw']?['phone'] ??
              '')
          .toString(),
      email: properties['contact']?['email'] ?? '',
      openingHours: properties['opening_hours'] ?? '',
      placeId: properties['place_id'] ?? '',
      operator: properties['operator'] ??
          properties['datasource']?['raw']?['operator'] ??
          '',
      branch: properties['branch'] ??
          properties['datasource']?['raw']?['branch'] ??
          '',
      // wheelchairAccessible: facilities['wheelchair'] == true ||
      //     properties['datasource']?['raw']?['wheelchair'] == 'yes',
      wheelchairAccessible: facilities['wheelchair'] as bool? ?? false,
      wheelchairCondition: wheelchairDetails['condition'] ??
          properties['datasource']?['raw']?['wheelchair'] ??
          '',
      speciality:
          properties['datasource']?['raw']?['healthcare:speciality'] ?? '',
      lat: (geometry['coordinates']?[1] ?? 0).toDouble(),
      lon: (geometry['coordinates']?[0] ?? 0).toDouble(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'properties': {
        'name': name,
        'address_line2': address,
        'website': website,
        'contact': {'phone': phone, 'email': email},
        'opening_hours': openingHours,
        'place_id': placeId,
        'operator': operator,
        'branch': branch,
        'facilities': {
          'wheelchair': wheelchairAccessible,
          'wheelchair_details': {'condition': wheelchairCondition}
        },
        'datasource': {
          'raw': {'healthcare:speciality': speciality}
        }
      },
      'geometry': {
        'coordinates': [lon, lat]
      }
    };
  }
}
