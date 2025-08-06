import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:healthify/models/clinic.dart';

class GeoApifyApiCalls {
  Map<String, String> cityId = {
    'Central':
        '512279f76b54f65940595243c6454336f53ff00101f901a0773a0000000000c0020992030743656e7472616c',
    'Northwest':
        '51c811554f15f259405958cd1e6dbb4af63ff00101f901a2773a0000000000c002099203094e6f72746877657374',
    'Southwest':
        '51dadaf403e4ec59405912d83c62ddb3f43ff00101f901a4773a0000000000c00209920309536f75746877657374',
    'Northeast':
        '5164e2bd2f5cfb594059cd6bad0dfe09f63ff00101f901a1773a0000000000c002099203094e6f72746865617374',
    'Southeast':
        '515c3679cb78005a4059e207c2b16152f53ff00101f901a3773a0000000000c00209920309536f75746865617374',
    'Singapore':
        '5148c6c5ac72f459405944c362d4b5b6f53ff00101f901cc30080000000000c0020b92030953696e6761706f7265'
  };

  Future<List<Clinic>> fetchClinics(String region) async {
    Map<String, String> _regions = {
      'Central':
          "place:519c88615f55f65940596b30687cba35f53ff00101f901a0773a0000000000c00206",
      'Northwest':
          "place:51f0969c9714f259405947f8286dbb4af63ff00101f901a2773a0000000000c00206",
      'Southwest':
          "place:51be2bc776e4ec59405936464662ddb3f43ff00101f901a4773a0000000000c00206",
      'Northeast':
          "place:51648d49af5bfb5940590c1f11532209f63ff00101f901a1773a0000000000c00206",
      'Southeast':
          "place:519ef1776492005a40592d4d00b49c5af53ff00101f901a3773a0000000000c00206",
      'Singapore':
          'place:5148c6c5ac72f459405944c362d4b5b6f53ff00101f901cc30080000000000c0020b92030953696e6761706f7265'
    };

    if (!_regions.containsKey(region)) {
      throw Exception('Invalid region: $region');
    }

    final String apiKey = dotenv.env['GEOAPIFY_API_KEY']!;
    final String baseURL = 'https://api.geoapify.com/v2/places';

    Map<String, String> queryParams = {
      "categories": "healthcare.clinic_or_praxis",
      "conditions": "named",
      "filter": _regions[region]!,
      "limit": "100",
      'apiKey': apiKey,
    };

    String queryString = Uri(queryParameters: queryParams).query;
    final response = await http.get(
      Uri.parse('$baseURL?$queryString'),
    );

    if (response.statusCode == 200) {
      // get json list
      List<dynamic> jsonList =
          jsonDecode(response.body)["features"] as List<dynamic>;

      // convert to list of clinics
      List<Clinic> clinicsList =
          jsonList.map((json) => Clinic.fromJson(json)).toList();

      return clinicsList;
    } else {
      throw Exception('Failed to load');
    }
  }

  // Geoapify Search by Radius
  Future<List<Clinic>> fetchClinicsByRadius({
    required double lat,
    required double lon,
    int radiusInMeters = 5000, // default to 5km
  }) async {
    final String apiKey = dotenv.env['GEOAPIFY_API_KEY']!;
    final String baseURL = 'https://api.geoapify.com/v2/places';

    Map<String, String> queryParams = {
      "categories": "healthcare.clinic_or_praxis",
      "conditions": "named",
      "filter": "circle:$lon,$lat,$radiusInMeters",
      "bias": "proximity:$lon,$lat",
      "limit": "100",
      'apiKey': apiKey,
    };

    String queryString = Uri(queryParameters: queryParams).query;
    final response = await http.get(Uri.parse('$baseURL?$queryString'));

    if (response.statusCode == 200) {
      List<dynamic> jsonList =
          jsonDecode(response.body)["features"] as List<dynamic>;
      return jsonList.map((json) => Clinic.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load clinics by radius');
    }
  }

  //TODO Any other APIs
}
