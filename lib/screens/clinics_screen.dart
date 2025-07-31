import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:healthify/utilities/api_calls.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'package:healthify/custom_widgets/bottom_navigation_bar.dart';
import 'package:healthify/models/clinic.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;

import 'make_appointments_screen.dart';

class ClinicsScreen extends StatefulWidget {
  const ClinicsScreen({Key? key}) : super(key: key);

  @override
  State<ClinicsScreen> createState() => _ClinicsScreenState();
}

late Future<List<Clinic>> _clinicsFuture;
late Future<List<Marker>> _markersFuture;

class _ClinicsScreenState extends State<ClinicsScreen> {
  List<Clinic> _loadedClinics = [];

  List<String> _regions = [
    'Central',
    'Northwest',
    'Southwest',
    'Northeast',
    'Southeast',
  ];

  List<String> _searchBy = [
    'Search by Distance',
    'Search by Region',
    'Saved Clinics',
    'Search by Open Status',
  ];

  String _selectedRegion = 'Central';
  String _selectedSearch = 'Search by Distance';

  // Saved Clinics
  Set<String> _savedClinicPlaceIds = {};
  // bool saveShow =
  //     false;
  // TODO: Replace this with a global index to know which the user is slecting.

  int selectedButtonIndex = 0;

  late Clinic _selectedClinic;

  // Current Location GPS
  LatLng? _currentLocation;
  bool _isLoadingLocation = false;
  final MapController _mapController = MapController();

  final GlobalKey _stackKey = GlobalKey();
  double _stackHeight = 0.0;

  // Use a ValueNotifier to hold the FAB's bottom position.
  // This allows only the AnimatedBuilder to rebuild when it changes.
  final ValueNotifier<double> _fabBottomNotifier =
      ValueNotifier<double>(16.0); // Initial position

  final DraggableScrollableController _controller =
      DraggableScrollableController();

  ScrollController? _clinicListScrollController;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _clinicsFuture = ApiCalls().fetchClinics(_selectedRegion);
    _markersFuture = _generateMarkers(_selectedRegion);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox? box =
          _stackKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null) {
        _stackHeight = box.size.height;
        // Set initial FAB position relative to initial sheet size
        _fabBottomNotifier.value = (_stackHeight * _controller.size) + 24;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _fabBottomNotifier.dispose(); // Don't forget to dispose
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever ||
            permission == LocationPermission.denied) {
          setState(() {
            _isLoadingLocation = false;
          });
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });

      // Move map to current location
      if (_currentLocation != null) {
        _mapController.move(_currentLocation!, 16);
      }
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
      });
      // Handle error - maybe show a snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get location: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showCitiesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CitiesSelectionDialog(
          regions: _regions,
          selectedRegion: _selectedRegion,
          onRegionSelected: (String region) {
            setState(() {
              _selectedRegion = region;
              _clinicsFuture = ApiCalls().fetchClinics(_selectedRegion);
              _markersFuture = _generateMarkers(_selectedRegion);
            });
          },
        );
      },
    );
  }

  Future<List<Marker>> _generateMarkers(String region) async {
    List<Clinic> clinicsList = await ApiCalls().fetchClinics(region);

    List<Marker> markers = [];

    if (_currentLocation != null) {
      markers.add(
        Marker(
          // Current Location Marker
          point: _currentLocation!,
          width: 20,
          height: 20,
          alignment: Alignment.center,
          rotate: false,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromARGB(255, 12, 85, 252),
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      );
    }

    markers.addAll(clinicsList.map((clinic) {
      return Marker(
        point: LatLng(clinic.lat, clinic.lon),
        width: 35,
        height: 35,
        alignment: Alignment.topCenter,
        rotate: true,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedClinic = clinic;

              final clickedIndex = _loadedClinics.indexWhere(
                  (c) => c.lat == clinic.lat && c.lon == clinic.lon);
              if (clickedIndex != -1) {
                final clickedClinic = _loadedClinics.removeAt(clickedIndex);
                _loadedClinics.insert(0, clickedClinic);
              }
            });
            _mapController.move(LatLng(clinic.lat, clinic.lon), 17.0);

            _controller.animateTo(
              0.30,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
            );

            // Scroll list to top
            _clinicListScrollController?.animateTo(
              0,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
            );
          },
          child: Container(
            width: 35,
            height: 35,
            child: Image.asset(
              'images/clinic_marker.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      );
    }));

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    ColorScheme colorScheme = theme.colorScheme;
    bool isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      bottomNavigationBar: CustomBottomNavigationBar(selectedIndex: 1),
      body: Stack(
        key: _stackKey, // Keep the key here to measure stack height once
        children: [
          Positioned.fill(
            child: ClinicMap(
                mapController: _mapController,
                currentLocation: _currentLocation,
                markerList: _markersFuture),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SearchBar(
                      isDarkMode: isDarkMode,
                      colorScheme: colorScheme,
                      theme: theme),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      _buildNavButton(0, Icons.location_on, 'Nearby'),
                      SizedBox(width: 8),
                      _buildNavButton(1, Icons.location_city, 'Regions'),
                      SizedBox(width: 8),
                      _buildNavButton(2, Icons.bookmark, 'Saved'),
                      SizedBox(width: 8),
                      _buildNavButton(3, Icons.store, 'Open'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // The AnimatedBuilder rebuilds ONLY the FAB when _fabBottomNotifier changes.
          AnimatedBuilder(
            animation: _fabBottomNotifier,
            builder: (context, child) {
              return Positioned(
                right: 16,
                // Use the notifier's value for the bottom position
                // Apply the same `math.min` logic if 550 is a desired maximum offset.
                bottom: math.min(
                    _fabBottomNotifier.value, 550), // Ensure max 550, or adjust
                child: FloatingActionButton(
                  shape: const CircleBorder(),
                  onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                  backgroundColor: theme.colorScheme.surface,
                  foregroundColor: theme.colorScheme.onSurface,
                  elevation: 4,
                  child: _isLoadingLocation
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.primary,
                            ),
                          ),
                        )
                      : const Icon(Icons.my_location, size: 25),
                ),
              );
            },
          ),

          // Move NotificationListener OUTSIDE the DraggableScrollableSheet's builder
          NotificationListener<DraggableScrollableNotification>(
            onNotification: (notification) {
              // Update the FAB's position based on sheet extent
              // _stackHeight should be already calculated and mostly static
              _fabBottomNotifier.value =
                  (notification.extent * _stackHeight) + 24;
              return false; // Crucially, return false to allow notifications to continue (if needed by other listeners)
              // or true if you want to consume it here. Returning true is fine if no other
              // parent needs this specific notification.
            },
            child: DraggableScrollableSheet(
              controller: _controller,
              initialChildSize: 0.35,
              minChildSize: 0.2,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                _clinicListScrollController ??= scrollController;
                return Container(
                  // Your sheet decoration and content
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .shadowColor
                            .withOpacity(0.2), // Use withOpacity
                        blurRadius: 12,
                        spreadRadius: 2,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: ListView(
                    controller: scrollController,
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 0),
                          width: 40,
                          height: 4.5,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.6),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedSearch,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          selectedButtonIndex == 1
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    _selectedRegion,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                      const SizedBox(height: 20),
                      FutureBuilder<List<Clinic>>(
                        future: _clinicsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text("Error: ${snapshot.error}"));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Center(
                                child: Text("No clinics found."));
                          }

                          final allClinics = snapshot.data!;
                          List<Clinic> clinics = allClinics;

                          _loadedClinics = allClinics;

                          if (selectedButtonIndex == 2) {
                            // Saved clinics show
                            clinics = clinics
                                .where((clinic) => _savedClinicPlaceIds
                                    .contains(clinic.placeId))
                                .toList();
                          }

                          if (clinics.isEmpty) {
                            return const Center(
                                child: Text("No saved clinics."));
                          }

                          return Column(
                            children: clinics.map((clinic) {
                              final displayData = getClinicDisplayInfo(
                                currentLat: _currentLocation?.latitude,
                                currentLon: _currentLocation?.longitude,
                                calculateDistance: _calculateDistance,
                                clinic: clinic,
                              );

                              return buildClinicCard(
                                context,
                                clinic.name,
                                displayData['distance'],
                                displayData['displaySpecialty'],
                                displayData['displayHours'],
                                clinic.lat,
                                clinic.lon,
                                clinic.placeId,
                                phone: clinic.phone,
                                website: clinic.website,
                                isOpen: displayData['isOpen'],
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> getClinicDisplayInfo({
    required double? currentLat,
    required double? currentLon,
    required double Function(double, double, double, double) calculateDistance,
    required dynamic clinic,
  }) {
    final distance = (currentLat != null && currentLon != null)
        ? "${calculateDistance(currentLat, currentLon, clinic.lat, clinic.lon).toStringAsFixed(1)} km"
        : "Unknown";

    final openingHours = OpeningHours.parse(clinic.openingHours);
    final statusText = openingHours.getStatusText();
    final todayHoursText = openingHours.getTodayHoursText();
    final isOpen = openingHours.isOpenNow();

    late String displayHours;
    final lower = todayHoursText.toLowerCase();
    if (isOpen) {
      displayHours = "$statusText • $todayHoursText";
    } else if (lower.contains("closed today") || lower.contains("closed")) {
      displayHours = "Closed today";
    } else {
      displayHours = "Closed • Opens $todayHoursText";
    }

    String displaySpecialty = clinic.speciality;
    final name = clinic.name.toLowerCase();
    if (name.contains("polyclinic")) {
      displaySpecialty = "Polyclinic";
    }
    if (displaySpecialty.isEmpty) {
      if (name.contains("family")) {
        displaySpecialty = "Family Medicine";
      } else if (name.contains("surgery")) {
        displaySpecialty = "General Surgery";
      } else if (name.contains("tcm")) {
        displaySpecialty = "Traditional Chinese Medicine";
      } else {
        displaySpecialty = "Medical Clinic";
      }
    }

    return {
      'distance': distance,
      'displayHours': displayHours,
      'displaySpecialty': displaySpecialty,
      'isOpen': isOpen,
    };
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371;
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  Widget buildClinicCard(
      BuildContext context,
      String name,
      String distance,
      String specialties,
      String openingHours,
      double lat,
      double lon,
      String placeId,
      {String? phone,
      String? website,
      bool isOpen = false}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isSaved = _savedClinicPlaceIds.contains(placeId);

    // print(openingHours);
    print(_savedClinicPlaceIds);

    return GestureDetector(
      onTap: () {
        _mapController.move(LatLng(lat, lon), 17.0);

        // Reorder list: move this clinic to the top
        setState(() {
          final clickedIndex = _loadedClinics.indexWhere(
              (c) => c.lat == lat && c.lon == lon); // match by coordinates
          if (clickedIndex != -1) {
            final clickedClinic = _loadedClinics.removeAt(clickedIndex);
            _loadedClinics.insert(0, clickedClinic);
          }
        });

        _controller.animateTo(
          0.30,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );

        _clinicListScrollController?.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        // padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: isDark ? 0.3 : 0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Clinic icon with theme colors
            // Container(
            //   width: 56,
            //   height: 56,
            //   decoration: BoxDecoration(
            //     color: colorScheme.primaryContainer,
            //     borderRadius: BorderRadius.circular(12),
            //   ),
            //   child: Icon(
            //     Icons.local_hospital,
            //     color: colorScheme.primary,
            //     size: 28,
            //   ),
            // ),
            // SizedBox(width: 16),

            // Clinic details
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 6),
                        // Distance
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            SizedBox(width: 4),
                            Text(
                              distance,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 13,
                              ),
                            ),
                            // SizedBox(height: 4),
                            // Specialty
                            Text(
                              " • ",
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              specialties,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),

                        SizedBox(height: 6),
                        // Opening hours with proper status
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 12,
                              color: isOpen
                                  ? (isDark
                                      ? Colors.green[400]
                                      : Colors.green[600])
                                  : (isDark
                                      ? Colors.red[400]
                                      : Colors.red[600]),
                            ),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                openingHours,
                                softWrap: true,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isOpen
                                      ? (isDark
                                          ? Colors.green[400]
                                          : Colors.green[600])
                                      : (isDark
                                          ? Colors.red[400]
                                          : Colors.red[600]),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        // SizedBox(height: 4),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 12),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: 16),

                            // Appointment button
                            FilledButton.tonal(
                              onPressed: () {
                                // Make appointment functionality
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          MakeAppointmentsScreen()),
                                );
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: colorScheme.primaryContainer,
                                foregroundColor: colorScheme.onPrimaryContainer,
                                minimumSize: Size(0, 36),
                                maximumSize: Size(double.infinity, 36),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                elevation: 0,
                                shadowColor: Colors.transparent,
                                // textStyle: TextStyle(
                                //   fontSize: 12,
                                //   fontWeight: FontWeight.w500,
                                // ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.calendar_month,
                                    size: 16,
                                    color: colorScheme.onPrimaryContainer,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Appointment',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Phone button (if phone exists)
                            if (phone != null && phone.isNotEmpty) ...[
                              SizedBox(width: 8),
                              FilledButton.tonal(
                                onPressed: () async {
                                  final Uri phoneUri =
                                      Uri(scheme: 'tel', path: phone);
                                  if (await canLaunchUrl(phoneUri)) {
                                    await launchUrl(phoneUri);
                                  }
                                },
                                style: FilledButton.styleFrom(
                                  backgroundColor:
                                      colorScheme.secondaryContainer,
                                  foregroundColor:
                                      colorScheme.onSecondaryContainer,
                                  minimumSize: Size(0, 36),
                                  maximumSize: Size(double.infinity, 36),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                  // textStyle: TextStyle(
                                  //   fontSize: 12,
                                  //   fontWeight: FontWeight.w500,
                                  // ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.phone,
                                      size: 16,
                                      color: colorScheme.onSecondaryContainer,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Call',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: colorScheme.onSecondaryContainer,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            // Website button (if website exists)
                            if (website != null && website.isNotEmpty) ...[
                              SizedBox(width: 8),
                              FilledButton.tonal(
                                onPressed: () async {
                                  final Uri websiteUri = Uri.parse(website);
                                  if (await canLaunchUrl(websiteUri)) {
                                    await launchUrl(websiteUri);
                                  }
                                },
                                style: FilledButton.styleFrom(
                                  backgroundColor:
                                      colorScheme.tertiaryContainer,
                                  foregroundColor:
                                      colorScheme.onTertiaryContainer,
                                  minimumSize: Size(0, 36),
                                  maximumSize: Size(double.infinity, 36),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                  // textStyle: TextStyle(
                                  //   fontSize: 12,
                                  //   fontWeight: FontWeight.w500,
                                  // ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.language_outlined,
                                      size: 16,
                                      color: colorScheme.onTertiaryContainer,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Website',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: colorScheme.onTertiaryContainer,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            // Saved button
                            SizedBox(width: 8),
                            FilledButton.tonal(
                              onPressed: () {
                                setState(() {
                                  if (isSaved) {
                                    _savedClinicPlaceIds.remove(placeId);
                                  } else {
                                    _savedClinicPlaceIds.add(placeId);
                                  }
                                });
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: colorScheme.surfaceVariant,
                                foregroundColor: colorScheme.onSurfaceVariant,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isSaved
                                        ? Icons.bookmark
                                        : Icons.bookmark_border,
                                    size: 16,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    isSaved ? 'Saved' : 'Save',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 16),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),

            // Action buttons
          ],
        ),
      ),
    );
  }

// Helper function to parse opening hours
  bool _isClinicOpenNow(String openingHours) {
    // Parse opening_hours format like "Mo-Sa 09:00-21:00; PH,Su 09:00-17:00"
    // This is a simplified version - you'd need more robust parsing
    final now = DateTime.now();
    final currentDay = now.weekday; // 1 = Monday, 7 = Sunday
    final currentTime = now.hour * 60 + now.minute; // Minutes since midnight

    // For demo purposes, return true if current time is between 8:00-20:00
    // You should implement proper parsing of the opening_hours string
    return currentTime >= 8 * 60 && currentTime <= 20 * 60;
  }

  Widget _buildNavButton(int index, IconData icon, String label) {
    final isSelected = selectedButtonIndex == index;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedButtonIndex = index;
          });

          // Show dialog when Cities button is tapped
          if (index == 1) {
            _showCitiesDialog();
          }

          // Regions selections
          _selectedSearch = _searchBy[index];
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.9)
                : colorScheme.surface.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ClinicMap extends StatelessWidget {
  const ClinicMap({
    super.key,
    required MapController mapController,
    required LatLng? currentLocation,
    required this.markerList,
  })  : _mapController = mapController,
        _currentLocation = currentLocation;

  final MapController _mapController;
  final LatLng? _currentLocation;
  final Future<List<Marker>> markerList;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter:
            _currentLocation ?? LatLng(1.3793, 103.8481), // fallback to NYP
        initialZoom: 16,
        // Enable rotation
        interactionOptions: InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.healthify',
        ),
        if (_currentLocation != null)
          FutureBuilder<List<Marker>>(
            future: markerList,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return ErrorWidget(
                  'Error loading markers: ${snapshot.error}',
                );
              }
              return MarkerLayer(
                markers: snapshot.data!,
              );
            },
          ),
        if (_currentLocation != null)
          CircleLayer(
            circles: [
              CircleMarker(
                point: _currentLocation!,
                radius: 50, // meters
                useRadiusInMeter: true,
                color: Colors.blue.withValues(alpha: 0.1),
                borderColor: Colors.blue.withValues(alpha: 0.3),
                borderStrokeWidth: 1,
              ),
            ],
          ),
      ],
    );
  }
}

class CitiesSelectionDialog extends StatefulWidget {
  final List<String> regions;
  final String selectedRegion;
  final Function(String) onRegionSelected;

  const CitiesSelectionDialog({
    Key? key,
    required this.regions,
    required this.selectedRegion,
    required this.onRegionSelected,
  }) : super(key: key);

  @override
  State<CitiesSelectionDialog> createState() => _CitiesSelectionDialogState();
}

class _CitiesSelectionDialogState extends State<CitiesSelectionDialog>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  String _tempSelectedRegion = '';

  @override
  void initState() {
    super.initState();
    _tempSelectedRegion = widget.selectedRegion;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: 320,
                  maxHeight: 490,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.15),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.location_city,
                              size: 28,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Select Region',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Choose your preferred region to find nearby clinics',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    // Region List
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: widget.regions.length,
                        itemBuilder: (context, index) {
                          final region = widget.regions[index];
                          final isSelected = region == _tempSelectedRegion;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  setState(() {
                                    _tempSelectedRegion = region;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? colorScheme.primaryContainer
                                        : colorScheme.surfaceContainerHighest
                                            .withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected
                                          ? colorScheme.primary
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? colorScheme.primary
                                              : colorScheme
                                                  .surfaceContainerHighest,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          _getRegionIcon(region),
                                          size: 20,
                                          color: isSelected
                                              ? colorScheme.onPrimary
                                              : colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              region,
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: isSelected
                                                    ? colorScheme
                                                        .onPrimaryContainer
                                                    : colorScheme.onSurface,
                                              ),
                                            ),
                                            Text(
                                              '${_getRegionDescription(region)} Singapore',
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                color: isSelected
                                                    ? colorScheme
                                                        .onPrimaryContainer
                                                        .withValues(alpha: 0.8)
                                                    : colorScheme
                                                        .onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isSelected)
                                        Icon(
                                          Icons.check_circle,
                                          color: colorScheme.primary,
                                          size: 24,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Action Buttons
                    Container(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(
                                  color: colorScheme.outline,
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed: () {
                                widget.onRegionSelected(_tempSelectedRegion);
                                Navigator.of(context).pop();
                              },
                              style: FilledButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: colorScheme.primary,
                              ),
                              child: Text(
                                'Apply',
                                style: TextStyle(
                                  color: colorScheme.onPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getRegionIcon(String region) {
    switch (region.toLowerCase()) {
      case 'central':
        return Icons.business;
      case 'northwest':
        return Icons.landscape;
      case 'southwest':
        return Icons.water;
      case 'northeast':
        return Icons.wb_sunny;
      case 'southeast':
        return Icons.factory;
      default:
        return Icons.location_on;
    }
  }

  String _getRegionDescription(String region) {
    switch (region.toLowerCase()) {
      case 'central':
        return 'Central & CBD areas of';
      case 'northwest':
        return 'Northwestern districts of';
      case 'southwest':
        return 'Southwestern areas of';
      case 'northeast':
        return 'Northeastern regions of';
      case 'southeast':
        return 'Southeastern districts of';
      default:
        return 'Areas of';
    }
  }
}

class SearchBar extends StatelessWidget {
  const SearchBar({
    super.key,
    required this.isDarkMode,
    required this.colorScheme,
    required this.theme,
  });

  final bool isDarkMode;
  final ColorScheme colorScheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode
            ? colorScheme.surface.withValues(alpha: 0.9)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SizedBox(
        height: 50,
        child: TextField(
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Icon(
                Icons.search,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            hintText: "Search clinics, services...",
            hintStyle: theme.textTheme.headlineMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w400,
            ),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          ),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class OpeningHours {
  final Map<int, List<TimeRange>> weekdayHours;
  final List<TimeRange> publicHolidayHours;
  final bool isAlwaysOpen;
  final bool isAlwaysClosed;

  OpeningHours({
    required this.weekdayHours,
    required this.publicHolidayHours,
    this.isAlwaysOpen = false,
    this.isAlwaysClosed = false,
  });

  static OpeningHours parse(String openingHoursString) {
    if (openingHoursString.isEmpty) {
      return OpeningHours(
        weekdayHours: {},
        publicHolidayHours: [],
        isAlwaysClosed: true,
      );
    }

    // Handle 24/7 or always open cases
    if (openingHoursString.toLowerCase().contains('24/7') ||
        openingHoursString.toLowerCase().contains('always open')) {
      return OpeningHours(
        weekdayHours: {},
        publicHolidayHours: [],
        isAlwaysOpen: true,
      );
    }

    Map<int, List<TimeRange>> weekdayHours = {};
    List<TimeRange> publicHolidayHours = [];

    // Split by semicolon to handle multiple rules
    List<String> rules = openingHoursString.split(';');

    for (String rule in rules) {
      rule = rule.trim();
      if (rule.isEmpty) continue;

      try {
        _parseRule(rule, weekdayHours, publicHolidayHours);
      } catch (e) {
        print('Error parsing opening hours rule: $rule - $e');
      }
    }

    return OpeningHours(
      weekdayHours: weekdayHours,
      publicHolidayHours: publicHolidayHours,
    );
  }

  static void _parseRule(String rule, Map<int, List<TimeRange>> weekdayHours,
      List<TimeRange> publicHolidayHours) {
    // Handle "off" or "closed" cases
    if (rule.toLowerCase().contains('off') ||
        rule.toLowerCase().contains('closed')) {
      return;
    }

    // Split days and time parts
    List<String> parts = rule.split(RegExp(r'\s+'));
    if (parts.length < 2) return;

    String daysPart = parts[0];
    String timePart = parts.sublist(1).join(' ');

    // Parse time ranges
    List<TimeRange> timeRanges = _parseTimeRanges(timePart);
    if (timeRanges.isEmpty) return;

    // Handle Public Holidays
    if (daysPart.contains('PH')) {
      publicHolidayHours.addAll(timeRanges);
      daysPart = daysPart.replaceAll('PH', '').replaceAll(',', '');
    }

    // Parse days
    List<int> days = _parseDays(daysPart);
    for (int day in days) {
      weekdayHours[day] = (weekdayHours[day] ?? [])..addAll(timeRanges);
    }
  }

  static List<TimeRange> _parseTimeRanges(String timePart) {
    List<TimeRange> ranges = [];

    // Handle multiple time ranges separated by comma
    List<String> timeSlots = timePart.split(',');

    for (String slot in timeSlots) {
      slot = slot.trim();
      if (slot.contains('-')) {
        List<String> times = slot.split('-');
        if (times.length == 2) {
          TimeOfDay? start = _parseTime(times[0].trim());
          TimeOfDay? end = _parseTime(times[1].trim());
          if (start != null && end != null) {
            ranges.add(TimeRange(start: start, end: end));
          }
        }
      }
    }

    return ranges;
  }

  static List<int> _parseDays(String daysPart) {
    List<int> days = [];

    // Day abbreviations mapping (Monday = 1, Sunday = 7)
    Map<String, int> dayMap = {
      'mo': 1,
      'tu': 2,
      'we': 3,
      'th': 4,
      'fr': 5,
      'sa': 6,
      'su': 7
    };

    daysPart = daysPart.toLowerCase().replaceAll(',', ' ');
    List<String> dayParts = daysPart.split(RegExp(r'\s+'));

    for (String part in dayParts) {
      part = part.trim();
      if (part.isEmpty) continue;

      if (part.contains('-')) {
        // Handle day ranges like "mo-fr"
        List<String> range = part.split('-');
        if (range.length == 2) {
          int? start = dayMap[range[0].trim()];
          int? end = dayMap[range[1].trim()];
          if (start != null && end != null) {
            for (int i = start; i <= end; i++) {
              days.add(i);
            }
          }
        }
      } else {
        // Handle individual days
        int? day = dayMap[part];
        if (day != null) {
          days.add(day);
        }
      }
    }

    return days;
  }

  static TimeOfDay? _parseTime(String timeStr) {
    timeStr = timeStr.trim();
    RegExp timeRegex = RegExp(r'^(\d{1,2}):(\d{2})$');
    Match? match = timeRegex.firstMatch(timeStr);

    if (match != null) {
      int hour = int.parse(match.group(1)!);
      int minute = int.parse(match.group(2)!);

      if (hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59) {
        return TimeOfDay(hour: hour, minute: minute);
      }
    }

    return null;
  }

  bool isOpenNow([DateTime? dateTime]) {
    dateTime ??= DateTime.now();

    if (isAlwaysOpen) return true;
    if (isAlwaysClosed) return false;

    int weekday = dateTime.weekday;
    TimeOfDay currentTime =
        TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);

    // Check if today has opening hours
    List<TimeRange>? todayHours = weekdayHours[weekday];
    if (todayHours == null || todayHours.isEmpty) return false;

    // Check if current time falls within any opening hours
    for (TimeRange range in todayHours) {
      if (_isTimeInRange(currentTime, range)) {
        return true;
      }
    }

    return false;
  }

  bool _isTimeInRange(TimeOfDay time, TimeRange range) {
    int timeMinutes = time.hour * 60 + time.minute;
    int startMinutes = range.start.hour * 60 + range.start.minute;
    int endMinutes = range.end.hour * 60 + range.end.minute;

    // Handle cases where end time is past midnight
    if (endMinutes <= startMinutes) {
      return timeMinutes >= startMinutes || timeMinutes <= endMinutes;
    }

    return timeMinutes >= startMinutes && timeMinutes <= endMinutes;
  }

  String getStatusText([DateTime? dateTime]) {
    if (isAlwaysOpen) return "Open 24/7";
    if (isAlwaysClosed) return "Closed";

    if (isOpenNow(dateTime)) {
      return "Open Now";
    } else {
      return "Closed";
    }
  }

  String getTodayHoursText([DateTime? dateTime]) {
    dateTime ??= DateTime.now();

    if (isAlwaysOpen) return "24 hours";
    if (isAlwaysClosed) return "Closed";

    int weekday = dateTime.weekday;
    List<TimeRange>? todayHours = weekdayHours[weekday];

    if (todayHours == null || todayHours.isEmpty) {
      return "Closed today";
    }

    return todayHours
        .map((range) =>
            "${_formatTime(range.start)} - ${_formatTime(range.end)}")
        .join(", ");
  }

  String _formatTime(TimeOfDay time) {
    String hour = time.hour.toString().padLeft(2, '0');
    String minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  String getFullScheduleText() {
    if (isAlwaysOpen) return "Open 24/7";
    if (isAlwaysClosed) return "Always closed";

    List<String> dayNames = [
      '',
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun'
    ];
    List<String> schedule = [];

    for (int day = 1; day <= 7; day++) {
      List<TimeRange>? dayHours = weekdayHours[day];
      if (dayHours != null && dayHours.isNotEmpty) {
        String hoursText = dayHours
            .map((range) =>
                "${_formatTime(range.start)}-${_formatTime(range.end)}")
            .join(", ");
        schedule.add("${dayNames[day]}: $hoursText");
      } else {
        schedule.add("${dayNames[day]}: Closed");
      }
    }

    if (publicHolidayHours.isNotEmpty) {
      String phHours = publicHolidayHours
          .map((range) =>
              "${_formatTime(range.start)}-${_formatTime(range.end)}")
          .join(", ");
      schedule.add("Public Holidays: $phHours");
    }

    return schedule.join("\n");
  }
}

class TimeRange {
  final TimeOfDay start;
  final TimeOfDay end;

  TimeRange({required this.start, required this.end});

  @override
  String toString() {
    return "${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')} - ${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}";
  }
}

class TimeOfDay {
  final int hour;
  final int minute;

  TimeOfDay({required this.hour, required this.minute});

  @override
  String toString() {
    return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
  }
}
