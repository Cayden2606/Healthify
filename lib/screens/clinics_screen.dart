import 'dart:convert';
import 'package:healthify/utilities/api_calls.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      bottomNavigationBar: CustomBottomNavigationBar(selectedIndex: 1),
      body: SafeArea(
        child: Column(
          children: [
            Text("this is an empty page pls read the comments in the code"),
            //TODO Dropdown widget for user to select region
            FutureBuilder<List<dynamic>>(
              future: ApiCalls().fetchClinics(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No clinics found.'));
                } else {
                  List<Clinic> clinics = snapshot.data as List<Clinic>;
                  return Expanded(
                    child: ListView.builder(
                      itemCount: clinics.length,
                      itemBuilder: (context, index) {
                        Clinic clinic = clinics[index];
                        return ListTile(
                          title: Text(clinic.name),
                          subtitle: Text(clinic.address),
                          onTap: () {
                            setState(() {
                              _selectedClinic = clinic;
                            });
                            //TODO Implement onTap for clinic > shows AddApptScreen() in bottom sheet
                          },
                        );
                      },
                    ),
                  );
                }
              },
            ),
            //TODO Adds appointment to firebase with userid, userName, point_id, clinicName, date and time
          ],
        ),
      ),
    );
  }
}
