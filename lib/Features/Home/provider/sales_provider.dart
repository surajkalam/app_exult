import 'package:coffee_shop/DATABASE_HELPER/topseller_database.dart';
import 'package:coffee_shop/Features/Home/models/user_salesmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Firebase Sales Service Provider
final firebaseSalesServiceProvider = Provider<FirebaseSalesService>((ref) {
  return FirebaseSalesService();
});

// Top Sellers Provider (Future)
final topSellersProvider = FutureProvider<List<UserSales>>((ref) async {
  final salesService = ref.read(firebaseSalesServiceProvider);
  return await salesService.getTopSellersThisMonth();
});

// Top Sellers Provider (Stream - real-time updates)
final topSellersStreamProvider = StreamProvider<List<UserSales>>((ref) {
  final salesService = ref.read(firebaseSalesServiceProvider);
  return salesService.getTopSellersStream();
});

// Refresh provider
final refreshTopSellersProvider = Provider<void>((ref) {
  ref.invalidate(topSellersProvider);
});