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
    ThemeData theme = Theme.of(context);
    ColorScheme colorScheme = theme.colorScheme;
    bool isDarkMode = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Clinics',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(selectedIndex: 1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? colorScheme.surface.withOpacity(0.5)
                      : colorScheme.surface,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Icon(
                        Icons.search,
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    hintText: "Search clinics, services...",
                    hintStyle: theme.textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 16),
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),

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
      ),
    );
  }
}
