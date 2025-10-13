// map_navigation_service.dart
import 'dart:developer';

import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

class MapNavigationService {
  // Open Google Maps with navigation from current location to destination
  static Future<void> openGoogleMapsNavigation({
    required double destinationLat,
    required double destinationLng,
    String? destinationName,
  }) async {
    try {
      // Get current location using your existing provider logic
      final Position? currentLocation = await _getCurrentPosition();
      
      String url;
      
      if (currentLocation != null) {
        // Navigation from current location to destination
        url = 'https://www.google.com/maps/dir/?api=1&'
              'origin=${currentLocation.latitude},${currentLocation.longitude}&'
              'destination=$destinationLat,$destinationLng&'
              'travelmode=driving&'
              'dir_action=navigate';
      } else {
        // Just show destination if location not available
        url = 'https://www.google.com/maps/search/?api=1&'
              'query=$destinationLat,$destinationLng';
      }

      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw 'Could not launch Google Maps';
      }
    } catch (e) {
      log('Error opening Google Maps: $e');
      rethrow;
    }
  }

  // Helper method to get current position
  static Future<Position?> _getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        // ignore: deprecated_member_use
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      log('Error getting current position: $e');
      return null;
    }
  }

  // Open Google Maps with just the location (no navigation)
  static Future<void> openGoogleMapsLocation({
    required double lat,
    required double lng,
    String? label,
  }) async {
    try {
      final String url = label != null
          ? 'https://www.google.com/maps/search/?api=1&query=$lat,$lng&query_place_id=$label'
          : 'https://www.google.com/maps/@?api=1&map_action=map&center=$lat,$lng&zoom=15';

      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      log('Error opening maps: $e');
    }
  }

  // Calculate distance between two points
  static double calculateDistance(
    double startLat, 
    double startLng, 
    double endLat, 
    double endLng
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }
}