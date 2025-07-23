import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:healthify/models/clinic.dart';

class ApiCalls {
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
  };

  Future<List<dynamic>> fetchClinics() async {
    final String apiKey = dotenv.env['GEOAPIFY_API_KEY']!;
    final String baseURL = 'https://api.geoapify.com/v2/places';

    // Map<String, String> requestHeaders = {};

    Map<String, String> queryParams = {
      "categories": "healthcare.clinic_or_praxis",
      "filter": "place:5164e2bd2f5cfb594059cd6bad0dfe09f63ff00101f901a1773a0000000000c002099203094e6f72746865617374",
      "limit": "20",
      'apiKey': apiKey,
    };

    String queryString = Uri(queryParameters: queryParams).query;
    final response = await http.get(
      Uri.parse('${baseURL}?${queryString}'),
    );

    if (response.statusCode == 200) {
      // get json list
      List<dynamic> jsonList = jsonDecode(response.body)["features"] as List<dynamic>;

      // convert to list of movies
      List<Clinic> clinicsList = jsonList.map(
        (json) => Clinic.fromJson(json)
      ).toList();
      
      return clinicsList;
    } else {
      throw Exception('Failed to load');
    }
  }

  //TODO Any other APIs
}
