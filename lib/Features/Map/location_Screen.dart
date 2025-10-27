
// location_screen.dart
import 'package:coffee_exult_app/Features/Map/map_navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffee_exult_app/Features/Map/provider/location_provider.dart';
import 'package:geolocator/geolocator.dart';// Your new service

class LocationScreen extends ConsumerStatefulWidget {
  const LocationScreen({super.key});

  @override
  ConsumerState<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends ConsumerState<LocationScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch location when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(locationProvider.notifier).fetchLocation();
    });
  }

  void _openGoogleMaps(Position position) {
    MapNavigationService.openGoogleMapsNavigation(
      destinationLat: position.latitude,
      destinationLng: position.longitude,
      destinationName: 'Your Location',
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text('Finding your location...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 50),
          const SizedBox(height: 20),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => ref.read(locationProvider.notifier).fetchLocation(),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(Position position, String address) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_on, size: 60, color: Colors.blue),
          const SizedBox(height: 20),
          Text(
            'Latitude: ${position.latitude.toStringAsFixed(6)}',
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            'Longitude: ${position.longitude.toStringAsFixed(6)}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              address,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => _openGoogleMaps(position),
            icon: const Icon(Icons.map),
            label: const Text('Open in Google Maps'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
          ),
          const SizedBox(height: 10),
          // TextButton(
          //   onPressed: () {
          //     // Print coordinates to console
          //     log('Latitude: ${position.latitude}');
          //     log('Longitude: ${position.longitude}');
          //     log('Address: $address');
              
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       const SnackBar(content: Text('Location data printed to console')),
          //     );
          //   },
          //   child: const Text('Print to Console'),
          // ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Location'),
        actions: [
          if (locationState.position != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.read(locationProvider.notifier).fetchLocation(),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: locationState.isLoading
            ? _buildLoadingState()
            : locationState.errorMessage.isNotEmpty
                ? _buildErrorState(locationState.errorMessage)
                : _buildSuccessState(locationState.position!, locationState.address),
      ),
    );
  }
}