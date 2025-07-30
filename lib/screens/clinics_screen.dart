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

class ClinicsScreen extends StatefulWidget {
  const ClinicsScreen({Key? key}) : super(key: key);

  @override
  State<ClinicsScreen> createState() => _ClinicsScreenState();
}

late Future<List<Clinic>> _clinicsFuture;
late Future<List<Marker>> _markersFuture;

class _ClinicsScreenState extends State<ClinicsScreen> {
  List<String> _regions = [
    'Central',
    'Northwest',
    'Southwest',
    'Northeast',
    'Southeast',
  ];

  String _selectedRegion = 'Central';

  // Current Location GPS
  LatLng? _currentLocation;
  bool _isLoadingLocation = false;
  final MapController _mapController = MapController();

  final GlobalKey _stackKey = GlobalKey();
  double _stackHeight = 0.0;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _clinicsFuture = ApiCalls().fetchClinics(_selectedRegion);
    _markersFuture = _generateMarkers(_selectedRegion);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox? box = _stackKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null) {
        setState(() {
          _stackHeight = box.size.height;
        });
      }
    });
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
          point: _currentLocation!,
          width: 20,
          height: 20,
          alignment: Alignment.center,
          rotate: false,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromARGB(237, 14, 204, 39),
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
        width: 20,
        height: 20,
        alignment: Alignment.center,
        rotate: false,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedClinic = clinic;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromARGB(237, 233, 4, 4),
              border: Border.all(color: Colors.white, width: 3),
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
    }));

    return markers;
  }

  int selectedButtonIndex = 0;
  final DraggableScrollableController _controller = DraggableScrollableController();

  double _liveSheetSize = 0.35;

  late Clinic _selectedClinic;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    ColorScheme colorScheme = theme.colorScheme;
    bool isDarkMode = theme.brightness == Brightness.dark;
    return Scaffold(
      bottomNavigationBar: CustomBottomNavigationBar(selectedIndex: 1),
      body: Stack(
        key: _stackKey,
        children: [
          Positioned.fill(
            child: ClinicMap(
                mapController: _mapController,
                currentLocation: _currentLocation,
                markerList: _markersFuture), // <-- Pass the state variable here  
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
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
          Positioned(
            right: 16,
            bottom: math.min((_stackHeight * _liveSheetSize) + 24, 550),
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
                  : Icon(Icons.my_location, size: 25),
            ),
          ),
          DraggableScrollableSheet(
            controller: _controller,
            initialChildSize: 0.35,
            minChildSize: 0.2,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return NotificationListener<DraggableScrollableNotification>(
                onNotification: (notification) {
                  final RenderBox? box = _stackKey.currentContext
                      ?.findRenderObject() as RenderBox?;
                  if (box != null) {
                    setState(() {
                      _stackHeight = box.size.height;
                      _liveSheetSize = notification.extent;
                    });
                  }
                  return true;
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .shadowColor
                            .withValues(alpha: 0.2),
                        blurRadius: 12,
                        spreadRadius: 2,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: ListView(
                    controller: scrollController,
                    physics: ClampingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      Center(
                        child: Container(
                          margin:
                              EdgeInsets.symmetric(vertical: 12, horizontal: 0),
                          width: 40,
                          height: 4.5,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Search by Distance',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              _selectedRegion,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      // Add more widgets here if needed
                      //
                      buildClinicCard(
                        context,
                        "One Doctors Family Clinic",
                        "2.1 km", // Calculate from coordinates
                        "Family Medicine, General", // Or parse from categories
                        "W" ?? "Hours not available",
                        phone: "W",
                      ),
                      FutureBuilder<List<Clinic>>(
                        future: _clinicsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator()
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text("Error: ${snapshot.error}"));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Center(
                                child: Text("No clinics found."));
                          }

                          final clinics = snapshot.data!;
                          return Column(
                            children: clinics.map((clinic) {
                              final distance = _currentLocation != null
                                  ? "${_calculateDistance(_currentLocation!.latitude, _currentLocation!.longitude, clinic.lat, clinic.lon).toStringAsFixed(1)} km"
                                  : "Unknown";

                              final now = DateTime.now();
                              final currentTimeMinutes =
                                  now.hour * 60 + now.minute;

                              // Attempt to parse opening hours in the format "HH:MM-HH:MM"
                              int openMinutes = 540; // Default 9:00 AM
                              int closeMinutes = 1260; // Default 9:00 PM
                              // print("Opening hours raw: ${clinic.openingHours}");

                              if (clinic.openingHours.contains('-')) {
                                final parts = clinic.openingHours.split('-');
                                if (parts.length == 2) {
                                  final openParts = parts[0].trim().split(':');
                                  final closeParts = parts[1].trim().split(':');

                                  if (openParts.length == 2 &&
                                      closeParts.length == 2) {
                                    final openHour = int.tryParse(openParts[0]);
                                    final openMinute = int.tryParse(openParts[1]);
                                    final closeHour = int.tryParse(closeParts[0]);
                                    final closeMinute = int.tryParse(closeParts[1]);

                                    if (openHour != null &&
                                        openMinute != null &&
                                        closeHour != null &&
                                        closeMinute != null) {
                                      openMinutes = openHour * 60 + openMinute;
                                      closeMinutes = closeHour * 60 + closeMinute;
                                    }
                                  }
                                }
                              }

                              final isOpen = currentTimeMinutes >= openMinutes && currentTimeMinutes <= closeMinutes;
                              final displayHours = isOpen ? "Open Now" : "Closed";

                              String displaySpecialty = clinic.speciality;
                              if (displaySpecialty.isEmpty) {
                                if (clinic.name
                                    .toLowerCase()
                                    .contains("family")) {
                                  displaySpecialty = "Family Medicine";
                                } else if (clinic.name
                                    .toLowerCase()
                                    .contains("surgery")) {
                                  displaySpecialty = "General Surgery";
                                } else {
                                  displaySpecialty = "Medical Clinic";
                                }
                              }

                              return buildClinicCard(
                                context,
                                clinic.name,
                                distance,
                                displaySpecialty,
                                "${displayHours} • ${clinic.openingHours.isNotEmpty ? clinic.openingHours : '09:00-21:00'}",
                                phone: clinic.phone,
                                website: clinic.website,
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
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

  Widget buildClinicCard(BuildContext context, String name, String distance,
      String specialties, String openingHours,
      {String? phone, String? website}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Parse opening hours to determine if open now
    bool isOpenNow = _isClinicOpenNow(openingHours);
    String displayHours = isOpenNow ? "Open Now" : "Closed";
    displayHours = "${displayHours} • 9:00 AM - 9:00PM";

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
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
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.local_hospital,
              color: colorScheme.primary,
              size: 28,
            ),
          ),
          SizedBox(width: 16),

          // Clinic details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 6),
                // Distance only (no rating)
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
                  ],
                ),
                SizedBox(height: 4),
                // Healthcare category instead of specialties
                Text(
                  specialties, // Or derive from categories in JSON
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 4),
                // Opening hours with proper icon
                Row(
                  children: [
                    Icon(
                      isOpenNow ? Icons.schedule : Icons.schedule,
                      size: 12,
                      color: isOpenNow
                          ? (isDark ? Colors.green[400] : Colors.green[600])
                          : colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(width: 4),
                    Text(
                      displayHours,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isOpenNow
                            ? (isDark ? Colors.green[400] : Colors.green[600])
                            : colorScheme.onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action buttons - only show phone if available
          Column(
            children: [
              Container(
                width: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.surfaceVariant,
                ),
                child: IconButton(
                  icon: Icon(Icons.favorite_border, size: 16),
                  onPressed: () {},
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              if (phone != null) ...[
                SizedBox(height: 4),
                Container(
                  width: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.primaryContainer,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.phone, size: 16),
                    onPressed: () {
                      // Launch phone dialer
                    },
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ],
          ),
        ],
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
  }) : _mapController = mapController, _currentLocation = currentLocation;

  final MapController _mapController;
  final LatLng? _currentLocation;
  final Future<List<Marker>> markerList;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _currentLocation ?? LatLng(1.3793, 103.8481), // fallback to NYP
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
