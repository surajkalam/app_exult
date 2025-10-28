import 'package:coffee_exult_app/DATABASE_HELPER/topseller_database.dart';
import 'package:coffee_exult_app/Features/Home/models/user_salesmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Firebase Sales Service Provider
final firebaseSalesServiceProvider = Provider<FirebaseSalesService>((ref) {
  return FirebaseSalesService();
});

// Top Sellers Provider for LAST MONTH (Future)
final topSellersProvider = FutureProvider<List<UserSales>>((ref) async {
  final salesService = ref.read(firebaseSalesServiceProvider);
  return await salesService.getTopSellersLastMonth(); // Changed to last month
});

// Top Sellers Provider (Stream - real-time updates for last month)
final topSellersStreamProvider = StreamProvider<List<UserSales>>((ref) {
  final salesService = ref.read(firebaseSalesServiceProvider);
  return salesService.getTopSellersStream();
});

// Current month provider (if needed for comparison)
final currentMonthSellersProvider = FutureProvider<List<UserSales>>((ref) async {
  final salesService = ref.read(firebaseSalesServiceProvider);
  return await salesService.getTopSellersThisMonth();
});

// Refresh provider
final refreshTopSellersProvider = Provider<void>((ref) {
  ref.invalidate(topSellersProvider);
});

// Month name provider
final lastMonthNameProvider = Provider<String>((ref) {
  final salesService = ref.read(firebaseSalesServiceProvider);
  return salesService.getLastMonthName();
});
