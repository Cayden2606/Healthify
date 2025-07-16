import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:healthify/custom_widgets/bottom_navigation_bar.dart';
import 'package:healthify/models/clinic.dart';

class ClinicsScreen extends StatefulWidget {
  const ClinicsScreen({Key? key}) : super(key: key);

  @override
  State<ClinicsScreen> createState() => _ClinicsScreenState();
}

class _ClinicsScreenState extends State<ClinicsScreen> {
  List<String> _regions = [
    'Central',
    'Northwest',
    'Southwest',
    'Northeast',
    'Southeast',
  ];
  String _selectedRegion = 'Central';

  late Clinic _selectedClinic;

  Future<List<dynamic>> fetchClinics() async {
    String baseURL = 'https://api.geoapify.com/v2/places';

    Map<String, String> requestHeaders = {
      'apiKey': await dotenv.env['GEOAPIFY_API_KEY']!
    };

    Map<String, String> queryParams = {
      "categories": "healthcare.clinic_or_praxis",
      "filter": "place:5164e2bd2f5cfb594059cd6bad0dfe09f63ff00101f901a1773a0000000000c002099203094e6f72746865617374",
      "limit": "20"
    };

    String queryString = Uri(queryParameters: queryParams).query;
    final response = await http.get(
      Uri.parse(baseURL + '?' + queryString),
      headers: requestHeaders,
    );

    if (response.statusCode == 200) {
      // get json list
      List<dynamic> jsonList = jsonDecode(response.body)["results"] as List<dynamic>;

      print(response.body);

      // convert to list of movies
      // List<Movie> moviesList = jsonList.map(
      //   (json) => Movie.fromJson(json)
      // ).toList();
      
      return jsonList;
    } else {
      throw Exception('Failed to load');
    }
  }

  @override
  Widget build(BuildContext context) {
    fetchClinics();
    
    return Scaffold(
      bottomNavigationBar: CustomBottomNavigationBar(selectedIndex: 1),
      body: SafeArea(
        child: Column(
          children: [
            Text("this is an empty page pls read the comments in the code")
            //TODO Dropdown widget for user to select region
            //TODO FutureBuilder to get clinics in selected region
            
            //TODO Implement onTap for clinic > shows AddApptScreen() in bottom sheet
            //TODO Adds appointment to firebase with userid, userName, point_id, clinicName, date and time
          ],
        ),
      ),
    );
  }
}
