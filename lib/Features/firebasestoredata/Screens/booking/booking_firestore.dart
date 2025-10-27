// provider/admin_bookings_provider.dart
import 'package:coffee_exult_app/Features/firebasestoredata/Screens/booking/booking_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final adminFirestoreServiceProvider = Provider<AdminFirestoreService>((ref) {
  return AdminFirestoreService();
});

final adminBookingsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final adminService = ref.watch(adminFirestoreServiceProvider);
  
  return adminService.getAllBookings().map((snapshot) {
    return snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        ...doc.data(),
      };
    }).toList();
  });
});

final bookingStatsProvider = FutureProvider<Map<String, int>>((ref) {
  final adminService = ref.watch(adminFirestoreServiceProvider);
  return adminService.getBookingStats();
});

// Provider for filtered bookings
final filteredBookingsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final bookings = ref.watch(adminBookingsProvider);
  final filter = ref.watch(bookingFilterProvider);
  
  return bookings.when(
    data: (bookingsList) {
      if (filter == 'all') return bookingsList;
      return bookingsList.where((booking) => booking['status'] == filter).toList();
    },
    loading: () => [],
    error: (_,_) => [],
  );
});

// Filter provider
final bookingFilterProvider = StateProvider<String>((ref) => 'all');