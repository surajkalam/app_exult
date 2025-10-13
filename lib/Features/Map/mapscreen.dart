import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String address;
  
  const MapScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.address,
  });
  
  @override
  Widget build(BuildContext context) {
    // Create marker for the location
    final Set<Marker> markers = {
      Marker(
        markerId: const MarkerId('location'),
        position: LatLng(latitude, longitude),
        infoWindow: InfoWindow(
          title: 'Location',
          snippet: address,
        ),
      ),
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Location'),
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: 15,
        ),
        markers: markers,
        zoomControlsEnabled: true,
        compassEnabled: true,
      ),
    );
  }
}