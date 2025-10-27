// providers/firebase_menu_provider.dart
import 'package:coffee_exult_app/Features/Menu/Provider/firebase_menu_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseMenuServiceProvider = Provider<FirebaseMenuService>((ref) {
  return FirebaseMenuService();
});

final menuCategoriesProvider = FutureProvider<Map<String, List<Map<String, dynamic>>>>((ref) async {
  final firebaseService = ref.read(firebaseMenuServiceProvider);
  return await firebaseService.getMenuItems();
});

// Or if you want real-time updates:
final menuCategoriesStreamProvider = StreamProvider<Map<String, List<Map<String, dynamic>>>>((ref) {
  final firebaseService = ref.read(firebaseMenuServiceProvider);
  return firebaseService.getMenuItemsStream();
});