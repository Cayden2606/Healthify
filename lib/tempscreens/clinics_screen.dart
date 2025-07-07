import 'package:flutter/material.dart';
import 'package:healthify/custom_widgets/bottom_navigation_bar.dart';

import '../models/clinic.dart';

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
