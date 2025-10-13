// //check animation
// //
// // location_screen.dart
// import 'package:coffee_shop/Features/Map/mapscreen.dart';
// import 'package:coffee_shop/Features/Map/provider/locationprovider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:go_router/go_router.dart'; // Make sure you have go_router package

// class LocationScreen extends ConsumerStatefulWidget {
//   const LocationScreen({super.key});

//   @override
//   ConsumerState<LocationScreen> createState() => _LocationScreenState();
// }

// class _LocationScreenState extends ConsumerState<LocationScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _imageAnimation;
//   late Animation<double> _textAnimation;

//   @override
//   void initState() {
//     super.initState();

//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1500),
//     );

//     _imageAnimation = Tween<double>(begin: 0, end: 1).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
//       ),
//     );

//     _textAnimation = Tween<double>(begin: 0, end: 1).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
//       ),
//     );

//     // Start animations
//     _controller.forward();

//     // Fetch location and setup navigation
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ref.read(locationProvider.notifier).fetchLocation().then((_) {
//         // Navigate to home after 3 seconds of showing location
//         Future.delayed(const Duration(seconds: 7), () {
//           if (mounted) {
//             context.go('/navbar');
//           }
//         });
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   Widget _buildLoadingState() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         FadeTransition(
//           opacity: _imageAnimation,
//           child: Image.asset(
//             "Assets/Images/mapsplashscreen12.png",
//             height: 100,
//             width: 150,
//             fit: BoxFit.contain,
//           ),
//         ),
//         const SizedBox(height: 30),
//         const CircularProgressIndicator(),
//         const SizedBox(height: 20),
//         FadeTransition(
//           opacity: _textAnimation,
//           child: const Text(
//             'Finding your location...',
//             style: TextStyle(fontSize: 16, color: Colors.grey),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildErrorState(String errorMessage) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         FadeTransition(
//           opacity: _imageAnimation,
//           child: Image.asset(
//             "Assets/Images/mapsplashscreen12.png",
//             height: 100,
//             width: 150,
//             fit: BoxFit.contain,
//           ),
//         ),
//         const SizedBox(height: 30),
//         FadeTransition(
//           opacity: _textAnimation,
//           child: const Icon(Icons.error_outline, color: Colors.red, size: 50),
//         ),
//         const SizedBox(height: 20),
//         FadeTransition(
//           opacity: _textAnimation,
//           child: Text(
//             errorMessage,
//             style: const TextStyle(color: Colors.red, fontSize: 16),
//             textAlign: TextAlign.center,
//           ),
//         ),
//         const SizedBox(height: 20),
//         FadeTransition(
//           opacity: _textAnimation,
//           child: ElevatedButton(
//             onPressed: () =>
//                 ref.read(locationProvider.notifier).fetchLocation(),
//             child: const Text('Try Again'),
//           ),
//         ),
//       ],
//     );
//   }
//   //   void navigateToMapScreen(BuildContext context, dynamic state) {
//   //   if (state.position != null) {
//   //     Navigator.of(context).push(
//   //       MaterialPageRoute(builder: (context) => const MapScreen()),
//   //     );
//   //   }
//   // }

//   Widget _buildSuccessState(Position position, String address) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         FadeTransition(
//           opacity: _imageAnimation,
//           child: ScaleTransition(
//             scale: _imageAnimation,
//             child: Image.asset(
//               "Assets/Images/mapsplashscreen12.png",
//               height: 150,
//               width: 150,
//               fit: BoxFit.contain,
//             ),
//           ),
//         ),
//         const SizedBox(height: 30),
//         FadeTransition(
//           opacity: _textAnimation,
//           child: SlideTransition(
//             position: Tween<Offset>(
//               begin: const Offset(0, 0.2),
//               end: Offset.zero,
//             ).animate(_textAnimation),
//             child: ElevatedButton(
//               onPressed: () {
//                 Navigator.of(context).push(
//                   MaterialPageRoute(
//                     builder: (context) => MapScreen(
//                       latitude: position.latitude,
//                       longitude: position.longitude,
//                       address: address,
//                     ),
//                   ),
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.brown[700],
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 30,
//                   vertical: 15,
//                 ),
//               ),
//               child: const Text('View on Map'),
//             ),
//           ),
//         ),
//         const SizedBox(height: 20),
//         FadeTransition(
//           opacity: _textAnimation,
//           child: SlideTransition(
//             position: Tween<Offset>(
//               begin: const Offset(0, 0.3),
//               end: Offset.zero,
//             ).animate(_textAnimation),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20.0),
//               child: Text(
//                 address,
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.blue,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(height: 10),
//         FadeTransition(
//           opacity: _textAnimation,
//           child: SlideTransition(
//             position: Tween<Offset>(
//               begin: const Offset(0, 0.2),
//               end: Offset.zero,
//             ).animate(_textAnimation),
//           ),
//         ),
//       ],
//     );
//   }
//   // Add this to your LocationProvider notifier

//   @override
//   Widget build(BuildContext context) {
//     final locationState = ref.watch(locationProvider);

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Center(
//           child: AnimatedSwitcher(
//             duration: const Duration(milliseconds: 500),
//             child: locationState.isLoading
//                 ? _buildLoadingState()
//                 : locationState.errorMessage.isNotEmpty
//                 ? _buildErrorState(locationState.errorMessage)
//                 : _buildSuccessState(
//                     locationState.position!,
//                     locationState.address,
//                   ),
//           ),
//         ),
//       ),
//     );
//   }
// }
// location_screen.dart
import 'package:coffee_shop/Features/Map/map_navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffee_shop/Features/Map/provider/location_provider.dart';
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