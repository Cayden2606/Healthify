import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:healthify/widgets/clinics/cities_selection_dialog.dart';
import 'package:healthify/widgets/clinics/clinic_map.dart';
import 'package:healthify/widgets/clinics/search_bar.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;

import 'package:healthify/screens/make_appointments_screen.dart';
import 'package:healthify/widgets/bottom_navigation_bar.dart';
import 'package:healthify/models/clinic.dart';
import 'package:healthify/models/opening_hours.dart';

import 'package:healthify/utilities/geoapify_calls.dart';
import 'package:healthify/utilities/firebase_calls.dart';

class ClinicsScreen extends StatefulWidget {
  const ClinicsScreen({Key? key}) : super(key: key);

  @override
  State<ClinicsScreen> createState() => _ClinicsScreenState();
}

late Future<List<Clinic>> _clinicsFuture;
late Future<List<Marker>> _markersFuture;

class _ClinicsScreenState extends State<ClinicsScreen> {
  List<Clinic> _loadedClinics = [];

  final List<String> _regions = [
    'Central',
    'Northwest',
    'Southwest',
    'Northeast',
    'Southeast',
    'Singapore'
  ];

  final List<String> _searchBy = [
    'Search by Region',
    'Search by Distance',
    'Saved Clinics',
    'Search by Open Status',
  ];

  String _selectedRegion = 'Central';
  String _selectedSearch = 'Search by Distance';

  // Saved Clinics
  Set<String> _savedClinicPlaceIds = {};

  int selectedButtonIndex = 1;

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
    _loadSavedClinics();
    _getCurrentLocation();

    _clinicsFuture = _getInitialNearbyClinics();
    _markersFuture = _clinicsFuture.then((clinics) => _generateMarkers(clinics));

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

  Future<List<Clinic>> _getInitialNearbyClinics() async {
    await _getCurrentLocation(); // Wait for location to be available

    if (_currentLocation != null) {
      final clinics = await GeoApifyApiCalls().fetchClinicsByRadius(
        lat: _currentLocation!.latitude,
        lon: _currentLocation!.longitude,
        radiusInMeters: 5000,
      );

      final Set<String> processedIds = {};
      for (final clinic in clinics) {
        // Run in the background, no need to await
        if (processedIds.add(clinic.placeId)) {
          // .add() returns true if the item was added (i.e., it was not already in the set)
          FirebaseCalls().addClinicIfNotFound(clinic);
        };
      }
      return clinics;
    } else {
      // Handle the case where location is not available.
      // This error will be displayed by the FutureBuilder.
      throw Exception('Location permissions are required to search nearby.');
    }
  }

  Future<void> _loadSavedClinics() async {
    try {
      final savedClinics = await FirebaseCalls().getUserSavedClinics();
      setState(() {
        _savedClinicPlaceIds =
            savedClinics.map((clinic) => clinic.placeId).toSet();
      });
    } catch (e) {
      print('Error loading saved clinics: $e');
    }
  }

  // FUnction that takes in selectedButtonIndex, if 0 do the nearby
  void _searchByOptions(int selectedButtonIndex) {
    // Nearby 5km radius
    if (selectedButtonIndex == 1) {
      setState(() {
        _clinicsFuture = GeoApifyApiCalls()
            .fetchClinicsByRadius(
                lat: _currentLocation!.latitude,
                lon: _currentLocation!.longitude,
                radiusInMeters: 5000)
            .then((clinics) {
          for (final clinic in clinics) {
            final Set<String> processedIds = {};
            if (processedIds.add(clinic.placeId)) {
              FirebaseCalls().addClinicIfNotFound(clinic);
            };
          }
          return clinics;
        });
        _markersFuture =
            _clinicsFuture.then((clinics) => _generateMarkers(clinics));
      });
    }
    // Regions Default -> Central
    else if (selectedButtonIndex == 0) {
      setState(() {
        _clinicsFuture = GeoApifyApiCalls().fetchClinics(_selectedRegion).then((clinics) {
          for (final clinic in clinics) {
            final Set<String> processedIds = {};
            if (processedIds.add(clinic.placeId)) {
              FirebaseCalls().addClinicIfNotFound(clinic);
            };
          }
          return clinics;
        });
        _markersFuture =
            _clinicsFuture.then((clinics) => _generateMarkers(clinics));
      });
      _showCitiesDialog();
    }
    if (selectedButtonIndex == 2) {
      setState(() {
        _clinicsFuture = FirebaseCalls().getUserSavedClinics();
        _markersFuture =
            _clinicsFuture.then((clinics) => _generateMarkers(clinics));
      });
    }
    // Open across SG?
   else if (selectedButtonIndex == 3) {
      setState(() {
        _clinicsFuture = GeoApifyApiCalls().fetchClinics('Singapore').then((clinics) {
          for (final clinic in clinics) {
            final Set<String> processedIds = {};
            if (processedIds.add(clinic.placeId)) {
              FirebaseCalls().addClinicIfNotFound(clinic);
            };
          }
          return clinics;
        });
        _markersFuture =
            _clinicsFuture.then((clinics) => _generateMarkers(clinics));
      });
    }
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
              _clinicsFuture =
                  GeoApifyApiCalls().fetchClinics(_selectedRegion).then((clinics) {
                for (final clinic in clinics) {
                  final Set<String> processedIds = {};
                  if (processedIds.add(clinic.placeId)) {
                    FirebaseCalls().addClinicIfNotFound(clinic);
                  };
                }
                return clinics;
              });
              _markersFuture =
                  _clinicsFuture.then((clinics) => _generateMarkers(clinics));
            });
          },
        );
      },
    );
  }

  Future<List<Marker>> _generateMarkers(List<Clinic> clinicsList) async {
    // List<Clinic> clinicsList = await GeoApifyApiCalls().fetchClinics(region);

    List<Marker> markers = [];

    // Filter clinics based on selected button
    List<Clinic> filteredClinics = clinicsList;

    if (selectedButtonIndex == 2) {
      // Show only saved clinics

      filteredClinics = clinicsList
          .where((clinic) => _savedClinicPlaceIds.contains(clinic.placeId))
          .toList();
    } else if (selectedButtonIndex == 3) {
      // Show only open clinics
      filteredClinics = clinicsList.where((clinic) {
        final displayData = getClinicDisplayInfo(
          currentLat: _currentLocation?.latitude,
          currentLon: _currentLocation?.longitude,
          calculateDistance: _calculateDistance,
          clinic: clinic,
        );
        return displayData['isOpen'] == true;
      }).toList();
    }

    markers.addAll(filteredClinics.map((clinic) {
      return Marker(
        point: LatLng(clinic.lat, clinic.lon),
        width: 35,
        height: 35,
        alignment: Alignment.topCenter,
        rotate: true,
        child: GestureDetector(
          onTap: () {            
            setState(() {
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

void _saveClinicsFirebase() async {
    // Save the _savedClinicPlaceIds to Firebase
    try {
      await FirebaseCalls().saveUserSavedClinics(_savedClinicPlaceIds,);
    } catch (e) {
      print('Error saving clinics to Firebase: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
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
                  ClinicSearchBar(
                      isDarkMode: isDarkMode,
                      colorScheme: colorScheme,
                      theme: theme),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      _buildNavButton(0, Icons.location_city, 'Regions'),
                      SizedBox(width: 8),
                      _buildNavButton(1, Icons.location_on, 'Nearby'),
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
                          selectedButtonIndex == 0
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
                          } else if (selectedButtonIndex == 3) {
                            // Filter to show only open clinics
                            clinics = clinics.where((clinic) {
                              final displayData = getClinicDisplayInfo(
                                currentLat: _currentLocation?.latitude,
                                currentLon: _currentLocation?.longitude,
                                calculateDistance: _calculateDistance,
                                clinic: clinic,
                              );
                              return displayData['isOpen'] == true;
                            }).toList();
                          }

                          //else if ( it is from Search bar ) { filter results with the name of it? }

                          if (clinics.isEmpty) {
                            String emptyMessage = selectedButtonIndex == 2
                                ? "No saved clinics."
                                : selectedButtonIndex == 3
                                    ? "No open clinics found."
                                    : "No clinics found.";
                            return Center(child: Text(emptyMessage));
                          }

                          return Column(
                            children: clinics.map(
                              (clinic) => buildClinicCard(context, clinic)
                            ).toList(),
                          );
                        },
                      )
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

    if (displaySpecialty.isNotEmpty) {
      // Replace ';' with ', ' and '_' with ' '
      String cleaned =
          displaySpecialty.replaceAll(';', ', ').replaceAll('_', ' ');

      // Split by ', ', camelcase each item, then join again
      List<String> specialties = cleaned.split(', ').map((item) {
        return item.split(' ').map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        }).join(' ');
      }).toList();

      displaySpecialty = specialties.join(', ');
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

  Widget buildClinicCard(BuildContext context, Clinic clinic) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isSaved = _savedClinicPlaceIds.contains(clinic.placeId);

    final displayData = getClinicDisplayInfo(
      currentLat: _currentLocation?.latitude,
      currentLon: _currentLocation?.longitude,
      calculateDistance: _calculateDistance,
      clinic: clinic,
    );

    final String distance = displayData['distance'];
    final String specialties = displayData['displaySpecialty'];
    final String openingHours = displayData['displayHours'];
    final bool isOpen = displayData['isOpen'];

    return GestureDetector(
      onTap: () {
        _mapController.move(LatLng(clinic.lat, clinic.lon), 17.0);

        // Reorder list: move this clinic to the top
        setState(() {
          final clickedIndex = _loadedClinics.indexWhere((c) =>
              c.lat == clinic.lat &&
              c.lon == clinic.lon); // match by coordinates
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
            color: colorScheme.outline.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(isDark ? 0.3 : 0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
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
                          clinic.name,
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
                                          MakeAppointmentsScreen(clinic)),
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
                            if (clinic.phone != null && clinic.phone!.isNotEmpty)
                            ...[
                              SizedBox(width: 8),
                              FilledButton.tonal(
                                onPressed: () async {
                                  final Uri phoneUri =
                                      Uri(scheme: 'tel', path: clinic.phone);
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
                            if (clinic.website != null &&
                                clinic.website!.isNotEmpty) ...[
                              SizedBox(width: 8),
                              FilledButton.tonal(
                                onPressed: () async {
                                  final Uri websiteUri =
                                      Uri.parse(clinic.website!);
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
                                    _savedClinicPlaceIds.remove(clinic.placeId);
                                  } else {
                                    _savedClinicPlaceIds.add(clinic.placeId);
                                  }

                                  // If on the "Saved" tab, refresh the markers
                                  if (selectedButtonIndex == 2) {
                                    // Re-fetch the saved clinics and regenerate markers
                                    _clinicsFuture = FirebaseCalls().getUserSavedClinics();
                                    _markersFuture = _clinicsFuture.then((clinics) => _generateMarkers(clinics));
                                  }
                                });
                                _saveClinicsFirebase(); // Save to Firebase
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: colorScheme.surfaceVariant,
                                foregroundColor: colorScheme.onSurfaceVariant,
                                minimumSize: Size(0, 36),
                                maximumSize: Size(double.infinity, 36),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 0),
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

          _searchByOptions(index);

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
