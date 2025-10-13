// location_provider.dart
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationState {
  final Position? position;
  final String address;
  final String errorMessage;
  final bool isLoading;
  final bool showImage;
  final bool showLocation;

  LocationState({
    this.position,
    this.address = 'Fetching your location...',
    this.errorMessage = '',
    this.isLoading = true,
    this.showImage = false,
    this.showLocation = false,
  });

  LocationState copyWith({
    Position? position,
    String? address,
    String? errorMessage,
    bool? isLoading,
    bool? showImage,
    bool? showLocation,
  }) {
    return LocationState(
      position: position ?? this.position,
      address: address ?? this.address,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
      showImage: showImage ?? this.showImage,
      showLocation: showLocation ?? this.showLocation,
    );
  }
}

class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier() : super(LocationState());

  Future<void> fetchLocation() async {
    try {
      state = state.copyWith(
        isLoading: true,
        errorMessage: '',
        showImage: false,
        showLocation: false,
      );

      // Show image first with delay
      await Future.delayed(const Duration(milliseconds: 500));
      state = state.copyWith(showImage: true);

      final position = await _determinePosition();
      final address = await _convertCoordinatesToAddress(
        position.latitude,
        position.longitude,
      );
     log('Address: $address');
      // Show location with delay after image
      await Future.delayed(const Duration(milliseconds: 800));
      state = state.copyWith(
        position: position,
        address: address,
        isLoading: false,
        showLocation: true,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
        address: 'Failed to get location',
        showImage: true,
        showLocation: true,
      );
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  Future<String> _convertCoordinatesToAddress(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isEmpty) {
        return 'Address not found';
      }

      final Placemark place = placemarks[0];
      final List<String> addressParts = [];

      if (place.street != null && place.street!.isNotEmpty) {
        addressParts.add(place.street!);
      }

      if (place.subLocality != null && place.subLocality!.isNotEmpty) {
        addressParts.add(place.subLocality!);
      } else if (place.locality != null && place.locality!.isNotEmpty) {
        addressParts.add(place.locality!);
      }

      if (place.administrativeArea != null &&
          place.administrativeArea!.isNotEmpty) {
        addressParts.add(place.administrativeArea!);
      }

      if (place.postalCode != null && place.postalCode!.isNotEmpty) {
        addressParts.add(place.postalCode!);
      }

      if (place.country != null && place.country!.isNotEmpty) {
        addressParts.add(place.country!);
      }

      return addressParts.isEmpty
          ? 'Address information not available'
          : addressParts.join(', ');
    } catch (e) {
      return 'Could not get address';
    }
  }
}

final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>(
  (ref) => LocationNotifier(),
);
