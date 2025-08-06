import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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
            _currentLocation ?? const LatLng(1.3793, 103.8481), // fallback to NYP
        initialZoom: 16,
        // Enable rotation
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          // urlTemplate:
          //     'https://tiles.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',

          userAgentPackageName: 'com.example.healthify',
        ),
        if (_currentLocation != null)
          FutureBuilder<List<Marker>>(
            future: markerList,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(
                  // Made it transparent since we already have other Circular Progress Indicators
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.transparent),
                ));
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
          // Actual Current Location
          CircleLayer(
            circles: [
              CircleMarker(
                point: _currentLocation,
                radius: 50, // meters
                useRadiusInMeter: true,
                color: Colors.blue.withOpacity(0.1),
                borderColor: Colors.blue.withOpacity(0.3),
                borderStrokeWidth: 1,
              ),
            ],
          ),
        if (_currentLocation != null)
          CircleLayer(
            circles: [
              CircleMarker(
                point: _currentLocation,
                radius: 7, // pixels
                useRadiusInMeter: false,
                color: const Color.fromARGB(255, 12, 85, 252),
                borderColor: Colors.white,
                borderStrokeWidth: 4,
              ),
            ],
          ),
      ],
    );
  }
}
