import 'dart:convert';
import 'package:http/http.dart' as http;

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

  void fetchClinics(String region) async {
    final String apiKey = 'YOUR-API-KEY';
    final String baseURL = 'https://api.geoapify.com/v2/places';

    final uri = Uri.parse(
      '$baseURL?categories=healthcare.clinic_or_praxis&filter=place:${cityId[region]}&limit=10&apiKey=$apiKey',
    );
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      //TODO return List<Clinic>
    } else {
      throw Exception('Failed to load clinics');
    }
  }

  //TODO Any other APIs
}
